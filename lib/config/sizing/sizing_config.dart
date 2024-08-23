import 'package:flutter/cupertino.dart';

class SizingConfig {
  static late double _screenWidth;
  static late double _screenHeight;
  static double _blockSizeHorizontal = 0; // left & right
  static double _blockSizeVertical = 0; // top & bottom

  static late double textMultiplier;
  static late double imageMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;

  void init(BoxConstraints constraints) {
    _screenWidth = constraints.maxWidth;
    _screenHeight = constraints.maxHeight;

    /// Divide the screen into blocks
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    /// Scale with the screen's height
    textMultiplier = _blockSizeVertical;
    imageMultiplier = _blockSizeHorizontal;
    heightMultiplier = _blockSizeVertical;
    widthMultiplier = _blockSizeHorizontal;

    print('Screen width: $_screenWidth');
    print('Screen height: $_screenHeight');
    print('text: $textMultiplier');
    print('image: $imageMultiplier');
    print('height: $heightMultiplier');
    print('width: $widthMultiplier');
  }
}