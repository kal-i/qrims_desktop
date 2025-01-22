import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/utils/delightful_toast_utils.dart';

class RegisterNewItemModal extends StatelessWidget {
  RegisterNewItemModal({super.key});

  final ValueNotifier<String?> selectedItemType = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 300.0,
      headerTitle: 'Register New Item',
      subtitle: 'Choose an item type to register.',
      content: Column(
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: selectedItemType,
            builder: (context, value, child) {
              return CustomDropdownField(
                onChanged: (newValue) {
                  selectedItemType.value = newValue;
                },
                items: [
                  'Supply (Consumables)',
                  'Equipment (Useful life of more than 1)',
                ]
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                        ),
                      ),
                    )
                    .toList(),
                label: 'Item Type',
                placeholderText: 'Select Item Type',
              );
            },
          ),
        ],
      ),
      footer: _ActionsRow(
        selectedItemType: selectedItemType,
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final ValueNotifier<String?> selectedItemType;

  const _ActionsRow({
    super.key,
    required this.selectedItemType,
  });

  @override
  Widget build(BuildContext context) {
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
            final selectedType = selectedItemType.value;

            if (selectedType == null) {
              DelightfulToastUtils.showDelightfulToast(
                context: context,
                icon: Icons.info_outline,
                title: 'Informtion',
                subtitle: 'Please select an item type.',
              );
              return;
            }

            context.pop();

            final Map<String, dynamic> extra = {
              'is_update': false,
            };

            if (selectedType == 'Supply (Consumables)') {
              context.go(
                RoutingConstants.nestedRegisterSupplyItemViewRoutePath,
                extra: extra,
              );
            } else if (selectedType == 'Equipment') {
              context.go(
                RoutingConstants.nestedRegisterEquipmentItemViewRoutePath,
                extra: extra,
              );
            }
          },
          text: 'Apply',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
