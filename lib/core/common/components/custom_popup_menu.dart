import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';
import 'custom_icon_button.dart';

enum MenuItemType {
  normal,
  header,
}

class CustomMenu extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(String) onItemSelected;
  final String? initialSelectedItem;
  final double? width;
  final double? height;

  const CustomMenu({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.initialSelectedItem,
    this.width,
    this.height,
  });

  @override
  _CustomMenuState createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  String? _selectedItem;
  String? _hoveredItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialSelectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.height ?? 300.0,
          maxWidth: widget.width ?? 200.0,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 0.8),
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final type = item['type'] as MenuItemType?;
            final text = item['text'] as String;
            final icon = item['icon'] as IconData?;
            final isHovered = _hoveredItem == text;
            final isSelected = _selectedItem == text;

            if (type == MenuItemType.header) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }

            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  _hoveredItem = text;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoveredItem = null;
                });
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedItem = text;
                  });
                  widget.onItemSelected(text);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? Theme.of(context).dividerColor.withOpacity(0.6)
                        : isSelected
                            ? Theme.of(context).dividerColor.withOpacity(0.6)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      if (icon != null)
                        Icon(
                          icon,
                          color: isSelected ? Colors.blue : AppColor.icon,
                        ),
                      const SizedBox(width: 8.0),
                      Text(
                        text,
                        style: isSelected
                            ? Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                )
                            : Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w400,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomMenuButton extends StatefulWidget {
  const CustomMenuButton({
    super.key,
    this.child,
    this.icon,
    this.tooltip,
    required this.items,
    required this.onItemSelected,
    this.initialItemSelected,
    this.isOutlined = true,
    this.height,
    this.width,
  });

  final Widget? child;
  final IconData? icon;
  final String? tooltip;
  final List<Map<String, dynamic>> items;
  final Function(String) onItemSelected;
  final String? initialItemSelected;
  final bool isOutlined;
  final double? height;
  final double? width;

  @override
  _CustomMenuButtonState createState() => _CustomMenuButtonState();
}

class _CustomMenuButtonState extends State<CustomMenuButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showMenu(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenSize = MediaQuery.of(context).size;
    const menuWidth = 200.0;
    const menuHeight = 300.0;

    // Determine available space
    double availableHeightAbove = offset.dy;
    double availableHeightBelow = screenSize.height - offset.dy - size.height;
    double availableWidthLeft = offset.dx;
    double availableWidthRight = screenSize.width - offset.dx - size.width;

    // Default position
    double verticalOffset = size.height; // 40; // Offset below the button
    double horizontalOffset = 0; // Default to no horizontal offset

    // Adjust position if necessary
    if (availableHeightBelow < menuHeight &&
        availableHeightAbove > menuHeight) {
      // Not enough space below, place it above
      verticalOffset = -menuHeight;
    }

    if (availableWidthRight < menuWidth && availableWidthLeft > menuWidth) {
      // Not enough space on the right, place it to the left
      horizontalOffset = size.width - menuWidth;
    } else if (availableWidthRight < menuWidth &&
        availableWidthLeft < menuWidth) {
      // Not enough space on either side, center it on the screen
      horizontalOffset = (screenSize.width - menuWidth) / 2 - offset.dx;
    }

    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(horizontalOffset, verticalOffset),
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(10.0),
                child: CustomMenu(
                  items: widget.items,
                  onItemSelected: (item) {
                    widget.onItemSelected(item);
                    print('Selected item: $item');
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  },
                  initialSelectedItem: widget.initialItemSelected,
                  width: widget.width,
                  height: widget.height,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child != null
          ? GestureDetector(
              child: widget.child,
              onTap: () => _showMenu(context),
            )
          : CustomIconButton(
              tooltip: widget.tooltip,
              onTap: () => _showMenu(context),
              icon: widget.icon,
              isOutlined: widget.isOutlined,
            ),
    );
  }
}
