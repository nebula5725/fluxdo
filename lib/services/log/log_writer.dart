import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 统一日志写入器，所有日志通过此类写入同一个 JSONL 文件
class LogWriter {
  LogWriter._();

  static final LogWriter instance = LogWriter._();

  /// 最大文件大小 2MB
  static const int _maxFileSize = 2 * 1024 * 1024;

  /// 新日志文件名
  static const String _fileName = 'app_log.jsonl';

  /// 旧日志文件名（用于一次性迁移）
  static const String _oldFileName = 'app_error.jsonl';

  /// 用 Future 链串行化写入，避免并发冲突
  Future<void> _writeChain = Future.value();

  /// 写入一条日志条目
  void write(Map<String, dynamic> entry) {
    final line = '${jsonEncode(entry)}\n';
    _writeChain = _writeChain.then((_) => _writeLine(line));
  }

  /// 写入一行日志到文件
  Future<void> _writeLine(String line) async {
    try {
      final file = await getLogFile();
      await _truncateIfNeeded(file);
      await file.writeAsString(line, mode: FileMode.append, flush: true);
    } catch (_) {
      // 写入失败时静默忽略，避免日志写入导致应用崩溃
    }
  }

  /// 超过 2MB 时截断保留后半部分
  Future<void> _truncateIfNeeded(File file) async {
    if (!file.existsSync()) return;
    final size = await file.length();
    if (size < _maxFileSize) return;

    final content = await file.readAsString();
    final lines = content.split('\n');
    // 保留后半部分
    final halfIndex = lines.length ~/ 2;
    final retained = lines.sublist(halfIndex).join('\n');
    await file.writeAsString(retained);
  }

  /// 获取日志文件，包含旧文件迁移逻辑
  static Future<File> getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${dir.path}/logs');
    if (!logDir.existsSync()) {
      await logDir.create(recursive: true);
    }

    final newFile = File('${logDir.path}/$_fileName');
    final oldFile = File('${logDir.path}/$_oldFileName');

    // 一次性迁移：旧文件存在且新文件不存在时，重命名
    if (oldFile.existsSync() && !newFile.existsSync()) {
      await oldFile.rename(newFile.path);
    } else if (oldFile.existsSync() && newFile.existsSync()) {
      // 两个文件都存在时，将旧文件内容追加到新文件，然后删除旧文件
      final oldContent = await oldFile.readAsString();
      if (oldContent.trim().isNotEmpty) {
        await newFile.writeAsString(oldContent, mode: FileMode.append);
      }
      await oldFile.delete();
    }

    return newFile;
  }
}
