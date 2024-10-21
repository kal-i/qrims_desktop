import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hugeicons/hugeicons.dart';

import 'bloc/custom_auth_password_text_box_bloc.dart';
import '../../../../../core/common/components/custom_text_box.dart';

class CustomAuthPasswordTextBox extends StatelessWidget {
  const CustomAuthPasswordTextBox({
    super.key,
    this.controller,
    this.placeHolderText,
    this.validator,
  });

  final TextEditingController? controller;
  final String? placeHolderText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final visibilityState =
        context.watch<CustomAuthPasswordTextBoxBloc>().state;

    return CustomTextBox(
      controller: controller,
      height: 80.0,
      placeHolderText: placeHolderText ?? 'password',
      isObscured: visibilityState == true ? false : true,
      prefixIcon: HugeIcons.strokeRoundedLockPassword,
      onSuffixIconPressed: () =>
          context.read<CustomAuthPasswordTextBoxBloc>().add(ToggleVisibility()),
      suffixIcon: visibilityState == true ? FluentIcons.eye_20_regular : FluentIcons.eye_off_20_regular,
      validator: validator ?? ValidationBuilder(requiredMessage: '$placeHolderText is required').minLength(8, '$placeHolderText must be at least 8 characters long').maxLength(50, '$placeHolderText must be at most 50 characters long').build(),
    );
  }
}

// override the validator