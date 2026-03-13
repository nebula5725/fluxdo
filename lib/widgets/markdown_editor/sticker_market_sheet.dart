import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sticker.dart';
import '../../providers/sticker_provider.dart';
import '../../services/discourse_cache_manager.dart';
import '../common/loading_spinner.dart';

/// 表情包市场浏览面板 (Bottom Sheet)
///
/// 展示市场中所有可用的表情包分组，用户可以添加/移除。
class StickerMarketSheet extends ConsumerWidget {
  const StickerMarketSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final groupsAsync = ref.watch(stickerGroupsProvider);
    final subscribedIds = ref.watch(subscribedStickerIdsProvider);

    return Container(
      height: mediaQuery.size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部标题栏
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                // 拖拽条
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '表情包市场',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('完成'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: (() {
              final groups = groupsAsync.value;
              if (groups != null) {
                return _buildGroupList(context, ref, groups, subscribedIds);
              }
              return groupsAsync.when(
                data: (groups) =>
                    _buildGroupList(context, ref, groups, subscribedIds),
                loading: () => const Center(child: LoadingSpinner()),
                error: (err, stack) => _buildError(context, ref),
              );
            })(),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('加载市场失败', style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(stickerGroupsProvider),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList(
    BuildContext context,
    WidgetRef ref,
    List<StickerGroup> groups,
    List<String> subscribedIds,
  ) {
    if (groups.isEmpty) {
      return Center(
        child: Text(
          '暂无可用的表情包',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final isSubscribed = subscribedIds.contains(group.id);
        return _StickerGroupTile(
          group: group,
          isSubscribed: isSubscribed,
          onToggle: () async {
            final notifier = ref.read(subscribedStickerIdsProvider.notifier);
            if (isSubscribed) {
              await notifier.unsubscribe(group.id);
            } else {
              await notifier.subscribe(group.id);
            }
          },
        );
      },
    );
  }
}

/// 市场中的分组列表项
class _StickerGroupTile extends StatelessWidget {
  final StickerGroup group;
  final bool isSubscribed;
  final VoidCallback onToggle;

  const _StickerGroupTile({
    required this.group,
    required this.isSubscribed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: _buildIcon(theme),
      title: Text(group.name),
      subtitle: Text(
        '${group.emojiCount} 个表情',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSubscribed
          ? FilledButton.tonalIcon(
              onPressed: onToggle,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('已添加'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onToggle,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('添加'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    final icon = group.icon;

    if (icon.startsWith('http://') || icon.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: icon,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          cacheManager: ExternalImageCacheManager(),
          errorWidget: (_, _, _) => _buildFallbackIcon(theme),
        ),
      );
    }

    if (icon.isNotEmpty) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
      );
    }

    return _buildFallbackIcon(theme);
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          group.name.isNotEmpty ? group.name[0] : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
