import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';

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
      height: 50.0,
      placeHolderText: placeHolderText ?? 'password',
      isObscured: visibilityState == true ? false : true,
      prefixIcon: Icons.lock,
      onSuffixIconPressed: () =>
          context.read<CustomAuthPasswordTextBoxBloc>().add(ToggleVisibility()),
      suffixIcon: visibilityState == true ? Icons.visibility : Icons.visibility_off,
      validator: validator ?? ValidationBuilder(requiredMessage: '$placeHolderText is required').minLength(8, '$placeHolderText must be at least 8 characters long').maxLength(50, '$placeHolderText must be at most 50 characters long').build(),
    );
  }
}

// override the validator