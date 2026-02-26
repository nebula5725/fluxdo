part of 'discourse_service.dart';

/// 通知相关
mixin _NotificationsMixin on _DiscourseServiceBase {
  /// 触发 bump_last_seen_notification，清除通知计数
  /// 使用 recent 模式让服务端自动更新 seen_notification_id
  Future<void> bumpSeenNotification() async {
    await _dio.get(
      '/notifications',
      queryParameters: {
        'recent': true,
        'limit': 1,
        'bump_last_seen_reviewable': true,
      },
    );
  }

  /// 获取通知列表（默认模式，支持完整分页）
  Future<NotificationListResponse> getNotifications({int? offset}) async {
    final queryParams = <String, dynamic>{
      'limit': 60,
    };
    if (offset != null) {
      queryParams['offset'] = offset;
    }

    final response = await _dio.get(
      '/notifications',
      queryParameters: queryParams,
    );
    return NotificationListResponse.fromJson(response.data);
  }

  /// 标记所有通知为已读
  Future<void> markAllNotificationsRead() async {
    await _dio.put('/notifications/mark-read');
  }

  /// 标记单条通知为已读
  Future<void> markNotificationRead(int id) async {
    await _dio.put('/notifications/mark-read', data: {'id': id});
  }
}
