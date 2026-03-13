import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sticker.dart';
import '../../providers/sticker_provider.dart';
import '../../services/discourse_cache_manager.dart';
import '../common/loading_spinner.dart';
import 'emoji_sticker_panel.dart' show floatingTabHeight;
import 'sticker_market_sheet.dart';

/// 表情包选择器
///
/// 单个滚动列表展示所有已订阅分组（带文字标题），
/// 顶部图标 Tab 作为锚点快速跳转。
class StickerPicker extends ConsumerStatefulWidget {
  final ValueChanged<String> onStickerSelected;

  const StickerPicker({
    super.key,
    required this.onStickerSelected,
  });

  @override
  ConsumerState<StickerPicker> createState() => _StickerPickerState();
}

class _StickerPickerState extends ConsumerState<StickerPicker>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();
  final GlobalKey _contentAreaKey = GlobalKey();
  List<GlobalKey> _groupKeys = [];
  int _activeGroupIndex = 0;
  bool _isProgrammaticScroll = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _openMarket() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StickerMarketSheet(),
    );
  }

  void _onStickerTap(StickerItem sticker) {
    ref.read(recentStickersProvider.notifier).add(sticker);
    widget.onStickerSelected(sticker.toMarkdown());
  }

  // ==================== 滚动锚点 ====================

  void _onScroll() {
    if (_isProgrammaticScroll) return;
    _updateActiveGroup();
  }

  void _updateActiveGroup() {
    if (_groupKeys.isEmpty) return;
    final contentBox =
        _contentAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (contentBox == null || !contentBox.attached) return;
    final contentTop = contentBox.localToGlobal(Offset.zero).dy;

    int activeIndex = 0;
    for (int i = 0; i < _groupKeys.length; i++) {
      final ctx = _groupKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box == null || box is! RenderBox || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy <= contentTop + 20) {
        activeIndex = i;
      }
    }
    if (_activeGroupIndex != activeIndex) {
      setState(() => _activeGroupIndex = activeIndex);
      _ensureTabVisible(activeIndex);
    }
  }

  Future<void> _scrollToGroup(int index) async {
    if (index < 0 || index >= _groupKeys.length) return;
    final ctx = _groupKeys[index].currentContext;
    if (ctx == null) return;
    _isProgrammaticScroll = true;
    setState(() => _activeGroupIndex = index);
    _ensureTabVisible(index);
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _isProgrammaticScroll = false;
  }

  void _ensureTabVisible(int index) {
    if (!_tabScrollController.hasClients) return;
    const tabWidth = 40.0;
    final target = index * tabWidth -
        _tabScrollController.position.viewportDimension / 2 +
        tabWidth / 2;
    _tabScrollController.animateTo(
      target.clamp(0.0, _tabScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  // ==================== 构建 ====================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final subscribedIds = ref.watch(subscribedStickerIdsProvider);
    final recentStickers = ref.watch(recentStickersProvider);
    final groupsAsync = ref.watch(stickerGroupsProvider);

    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: (() {
          if (subscribedIds.isEmpty) return _buildEmptyState();
          final allGroups = groupsAsync.value;
          if (allGroups != null) {
            return _buildContent(
              _filterSubscribed(allGroups, subscribedIds),
              recentStickers,
            );
          }
          return groupsAsync.when(
            data: (groups) => _buildContent(
              _filterSubscribed(groups, subscribedIds),
              recentStickers,
            ),
            loading: () => const Center(child: LoadingSpinner()),
            error: (err, stack) => _buildError(),
          );
        })(),
      ),
    );
  }

  List<StickerGroup> _filterSubscribed(
    List<StickerGroup> allGroups,
    List<String> subscribedIds,
  ) {
    final groupMap = {for (final g in allGroups) g.id: g};
    return subscribedIds
        .where((id) => groupMap.containsKey(id))
        .map((id) => groupMap[id]!)
        .toList();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.collections_outlined,
              size: 48,
              color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('还没有表情包',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _openMarket,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('从市场添加'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('加载表情包失败',
              style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(stickerGroupsProvider),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    List<StickerGroup> groups,
    List<StickerItem> recentStickers,
  ) {
    if (groups.isEmpty) return _buildEmptyState();

    final hasRecent = recentStickers.isNotEmpty;
    final totalGroups = (hasRecent ? 1 : 0) + groups.length;

    while (_groupKeys.length < totalGroups) {
      _groupKeys.add(GlobalKey());
    }
    if (_groupKeys.length > totalGroups) {
      _groupKeys = _groupKeys.sublist(0, totalGroups);
    }

    return Column(
      children: [
        _buildTabBar(groups, hasRecent),
        Expanded(
          key: _contentAreaKey,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: _buildSlivers(groups, hasRecent, recentStickers),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(List<StickerGroup> groups, bool hasRecent) {
    final theme = Theme.of(context);
    final totalTabs = (hasRecent ? 1 : 0) + groups.length;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: totalTabs,
              itemBuilder: (context, index) {
                final isActive = _activeGroupIndex == index;
                Widget icon;
                if (hasRecent && index == 0) {
                  icon = Icon(
                    Icons.access_time,
                    size: 20,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  );
                } else {
                  final group = groups[hasRecent ? index - 1 : index];
                  icon = _buildGroupTabIcon(group);
                }
                return GestureDetector(
                  onTap: () => _scrollToGroup(index),
                  child: Container(
                    width: 36,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: icon),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
            height: 20, width: 1, color: theme.colorScheme.outlineVariant),
        IconButton(
          icon: Icon(Icons.add_circle_outline,
              size: 20, color: theme.colorScheme.primary),
          onPressed: _openMarket,
          tooltip: '添加表情包',
        ),
      ],
    );
  }

  Widget _buildGroupTabIcon(StickerGroup group) {
    final icon = group.icon;
    if (icon.startsWith('http://') || icon.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: icon,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          cacheManager: ExternalImageCacheManager(),
          errorWidget: (_, _, _) => _buildFallbackIcon(group.name),
        ),
      );
    }
    if (icon.isNotEmpty) {
      return Text(icon, style: const TextStyle(fontSize: 18));
    }
    return _buildFallbackIcon(group.name);
  }

  Widget _buildFallbackIcon(String name) {
    return Text(
      name.isNotEmpty ? name[0] : '?',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  List<Widget> _buildSlivers(
    List<StickerGroup> groups,
    bool hasRecent,
    List<StickerItem> recentStickers,
  ) {
    final slivers = <Widget>[];
    int keyIndex = 0;

    if (hasRecent) {
      slivers.add(SliverToBoxAdapter(
        child: _buildSectionHeader('常用', _groupKeys[keyIndex]),
      ));
      slivers.add(_buildStickerSliverGrid(recentStickers));
      keyIndex++;
    }

    for (final group in groups) {
      slivers.add(SliverToBoxAdapter(
        child: _buildSectionHeader(group.name, _groupKeys[keyIndex]),
      ));
      slivers.add(_StickerGroupSliverContent(
        groupId: group.id,
        onStickerTap: _onStickerTap,
      ));
      keyIndex++;
    }

    // 底部留白
    slivers.add(SliverToBoxAdapter(
      child: SizedBox(height: floatingTabHeight),
    ));

    return slivers;
  }

  Widget _buildSectionHeader(String title, GlobalKey key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildStickerSliverGrid(List<StickerItem> stickers) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => _StickerItemWidget(
            sticker: stickers[index],
            onTap: () => _onStickerTap(stickers[index]),
          ),
          childCount: stickers.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
      ),
    );
  }
}

/// 单个分组的 Sliver 内容（懒加载）
class _StickerGroupSliverContent extends ConsumerWidget {
  final String groupId;
  final ValueChanged<StickerItem> onStickerTap;

  const _StickerGroupSliverContent({
    required this.groupId,
    required this.onStickerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(stickerGroupDetailProvider(groupId));
    final theme = Theme.of(context);

    final detail = detailAsync.value;
    if (detail != null) return _buildGrid(detail);

    return detailAsync.when(
      data: _buildGrid,
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(height: 80, child: Center(child: LoadingSpinner())),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: SizedBox(
          height: 80,
          child: Center(
            child: TextButton(
              onPressed: () =>
                  ref.invalidate(stickerGroupDetailProvider(groupId)),
              child: Text('加载失败，点击重试',
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(StickerGroupDetail detail) {
    if (detail.emojis.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 80, child: Center(child: Text('该分组暂无表情包'))),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => _StickerItemWidget(
            sticker: detail.emojis[index],
            onTap: () => onStickerTap(detail.emojis[index]),
          ),
          childCount: detail.emojis.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 80,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
      ),
    );
  }
}

/// 单个表情包图片
class _StickerItemWidget extends StatelessWidget {
  final StickerItem sticker;
  final VoidCallback onTap;

  const _StickerItemWidget({
    required this.sticker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message: sticker.name,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CachedNetworkImage(
            imageUrl: sticker.url,
            cacheManager: ExternalImageCacheManager(),
            fit: BoxFit.contain,
            placeholder: (_, _) => const SizedBox.shrink(),
            errorWidget: (_, _, _) => Icon(
              Icons.broken_image_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
