import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/legacy.dart';

import '../models/sticker.dart';
import '../services/sticker_market_service.dart';
import 'theme_provider.dart'; // sharedPreferencesProvider

/// 表情包市场服务 Provider
final stickerMarketServiceProvider = Provider<StickerMarketService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StickerMarketService(prefs);
});

/// 市场全部非归档分组
final stickerGroupsProvider = FutureProvider<List<StickerGroup>>((ref) async {
  final service = ref.watch(stickerMarketServiceProvider);
  return service.getAllGroups();
});

/// 分组详情（按 groupId 懒加载）
final stickerGroupDetailProvider =
    FutureProvider.family<StickerGroupDetail, String>((ref, groupId) async {
  final service = ref.watch(stickerMarketServiceProvider);
  return service.getGroupDetail(groupId);
});

/// 已订阅的分组 ID 列表（响应式）
final subscribedStickerIdsProvider =
    StateNotifierProvider<SubscribedStickerIdsNotifier, List<String>>((ref) {
  final service = ref.watch(stickerMarketServiceProvider);
  return SubscribedStickerIdsNotifier(service);
});

class SubscribedStickerIdsNotifier extends StateNotifier<List<String>> {
  final StickerMarketService _service;

  SubscribedStickerIdsNotifier(this._service)
      : super(_service.getSubscribedGroupIds());

  Future<void> subscribe(String groupId) async {
    await _service.subscribe(groupId);
    state = _service.getSubscribedGroupIds();
  }

  Future<void> unsubscribe(String groupId) async {
    await _service.unsubscribe(groupId);
    state = _service.getSubscribedGroupIds();
  }

  bool isSubscribed(String groupId) => state.contains(groupId);
}

/// 最近使用的表情包（响应式）
final recentStickersProvider =
    StateNotifierProvider<RecentStickersNotifier, List<StickerItem>>((ref) {
  final service = ref.watch(stickerMarketServiceProvider);
  return RecentStickersNotifier(service);
});

class RecentStickersNotifier extends StateNotifier<List<StickerItem>> {
  final StickerMarketService _service;

  RecentStickersNotifier(this._service) : super(_service.getRecentStickers());

  Future<void> add(StickerItem sticker) async {
    await _service.addRecentSticker(sticker);
    state = _service.getRecentStickers();
  }
}
