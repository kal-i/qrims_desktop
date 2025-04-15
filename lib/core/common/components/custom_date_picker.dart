import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';
import 'custom_form_text_field.dart';
import '../../utils/date_formatter.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    this.onDateChanged,
    required this.label,
    required this.dateController,
    this.firstDate,
    this.lastDate,
    this.fillColor,
    this.enabled = true,
  });

  final ValueChanged<DateTime?>? onDateChanged;
  final String label;
  final TextEditingController dateController;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Color? fillColor;
  final bool enabled;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  Future<void> _selectDate(BuildContext context) async {
    if (!widget.enabled) return;

    DateTime now = DateTime.now();
    DateTime initialDate = widget.dateController.text.isNotEmpty
        ? DateTime.parse(widget.dateController.text)
        : now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2101),
    );

    if (pickedDate != null) {
      widget.dateController.text = dateFormatter(pickedDate);
      widget.onDateChanged?.call(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormTextField(
      fillColor: widget.fillColor ??
          (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightBackground
              : AppColor.darkBackground),
      controller: widget.dateController,
      label: widget.label,
      suffixIcon: HugeIcons.strokeRoundedCalendar03,
      onTap: widget.enabled ? () => _selectDate(context) : null,
      enabled: widget.enabled,
      validator: ValidationBuilder()
          .regExp(RegExp(r'^\d{4}-\d{2}-\d{2}$'), 'Invalid date format')
          .build(),
    );
  }
}
