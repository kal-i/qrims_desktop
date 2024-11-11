import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../core/common/components/custom_date_picker.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/custom_text_box.dart';
import '../../../../core/enums/issuance_purpose.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/purchase_request_suggestions_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../injection_container.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../../../../core/common/components/base_modal.dart';

// pr id dropdown
// init info for issuance like the name of req. off
// date and status
final List<String> _samplePRIds = [
  '2024-10-01',
  '2024-10-02',
  '2024-10-03',
  '2024-10-04',
  '2024-10-05',
];

class CreateIcsModal extends StatefulWidget {
  const CreateIcsModal({super.key});

  @override
  State<CreateIcsModal> createState() => _CreateIcsModalState();
}

class _CreateIcsModalState extends State<CreateIcsModal> {
  late PurchaseRequestSuggestionsService _purchaseRequestSuggestionsService;

  final _prIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _purchaseRequestSuggestionsService =
        serviceLocator<PurchaseRequestSuggestionsService>();
  }

  @override
  void dispose() {
    _prIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 300.0,
      headerTitle: 'Create Inventory Custodian Slip',
      subtitle: 'Issue items below Php 50,000.00',
      content: _buildModalContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildModalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPurchaseRequestIdSuggestionField(),
        // CustomDropdownField(
        //   onChanged: (value) {},
        //   items: _samplePRIds
        //       .map(
        //         (type) => DropdownMenuItem(
        //       value: type,
        //       child: Text('PR No. $type'),
        //     ),
        //   )
        //       .toList(),
        //   placeholderText: 'PR ID',
        // ),
        // const SizedBox(
        //   height: 30.0,
        // ),
        // Text(
        //   'Preview',
        //   style: Theme.of(context).textTheme.titleSmall?.copyWith(
        //     fontSize: 18.0,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
        // const SizedBox(
        //   height: 20.0,
        // ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: CustomTextBox(
        //         height: 50.0,
        //         placeHolderText: 'Status',
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 20.0,
        //     ),
        //     Expanded(
        //       child: _buildDateSelection(),
        //     ),
        //   ],
        // ),
        // const SizedBox(
        //   height: 20.0,
        // ),
        // Row(
        //   children: [
        //     Expanded(
        //       flex: 2,
        //       child: CustomTextBox(
        //         height: 50.0,
        //         placeHolderText: 'Requesting Officer Name',
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 20.0,
        //     ),
        //     Expanded(
        //       child: CustomTextBox(
        //         height: 50.0,
        //         placeHolderText: 'Office',
        //       ),
        //     ),
        //     const SizedBox(
        //       width: 20.0,
        //     ),
        //     Expanded(
        //       child: CustomTextBox(
        //         height: 50.0,
        //         placeHolderText: 'Position',
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildDateSelection() {
    final ValueNotifier<DateTime> _pickedDate = ValueNotifier(DateTime.now());
    return ValueListenableBuilder(
      valueListenable: _pickedDate,
      builder: (context, pickedValue, child) {
        final dateController = TextEditingController(
          text: pickedValue != null ? dateFormatter(pickedValue) : '',
        );

        return CustomDatePicker(
          onDateChanged: (DateTime? date) {
            if (date != null) {
              _pickedDate.value = date;
            }
          },
          label: 'Acquired Date',
          dateController: dateController,
        );
      },
    );
  }

  Widget _buildPurchaseRequestIdSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (prId) async {
        return await _purchaseRequestSuggestionsService.fetchPurchaseRequestIds(
          prId: prId,
          type: 'ics',
        );
      },
      onSelected: (value) {
        _prIdController.text = value;
      },
      controller: _prIdController,
      label: 'PR ID',
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
            context.pop();
            context.go(
              RoutingConstants.nestedRegisterItemIssuanceViewRoutePath,
              extra: {
                'purpose': IssuancePurpose.register,
                'type': IssuanceType.ics,
                'pr_id': _prIdController.text,
              },
            );
          },
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
