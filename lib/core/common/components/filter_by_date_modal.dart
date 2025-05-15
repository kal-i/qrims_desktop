import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'custom_date_picker.dart';
import 'custom_filled_button.dart';
import 'custom_outline_button.dart';
import 'base_modal.dart';
import '../../utils/date_formatter.dart';

class FilterByDateModal extends StatefulWidget {
  const FilterByDateModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.onApplyFilters,
    this.startDate,
    this.endDate,
  });

  final String title;
  final String? subtitle;
  final Function(
    DateTime? startDate,
    DateTime? endDate,
  ) onApplyFilters;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<FilterByDateModal> createState() => _FilterByDateModalState();
}

class _FilterByDateModalState extends State<FilterByDateModal> {
  late final ValueNotifier<DateTime> _pickedStartDate =
      ValueNotifier<DateTime>(widget.startDate ?? DateTime.now());
  late final ValueNotifier<DateTime> _pickedEndDate =
      ValueNotifier<DateTime>(widget.endDate ?? DateTime.now());

  @override
  void dispose() {
    _pickedStartDate.dispose();
    _pickedEndDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 400.0,
      headerTitle: widget.title,
      subtitle: widget.subtitle,
      content: _buildFilterContents(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildFilterContents() {
    return Column(
      children: [
        _buildStartDateSelection(),
        const SizedBox(
          height: 20.0,
        ),
        _buildEndDateSelection(),
      ],
    );
  }

  Widget _buildStartDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _pickedStartDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _pickedStartDate.value = date;
            }
          },
          label: 'Start Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildEndDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _pickedEndDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _pickedEndDate.value = date;
            }
          },
          label: 'End Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomFilledButton(
          onTap: () {
            widget.onApplyFilters(
              _pickedStartDate.value,
              _pickedEndDate.value,
            );
            context.pop();
          },
          text: 'Apply',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
