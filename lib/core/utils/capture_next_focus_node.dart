import 'package:flutter/widgets.dart';

void captureNextFocusNode(BuildContext context, FocusNode current, FocusNode next) {
  current.unfocus();
  FocusScope.of(context).requestFocus(next);
}