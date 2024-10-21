import 'package:flutter/material.dart';
import 'custom_icon_button.dart';

class ReusablePopupMenuContainer extends StatefulWidget {
  const ReusablePopupMenuContainer({
    super.key,
    this.tooltip,
    required this.child,
    required this.icon,
    this.isOutlined = true,
    this.width,
    this.height,
  });

  final String? tooltip;  // Tooltip text shown when hovering over the button
  final IconData icon;  // The icon displayed on the button
  final bool isOutlined;  // Whether the button has an outline
  final Widget child;  // The content of the popup menu
  final double? width;  // Optional width of the popup menu
  final double? height;  // Optional height of the popup menu

  @override
  State<ReusablePopupMenuContainer> createState() =>
      _ReusablePopupMenuContainerState();
}

class _ReusablePopupMenuContainerState extends State<ReusablePopupMenuContainer> {
  final LayerLink _layerLink = LayerLink();  // Links the target and follower for precise positioning
  OverlayEntry? _overlayEntry;  // Manages the overlay that displays the popup menu

  void _showMenu(BuildContext context) {
    final overlay = Overlay.of(context);  // Accesses the overlay layer of the application
    final renderBox = context.findRenderObject() as RenderBox;  // Gets the size and position of the target widget
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);  // Converts local coordinates to global (screen) coordinates

    final screenSize = MediaQuery.of(context).size;  // Gets the screen size
    final menuWidth = widget.width ?? 200.0;  // Sets default width if none is provided
    final menuHeight = widget.height ?? 300.0;  // Sets default height if none is provided

    // Determine available space
    double availableHeightAbove = offset.dy;
    double availableHeightBelow = screenSize.height - offset.dy - size.height;
    double availableWidthLeft = offset.dx;
    double availableWidthRight = screenSize.width - offset.dx - size.width;

    // Default position
    double verticalOffset = 40;  // Default offset below the button
    double horizontalOffset = 0;  // Default to no horizontal offset

    // Adjust position if necessary
    if (availableHeightBelow < menuHeight &&
        availableHeightAbove > menuHeight) {
      // Not enough space below, place it above the button
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

    _overlayEntry?.remove();  // Removes any existing overlay entry

    // Creates the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,  // Makes the whole screen clickable to dismiss the menu
        onTap: () {
          _overlayEntry?.remove();  // Removes the overlay when the user taps outside the menu
          _overlayEntry = null;
        },
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,  // Links the follower with the target widget
              showWhenUnlinked: false,  // Only shows the follower when linked to the target
              offset: Offset(horizontalOffset, verticalOffset),  // Positions the menu relative to the target
              child: Material(
                elevation: 8.0,  // Adds shadow to the menu for a raised effect
                borderRadius: BorderRadius.circular(10.0),  // Rounds the corners of the menu
                child: widget.child,  // The content of the popup menu
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);  // Inserts the overlay entry into the overlay
  }

  @override
  void dispose() {
    _overlayEntry?.remove();  // Ensures the overlay is removed when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,  // Links this target to the follower (popup menu)
      child: CustomIconButton(
        tooltip: widget.tooltip,  // Displays a tooltip when the user hovers over the button
        onTap: () => _showMenu(context),  // Shows the popup menu when the button is tapped
        icon: widget.icon,  // The icon displayed on the button
        isOutlined: widget.isOutlined,  // Determines whether the button is outlined
      ),
    );
  }
}
