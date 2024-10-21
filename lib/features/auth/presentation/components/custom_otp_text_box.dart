import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/common/components/custom_text_box.dart';

class CustomOtpTextBox extends StatelessWidget {
  const CustomOtpTextBox({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextBox(
      height: 64.0,
      width: 68.0,
      controller: controller,
      onChanged: (value) {
        if (value.length == 1) {
          FocusScope.of(context).nextFocus();
        }
      },
      fontSize: 32.0,
      textAlign: TextAlign.center,
      textInputType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(1),
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
