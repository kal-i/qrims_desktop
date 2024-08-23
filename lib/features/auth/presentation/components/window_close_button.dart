import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowCloseButton extends StatelessWidget {
  const WindowCloseButton({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 40.0, // increase width if necessary
      height: 40.0,
      child: WindowCaptionButton.close(
        brightness: Theme.of(context).brightness,
        onPressed: () => windowManager.close(),
      ),
    );
  }
}
