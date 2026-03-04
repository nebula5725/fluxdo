import 'package:dio/dio.dart';

import '../../log/log_writer.dart';

/// 网络请求日志拦截器，记录每个请求的 method/url/statusCode/duration
class NetworkLogInterceptor extends Interceptor {
  static const String _startTimeKey = '_networkLog_startTime';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logRequest(
      options: response.requestOptions,
      statusCode: response.statusCode,
      level: 'info',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logRequest(
      options: err.requestOptions,
      statusCode: err.response?.statusCode,
      level: 'warning',
    );
    handler.next(err);
  }

  void _logRequest({
    required RequestOptions options,
    required int? statusCode,
    required String level,
  }) {
    final startTime = options.extra[_startTimeKey] as int?;
    final duration = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;

    // URL 脱敏：不记录查询参数
    final uri = options.uri;
    final sanitizedUrl = '${uri.scheme}://${uri.host}${uri.path}';

    LogWriter.instance.write({
      'timestamp': DateTime.now().toIso8601String(),
      'level': level,
      'type': 'request',
      'message': '${options.method} ${uri.path}',
      'method': options.method,
      'url': sanitizedUrl,
      'statusCode': statusCode,
      'duration': duration,
    });
  }
}
