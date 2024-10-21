import 'package:flutter/cupertino.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/custom_text_box.dart';

class CustomEmailTextBox extends StatelessWidget {
  const CustomEmailTextBox({super.key, this.controller,});

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextBox(
      controller: controller,
      height: 80.0,
      placeHolderText: 'email',
      prefixIcon: HugeIcons.strokeRoundedMail02,
      validator: ValidationBuilder(requiredMessage: 'email is required').email('not a valid email address').maxLength(50, 'email must be at most 50 characters long').build(),
    );
  }
}
