import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/issuance_type.dart';
import '../../../../core/services/purchase_request_suggestions_service.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../init_dependencies.dart';
import '../../../purchase_request/presentation/components/custom_search_field.dart';
import '../../../../core/common/components/base_modal.dart';

class CreateIssuanceModal extends StatefulWidget {
  const CreateIssuanceModal({
    super.key,
    required this.issuanceType,
  });

  final IssuanceType issuanceType;

  @override
  State<CreateIssuanceModal> createState() => _CreateIssuanceModalState();
}

class _CreateIssuanceModalState extends State<CreateIssuanceModal> {
  late PurchaseRequestSuggestionsService _purchaseRequestSuggestionsService;

  final _prIdController = TextEditingController();

  final ValueNotifier<String?> _selectedType = ValueNotifier(null);
  bool _isValidPrIdSelected = false;

  @override
  void initState() {
    super.initState();
    _purchaseRequestSuggestionsService =
        serviceLocator<PurchaseRequestSuggestionsService>();
  }

  @override
  void dispose() {
    _prIdController.dispose();
    _selectedType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 380.0,
      headerTitle: widget.issuanceType == IssuanceType.ics
          ? 'Create Inventory Custodian Slip'
          : widget.issuanceType == IssuanceType.par
              ? 'Create Property Acknowledgement Receipt'
              : 'Create Requisition and Issue Slip',
      subtitle: widget.issuanceType == IssuanceType.ics
          ? 'Issue items below Php 50,000.00'
          : widget.issuanceType == IssuanceType.par
              ? 'Issue items above Php 50,000.00'
              : 'Issue supply items (consumable)',
      content: _buildModalContent(),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildModalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPRSelection(context),
        const SizedBox(height: 20.0),
        ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, isWithPr, child) {
            return _selectedType.value == '/w PR'
                ? _buildPurchaseRequestIdSuggestionField()
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildPRSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10.0,
        ),
        Text(
          'Issue with an actual Purchase Request object saved on the?',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 10.0),
        ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, value, child) {
            return CustomDropdownField(
              onChanged: (newValue) {
                _selectedType.value = newValue;
              },
              items: [
                '/w PR',
                'w/o PR',
              ]
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              label: 'Issue Type',
              placeholderText: 'Select Issue Type',
            );
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseRequestIdSuggestionField() {
    return CustomSearchField(
      suggestionsCallback: (prId) async {
        _isValidPrIdSelected = false;

        final results =
            await _purchaseRequestSuggestionsService.fetchPurchaseRequestIds(
          prId: prId,
        );

        if ((results == null || results.isEmpty) && prId.isNotEmpty) {
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.warning_amber_outlined,
            title: 'No Match',
            subtitle: 'No Purchase Request found with that ID.',
          );
        }

        return results;
      },
      onSelected: (value) {
        _prIdController.text = value;
        _isValidPrIdSelected = true;
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
        const SizedBox(width: 10.0),
        CustomFilledButton(
          onTap: () {
            if (_selectedType.value == null) {
              DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.info_outline,
                title: 'Information',
                subtitle: 'Please select an issue type.',
              );
              return;
            }

            if (_selectedType.value == '/w PR') {
              if (_prIdController.text.isEmpty) {
                DelightfulToastUtils.showDelightfulToast(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'Information',
                  subtitle: 'Please select a PR ID.',
                );
                return;
              }

              if (!_isValidPrIdSelected) {
                DelightfulToastUtils.showDelightfulToast(
                  context: context,
                  icon: Icons.warning_amber_outlined,
                  title: 'Invalid PR ID',
                  subtitle: 'Please select a PR ID from the suggestions.',
                );
                return;
              }
            }

            if (_selectedType.value == 'w/o PR' &&
                widget.issuanceType != IssuanceType.ris) {
              context.pop();
              context.go(
                RoutingConstants
                    .nestedRegisterMultipleItemIssuanceViewRoutePath,
                extra: {
                  'type': widget.issuanceType == IssuanceType.ics
                      ? IssuanceType.ics
                      : IssuanceType.par,
                },
              );
              return;
            }

            context.pop();
            context.go(
              RoutingConstants.nestedRegisterItemIssuanceViewRoutePath,
              extra: {
                'type': widget.issuanceType == IssuanceType.ics
                    ? IssuanceType.ics
                    : widget.issuanceType == IssuanceType.par
                        ? IssuanceType.par
                        : IssuanceType.ris,
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
