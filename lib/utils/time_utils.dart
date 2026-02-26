import 'package:intl/intl.dart';

/// 时间工具类 - 统一处理时间格式化和时区转换
class TimeUtils {
  TimeUtils._();

  /// 解析 UTC 时间字符串并转换为本地时间
  /// Discourse API 返回的时间是 UTC 格式
  static DateTime? parseUtcTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    try {
      // 解析为 UTC 时间
      final utcTime = DateTime.parse(timeString);
      // 转换为本地时间
      return utcTime.toLocal();
    } catch (e) {
      return null;
    }
  }

  /// 格式化时间为相对时间（刚刚、X分钟前、X小时前等）
  /// 适用于列表页等需要简洁显示的场景
  static String formatRelativeTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}周前';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}个月前';
    return '${(diff.inDays / 365).floor()}年前';
  }

  /// 格式化时间为详细时间字符串
  /// 格式：2024-01-15 14:30
  /// 适用于详情页等需要精确时间的场景
  static String formatDetailTime(DateTime? time) {
    if (time == null) return '';

    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(time);
  }

  /// 格式化时间为短日期
  /// 格式：1月15日
  static String formatShortDate(DateTime? time) {
    if (time == null) return '';

    return '${time.month}月${time.day}日';
  }

  /// 格式化时间为完整日期
  /// 格式：2024年1月15日
  static String formatFullDate(DateTime? time) {
    if (time == null) return '';

    return '${time.year}年${time.month}月${time.day}日';
  }

  /// 格式化时间为 Tooltip 精确时间
  /// 格式：2024年1月15日 14:30:25
  /// 适用于长按显示精确时间的场景
  static String formatTooltipTime(DateTime? time) {
    if (time == null) return '';

    return '${time.year}年${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  /// 格式化时间为智能日期标签
  /// 今天显示"今天"、昨天显示"昨天"、同年显示"1月15日"、跨年显示"2024年1月15日"
  static String formatSmartDate(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) return '今天';
    if (date == today.subtract(const Duration(days: 1))) return '昨天';
    if (time.year == now.year) return '${time.month}月${time.day}日';
    return '${time.year}年${time.month}月${time.day}日';
  }

  /// 格式化时间为紧凑格式
  /// 格式：01-15 14:30
  /// 适用于聊天引用等空间有限的场景
  static String formatCompactTime(DateTime? time) {
    if (time == null) return '';

    final formatter = DateFormat('MM-dd HH:mm');
    return formatter.format(time);
  }
}
