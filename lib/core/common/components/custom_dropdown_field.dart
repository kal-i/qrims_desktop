import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

// todo: fix the hint text alignment
class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.onChanged,
    this.value,
    this.label,
    this.placeholderText,
    this.items,
    this.onMenuStateChange,
    this.validator,
    this.valueToStringConverter,
    this.fillColor,
    this.hasValidation = true,
  });

  final void Function(T?)? onChanged;
  final T? value;
  final String? label;
  final String? placeholderText;
  final List<DropdownMenuItem<T>>? items;
  final void Function(bool)? onMenuStateChange;
  final String? Function(T?)? validator;
  final String Function(T?)? valueToStringConverter;
  final Color? fillColor;
  final bool hasValidation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty)
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        DropdownButtonFormField2<T>(
          hint: Text(
            placeholderText ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColor.darkPlaceHolderText,
                ),
          ),
          isExpanded: true,
          onChanged: onChanged,
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ??
                (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightBackground
                    : AppColor.darkBackground),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              // borderSide: BorderSide(
              //   color: Theme.of(context).dividerColor,
              //   width: 1.5,
              // ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColor.error,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColor.accent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColor.error,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onMenuStateChange: onMenuStateChange,
          iconStyleData: const IconStyleData(
            icon: Icon(
              HugeIcons.strokeRoundedArrowDown01,
              //color: AppColor.accent,
            ),
            iconSize: 20.0,
          ),
          buttonStyleData: ButtonStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.only(left: 8.0),
          ),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
          items: items,
          validator: hasValidation
              ? validator ??
                  (T? value) {
                    if (value == null) {
                      return '$label is required';
                    }
                    final String valueAsString = valueToStringConverter != null
                        ? valueToStringConverter!(value)
                        : value.toString();
                    return ValidationBuilder(
                            requiredMessage: '$label is required')
                        .build()(valueAsString);
                  }
              : null,
        ),
      ],
    );
  }
}
