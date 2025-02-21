import 'package:flutter/services.dart';

class KeyboardService {
  static final KeyboardService _instance = KeyboardService._internal();

  factory KeyboardService() => _instance;

  KeyboardService._internal() {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    try {
      if (event is KeyDownEvent || event is KeyUpEvent) {
        // Ignore problematic toggle keys
        if (_isProblematicKey(event.logicalKey)) {
          return false;
        }

        print("Key Pressed: ${event.logicalKey.debugName}");
      }
    } catch (e) {
      print("Keyboard event error: $e");
    }
    return false;
  }

  bool _isProblematicKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.numLock ||
        key == LogicalKeyboardKey.capsLock ||
        key == LogicalKeyboardKey.scrollLock;
  }

  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
  }
}
