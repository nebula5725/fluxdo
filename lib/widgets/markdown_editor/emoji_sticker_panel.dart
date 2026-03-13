import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../models/emoji.dart';
import 'emoji_picker.dart';
import 'sticker_picker.dart';

/// 面板模式
enum PanelMode { emoji, sticker }

/// 悬浮 Tab 的高度（含上下内边距），用于给内容区预留底部空间
const double floatingTabHeight = 52;

/// 表情/表情包面板容器
///
/// 通过底部悬浮 Tab 切换"内置表情"和"表情包"两种模式。
/// 使用 Stack 布局，内容区在底层，悬浮 Tab 在顶层。
class EmojiStickerPanel extends StatefulWidget {
  /// 选中内置表情的回调
  final ValueChanged<Emoji> onEmojiSelected;

  /// 选中表情包的回调，参数为 Markdown 图片文本
  final ValueChanged<String> onStickerSelected;

  const EmojiStickerPanel({
    super.key,
    required this.onEmojiSelected,
    required this.onStickerSelected,
  });

  @override
  State<EmojiStickerPanel> createState() => _EmojiStickerPanelState();
}

class _EmojiStickerPanelState extends State<EmojiStickerPanel> {
  PanelMode _mode = PanelMode.emoji;

  /// 悬浮 Tab 是否可见
  bool _tabVisible = true;

  void _onUserScroll(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) {
      // 手指向上（内容向下滚）→ 隐藏 Tab
      if (_tabVisible) setState(() => _tabVisible = false);
    } else if (direction == ScrollDirection.forward) {
      // 手指向下（内容向上滚）→ 显示 Tab
      if (!_tabVisible) setState(() => _tabVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 内容区：用 NotificationListener 统一捕获滚动方向
        NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            _onUserScroll(notification.direction);
            return false;
          },
          child: _mode == PanelMode.emoji
              ? EmojiPicker(
                  onEmojiSelected: widget.onEmojiSelected,
                  bottomPadding: floatingTabHeight,
                )
              : StickerPicker(
                  onStickerSelected: widget.onStickerSelected,
                ),
        ),

        // 悬浮切换 Tab
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: _tabVisible ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _buildFloatingTab(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingTab(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabButton(
            theme: theme,
            icon: Icons.emoji_emotions_outlined,
            selectedIcon: Icons.emoji_emotions,
            label: '表情',
            selected: _mode == PanelMode.emoji,
            onTap: () {
              if (_mode != PanelMode.emoji) {
                setState(() {
                  _mode = PanelMode.emoji;
                  _tabVisible = true;
                });
              }
            },
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            theme: theme,
            icon: Icons.collections_outlined,
            selectedIcon: Icons.collections,
            label: '表情包',
            selected: _mode == PanelMode.sticker,
            onTap: () {
              if (_mode != PanelMode.sticker) {
                setState(() {
                  _mode = PanelMode.sticker;
                  _tabVisible = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required ThemeData theme,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
