import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';

class CustomTextBox extends StatelessWidget {
  const CustomTextBox({
    super.key,
    this.height = 30.0,
    this.width = 100.0,
    this.onChanged,
    this.controller,
    this.fontSize,
    this.placeHolderText,
    this.prefixImagePath,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.isObscured = false,
    this.textAlign = TextAlign.start,
    this.textInputType,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
  });

  final double width;
  final double height;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final double? fontSize;
  final String? placeHolderText;
  final String? prefixImagePath;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool isObscured;
  final TextAlign textAlign;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeBloc>().state;

    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        onChanged: onChanged,
        controller: controller,
        cursorColor: AppColor.accent,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,
              // currentTheme == AppTheme.light
              //     ? AppColor.lightOutlineBorder
              //     : AppColor.darkOutlineBorder,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColor.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColor.accent,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColor.error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: currentTheme == AppTheme.light
              ? AppColor.lightBackground
              : AppColor.darkBackground,
          hintText: placeHolderText,
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.darkPlaceHolderText,
              ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  size: 18.0,
                )
              : prefixImagePath != null
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        prefixImagePath!,
                        height: 20.0,
                      ),
                    )
                  : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onSuffixIconPressed,
                  icon: Icon(
                    suffixIcon,
                    size: 20.0,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: height * 0.3, // Adjusted padding to match height
            horizontal: 10.0,
          ),
        ),
        obscureText: isObscured,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: currentTheme == AppTheme.light
                  ? AppColor.darkPrimary
                  : AppColor.lightPrimary,
              fontSize: fontSize,
            ),
        textAlign: textAlign,
        keyboardType: textInputType,
        inputFormatters: inputFormatters,
        validator: validator ?? ValidationBuilder(requiredMessage: '$placeHolderText is required').build(),
      ),
    );
  }
}
