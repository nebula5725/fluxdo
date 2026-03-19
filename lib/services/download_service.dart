import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'network/discourse_dio.dart';

/// 文件下载服务（单例）
///
/// 使用 DiscourseDio.create() 创建 Dio 实例，
/// 自动继承代理/DOH/rhttp/Cookie 等所有网络设置。
class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();
  factory DownloadService() => instance;

  late final Dio _dio;

  /// 初始化下载专用 Dio 实例
  void initialize() {
    _dio = DiscourseDio.create(
      receiveTimeout: const Duration(minutes: 30),
      maxConcurrent: null, // 下载不受并发限制
      enableCfChallenge: false, // 下载不需要 CF 验证
    );
    debugPrint('[DownloadService] 初始化完成');
  }

  /// 下载文件到本地
  Future<void> download({
    required String url,
    required String savePath,
    required void Function(int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    await _dio.download(
      url,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
      options: Options(extra: {'skipCsrf': true, 'skipAuthCheck': true}),
    );
  }

  /// 从 URL / suggestedFilename 解析文件名
  static String resolveFileName(String url, {String? suggestedFilename}) {
    // 优先使用建议文件名
    if (suggestedFilename != null && suggestedFilename.isNotEmpty) {
      return suggestedFilename;
    }
    // 从 URL 路径解析
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final last = segments.last;
        if (last.isNotEmpty && last.contains('.')) {
          return Uri.decodeComponent(last);
        }
      }
    } catch (_) {}
    // 兜底：用时间戳
    return 'download_${DateTime.now().millisecondsSinceEpoch}';
  }
}
