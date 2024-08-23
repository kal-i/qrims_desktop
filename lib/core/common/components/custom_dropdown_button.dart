import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';
import '../../utils/readable_enum_converter.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  const CustomDropdownButton({
    super.key,
    required this.onChanged,
    this.value,
    required this.label,
    this.items,
    this.onMenuStateChange,
    this.validator,
    this.valueToStringConverter,
  });

  final void Function(T?)? onChanged;
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>>? items;
  final void Function(bool)? onMenuStateChange;
  final String? Function(T?)? validator;
  final String Function(T?)? valueToStringConverter;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      onChanged: onChanged,
      value: value,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.watch<ThemeBloc>().state == AppTheme.light
                ? AppColor.lightOutlineBorder
                : AppColor.darkOutlineBorder,
            width: 1.5,
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
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColor.accent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        label: Text(label),
        labelStyle: Theme.of(context).textTheme.bodySmall,
      ),
      onMenuStateChange: onMenuStateChange,
      // buttonStyleData: const ButtonStyleData(
      //   padding: EdgeInsets.only(right: 8.0),
      // ),
      // iconStyleData: const IconStyleData(
      //   icon: Icon(
      //     Icons.arrow_drop_down_outlined,
      //     color: AppColor.accent,
      //   ),
      //   iconSize: 20.0,
      // ),
      // dropdownStyleData: DropdownStyleData(
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10.0),
      //   ),
      // ),
      // menuItemStyleData: const MenuItemStyleData(
      //   padding: EdgeInsets.symmetric(horizontal: 16.0),
      // ),
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
    );
  }
}
