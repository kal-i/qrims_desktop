import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/issuance_purpose.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/purchase_request_suggestions_service.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../../../../core/common/components/base_modal.dart';

class CreateIcsModal extends StatefulWidget {
  const CreateIcsModal({super.key});

  @override
  State<CreateIcsModal> createState() => _CreateIcsModalState();
}

class _CreateIcsModalState extends State<CreateIcsModal> {
  late PurchaseRequestSuggestionsService _purchaseRequestSuggestionsService;

  final _prIdController = TextEditingController();

  final ValueNotifier<bool> _isWithPr = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _purchaseRequestSuggestionsService =
        serviceLocator<PurchaseRequestSuggestionsService>();
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _isWithPr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 350.0,
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
        _buildPRSelection(context),
        const SizedBox(
          height: 20.0,
        ),
        ValueListenableBuilder(
            valueListenable: _isWithPr,
            builder: (context, isWithPr, child) {
              return isWithPr
                  ? _buildPurchaseRequestIdSuggestionField()
                  : const SizedBox.shrink();
            }),
      ],
    );
  }

  Widget _buildPRSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issue with a Purchase Request?',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isWithPr,
          builder: (context, isWithPR, child) {
            return Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: isWithPR,
                  onChanged: (value) {
                    _isWithPr.value = value!;
                  },
                ),
                Text(
                  'With PR',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Radio<bool>(
                  value: false,
                  groupValue: isWithPR,
                  onChanged: (value) {
                    _isWithPr.value = value!;
                  },
                ),
                Text(
                  'Without PR',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseRequestIdSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (prId) async {
        return await _purchaseRequestSuggestionsService.fetchPurchaseRequestIds(
          prId: prId,
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
