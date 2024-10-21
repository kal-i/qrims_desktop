import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hugeicons/hugeicons.dart';

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
  });

  final ValueChanged<DateTime?>? onDateChanged;
  final String label;
  final TextEditingController dateController;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = widget.dateController.text.isNotEmpty ? DateTime.parse(widget.dateController.text) : now;

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
      controller: widget.dateController,
      label: widget.label,
      suffixIcon: HugeIcons.strokeRoundedCalendar03,
      onTap: () => _selectDate(context),
      validator: ValidationBuilder()
          .regExp(RegExp(r'^\d{4}-\d{2}-\d{2}$'), 'Invalid date format')
          .build(),
    );
  }
}
