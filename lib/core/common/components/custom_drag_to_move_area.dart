import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomDragToMoveArea extends StatelessWidget {
  const CustomDragToMoveArea({
    super.key,
    required this.child,
    this.enableDoubleTap = false,  // Add a flag for double-tap functionality
  });

  final Widget child;
  final bool enableDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: enableDoubleTap ? () async {
        bool isMaximized = await windowManager.isMaximized();
        if (!isMaximized) {
          windowManager.maximize();
        } else {
          windowManager.unmaximize();
        }
      } : null,  // Set to null if double-tap is disabled
      child: child,
    );
  }
}
