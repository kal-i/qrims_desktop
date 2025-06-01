import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/issuance_item_status.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../bloc/issuances_bloc.dart';

class AccountabilityStatusModal extends StatefulWidget {
  const AccountabilityStatusModal({
    super.key,
    required this.baseItemId,
    this.status,
    this.remarks,
    this.date,
  });

  final String baseItemId;
  final IssuanceItemStatus? status;
  final String? remarks;
  final DateTime? date;

  @override
  State<AccountabilityStatusModal> createState() =>
      _AccountabilityStatusModalState();
}

class _AccountabilityStatusModalState extends State<AccountabilityStatusModal> {
  final ValueNotifier<IssuanceItemStatus?> _status = ValueNotifier(null);
  final ValueNotifier<DateTime?> _date = ValueNotifier(null);

  final _remarksController = TextEditingController();

  bool _isViewOnlyMode() =>
      widget.status == IssuanceItemStatus.returned ||
      widget.status == IssuanceItemStatus.lost ||
      widget.status == IssuanceItemStatus.disposed;

  @override
  void initState() {
    super.initState();

    _status.value = widget.status;
    _date.value = widget.date ?? DateTime.now();
    _remarksController.text =
        !_isViewOnlyMode() ? '' : widget.remarks ?? 'No remarks specified.';
  }

  void _onSave() {
    if (_status.value == null) {
      DelightfulToastUtils.showDelightfulToast(
        context: context,
        icon: Icons.error_outline,
        title: 'Update Failed',
        subtitle: 'Please select a status.',
      );
      return;
    }

    context.read<IssuancesBloc>().add(
          ResolveIssuanceItemEvent(
            baseItemId: widget.baseItemId,
            status: _status.value!,
            date: _date.value!,
            remarks: _remarksController.text,
          ),
        );

    context.pop();
  }

  @override
  void dispose() {
    _status.dispose();
    _date.dispose();
    _remarksController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 600.0,
      height: 500.0,
      headerTitle: 'Accountability Status',
      subtitle: !_isViewOnlyMode()
          ? 'Resolve accountable item.'
          : 'View resolved accountability.',
      content: _buildContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildContent() {
    return Column(
      spacing: 20.0,
      children: [
        CustomDropdownField<IssuanceItemStatus>(
          value: _status.value,
          onChanged:
              !_isViewOnlyMode() ? (value) => _status.value = value : null,
          items: [
            const DropdownMenuItem<IssuanceItemStatus>(
              value: null,
              child: Text('Select status'),
            ),
            ...IssuanceItemStatus.values
                .where((status) =>
                    status != IssuanceItemStatus.issued &&
                    status != IssuanceItemStatus.received)
                .map(
                  (status) => DropdownMenuItem<IssuanceItemStatus>(
                    value: status,
                    child: Text(readableEnumConverter(status)),
                  ),
                ),
          ],
          label: 'Issuance Item Status',
          placeholderText: 'Select status',
        ),
        _buildDateSelection(),
        CustomFormTextField(
          label: 'Remarks (optional)',
          placeholderText: 'Enter remarks',
          maxLines: 4,
          controller: _remarksController,
          enabled: !_isViewOnlyMode(),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return ValueListenableBuilder(
      valueListenable: _date,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: !_isViewOnlyMode()
              ? (DateTime? date) {
                  if (date != null) {
                    _date.value = date;
                  }
                }
              : null,
          label: 'Date',
          dateController: dateController,
          enabled: !_isViewOnlyMode(),
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
          text: 'Back',
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        if (!_isViewOnlyMode())
          CustomFilledButton(
            onTap: _onSave,
            text: 'Save',
            width: 180.0,
            height: 40.0,
          ),
      ],
    );
  }
}
