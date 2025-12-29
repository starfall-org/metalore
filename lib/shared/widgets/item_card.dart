import 'package:flutter/material.dart';

import '../../app/translate/tl.dart';

enum ItemCardLayout { grid, list }

/// Thẻ hiển thị tài nguyên dạng lưới (Grid) hoặc danh sách (List) theo Material 3.
/// Dùng chung cho providers/agents/tts/mcp.
/// Có hoạt ảnh chuyển đổi giữa 2 trạng thái và grid layout đảm bảo tỉ lệ 1:1.
class ItemCard extends StatefulWidget {
  final Widget icon;
  final Color? iconColor;
  final String title;
  final Widget? subtitleWidget;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final ItemCardLayout layout;
  final Duration animationDuration;
  final Curve animationCurve;

  const ItemCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.leading,
    this.trailing,
    this.iconColor,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.elevation = 1,
    this.layout = ItemCardLayout.grid,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layout != widget.layout) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _ = widget.iconColor ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCard(context, theme),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    Widget cardBody = _buildCardBody(theme);

    // Đảm bảo grid layout có tỉ lệ 1:1 (4 cạnh bằng nhau)
    if (widget.layout == ItemCardLayout.grid) {
      cardBody = AspectRatio(aspectRatio: 1.0, child: cardBody);
    }

    return Card(
      elevation: widget.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.layout == ItemCardLayout.grid
          ? InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: widget.onTap,
              child: cardBody,
            )
          : cardBody,
    );
  }

  Widget _buildCardBody(ThemeData theme) {
    Widget buildSubtitle() {
      if (widget.subtitleWidget != null) return widget.subtitleWidget!;
      if (widget.subtitle != null) {
        return Text(
          widget.subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          maxLines: widget.layout == ItemCardLayout.grid ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        );
      }
      return const SizedBox.shrink();
    }

    if (widget.layout == ItemCardLayout.grid) {
      Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon với kích thước responsive
          Flexible(flex: 2, child: Center(child: widget.icon)),
          const SizedBox(height: 8),
          // Nội dung text
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null ||
                    widget.subtitleWidget != null) ...[
                  const SizedBox(height: 4),
                  buildSubtitle(),
                ],
              ],
            ),
          ),
        ],
      );

      // Nếu có trailing widget hoặc menu hành động
      if (widget.leading != null ||
          widget.trailing != null ||
          widget.onView != null ||
          widget.onEdit != null ||
          widget.onDelete != null) {
        content = Stack(
          children: [
            if (widget.leading != null)
              Positioned(top: 0, left: 0, child: widget.leading!),
            Positioned.fill(child: content),
            Positioned(
              top: 0,
              right: 0,
              child:
                  widget.trailing ??
                  _ActionMenu(
                    onView: widget.onView,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                  ),
            ),
          ],
        );
      }
      return Padding(padding: widget.padding, child: content);
    } else {
      // List layout
      return ListTile(
        contentPadding: widget.padding,
        leading: widget.icon,
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: (widget.subtitle != null || widget.subtitleWidget != null)
            ? buildSubtitle()
            : null,
        trailing:
            widget.trailing ??
            (widget.onView != null ||
                    widget.onEdit != null ||
                    widget.onDelete != null
                ? _ActionMenu(
                    onView: widget.onView,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                  )
                : null),
        onTap: widget.onTap,
      );
    }
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionMenu({this.onView, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case _MenuAction.view:
            onView?.call();
            break;
          case _MenuAction.edit:
            onEdit?.call();
            break;
          case _MenuAction.delete:
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_MenuAction>>[];
        if (onView != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.view,
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(tl('agents.view')),
                ],
              ),
            ),
          );
        }
        if (onEdit != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.edit,
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(tl('agents.edit')),
                ],
              ),
            ),
          );
        }
        if (onDelete != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.delete,
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(tl('agents.delete')),
                ],
              ),
            ),
          );
        }
        return items;
      },
    );
  }
}

enum _MenuAction { view, edit, delete }

/// Nút action trên AppBar để chuyển đổi giữa List và Grid theo Material Icons.
/// Có hoạt ảnh chuyển đổi mượt mà giữa các icon.
class ViewToggleAction extends StatefulWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;
  final String? listTooltip;
  final String? gridTooltip;
  final Duration animationDuration;

  const ViewToggleAction({
    super.key,
    required this.isGrid,
    required this.onChanged,
    this.listTooltip = 'List view',
    this.gridTooltip = 'Grid view',
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<ViewToggleAction> createState() => _ViewToggleActionState();
}

class _ViewToggleActionState extends State<ViewToggleAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ViewToggleAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGrid != widget.isGrid) {
      _animateTransition();
    }
  }

  void _animateTransition() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return IconButton(
          tooltip: widget.isGrid ? widget.listTooltip : widget.gridTooltip,
          icon: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159 * 2,
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                widget.isGrid ? Icons.view_list : Icons.grid_view_outlined,
                key: ValueKey(widget.isGrid),
              ),
            ),
          ),
          onPressed: () => widget.onChanged(!widget.isGrid),
        );
      },
    );
  }
}

/// Nút action trên AppBar để thêm tài nguyên theo Material Icons.
class AddAction extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const AddAction({super.key, required this.onPressed, this.tooltip = 'Add'});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.add),
      onPressed: onPressed,
    );
  }
}
