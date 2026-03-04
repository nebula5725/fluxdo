import 'dart:convert';
import 'dart:io';

import 'log_writer.dart';

/// 日志文件管理工具
class LoggerUtils {
  LoggerUtils._();

  /// 过期天数
  static const int _expireDays = 14;

  /// 获取日志文件
  static Future<File> getLogFile() => LogWriter.getLogFile();

  /// 获取日志文件路径（用于分享文件）
  static Future<String> getLogFilePath() async {
    final file = await getLogFile();
    return file.path;
  }

  /// 读取并解析 JSONL，逆序返回（最新在前）
  /// 对旧格式条目（无 level/type 字段）默认当作 error + general
  static Future<List<Map<String, dynamic>>> readLogEntries() async {
    final file = await getLogFile();
    if (!file.existsSync()) return [];

    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];

    final lines = content.trim().split('\n');
    final entries = <Map<String, dynamic>>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        // 兼容旧格式
        json['level'] ??= 'error';
        json['type'] ??= 'general';
        // 旧格式的 message 在 customParameters.message 中
        if (json['message'] == null) {
          final customParams =
              json['customParameters'] as Map<String, dynamic>?;
          json['message'] = customParams?['message']?.toString() ??
              json['error']?.toString();
          // 同时提升 tag
          json['tag'] ??= customParams?['tag']?.toString();
        }
        entries.add(json);
      } catch (_) {
        // 跳过无法解析的行
      }
    }

    return entries.reversed.toList();
  }

  /// 读取原始文本（用于复制/分享）
  static Future<String> readLogContent() async {
    final file = await getLogFile();
    if (!file.existsSync()) return '';
    return file.readAsString();
  }

  /// 清理 14 天前的过期条目
  static Future<void> cleanExpiredLogs() async {
    final file = await getLogFile();
    if (!file.existsSync()) return;

    final content = await file.readAsString();
    if (content.trim().isEmpty) return;

    final lines = content.trim().split('\n');
    final now = DateTime.now();
    final retained = <String>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final timestamp = json['timestamp'] as String?;
        if (timestamp != null) {
          final time = DateTime.tryParse(timestamp);
          if (time != null && now.difference(time).inDays < _expireDays) {
            retained.add(line);
          }
        }
      } catch (_) {
        // 无法解析的行也丢弃
      }
    }

    await file.writeAsString('${retained.join('\n')}\n');
  }

  /// 清空日志
  static Future<void> clearLogs() async {
    final file = await getLogFile();
    if (file.existsSync()) {
      await file.writeAsString('');
    }
  }
}
