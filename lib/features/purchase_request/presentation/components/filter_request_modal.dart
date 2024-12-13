import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../injection_container.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';

class FilterRequestModal extends StatefulWidget {
  const FilterRequestModal({
    super.key,
    required this.onApplyFilters,
    this.startDate,
    this.endDate,
  });

  final Function(
      DateTime? startDate,
      DateTime? endDate,
  ) onApplyFilters;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<FilterRequestModal> createState() => _FilterRequestModalState();
}

class _FilterRequestModalState extends State<FilterRequestModal> {
  late DateTime? _selectedStartDateFilter;
  late DateTime? _selectedEndDateFilter;

  final ValueNotifier<DateTime> _pickedStartDate = ValueNotifier(DateTime.now());
  final ValueNotifier<DateTime> _pickedEndDate = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();

    // Initialize with the passed filter values

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 400.0,
      headerTitle: 'Filter Request',
      subtitle: 'Filter requests by the following parameters.',
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
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
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
          fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
              ? AppColor.lightCustomTextBox
              : AppColor.darkCustomTextBox),
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
              _selectedStartDateFilter,
              _selectedEndDateFilter,
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
