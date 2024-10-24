import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    super.key,
    required this.onChanged,
    this.value,
    this.label,
    this.items,
    this.onMenuStateChange,
    this.validator,
    this.valueToStringConverter,
  });

  final void Function(T?)? onChanged;
  final T? value;
  final String? label;
  final List<DropdownMenuItem<T>>? items;
  final void Function(bool)? onMenuStateChange;
  final String? Function(T?)? validator;
  final String Function(T?)? valueToStringConverter;

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
          const SizedBox(
            height: 10.0,
          ),
        DropdownButtonFormField2<T>(
          isExpanded: true,
          onChanged: onChanged,
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.watch<ThemeBloc>().state == AppTheme.light
                ? AppColor.lightBackground
                : AppColor.darkBackground,
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppColor.error,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
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
              borderRadius: BorderRadius.circular(5.0),
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
          items:
              items, // items.map((item) => DropdownMenuItem(value: item, child: Text(readableEnumConverter(item), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12.0, fontWeight: FontWeight.w500,),),),).toList(),
          validator: validator ??
              (T? value) {
                final String valueAsString = valueToStringConverter != null
                    ? valueToStringConverter!(value)
                    : value.toString();
                return ValidationBuilder(requiredMessage: '$label is required')
                    .build()(valueAsString);
              },
        ),
      ],
    );
  }
}
