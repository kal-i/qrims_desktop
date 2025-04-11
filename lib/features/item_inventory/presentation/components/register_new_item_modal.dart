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
      height: 400.0,
      headerTitle: 'Register New Item',
      subtitle: 'Choose an item type to register.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: selectedItemType,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomDropdownField(
                    onChanged: (newValue) {
                      selectedItemType.value = newValue;
                    },
                    items: [
                      'Supply',
                      'Inventory',
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
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: selectedItemType.value == 'Supply'
                            ? '**📦 Supply Items** '
                            : selectedItemType.value == 'Inventory'
                                ? '**🔧 Inventory Items** '
                                : '**❓ Item Type** ',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 2.0,
                            ),
                        children: [
                          selectedItemType.value == 'Supply'
                              ? TextSpan(
                                  text:
                                      '(or consumables) are tracked in bulk. If a new batch of supplies has the ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        height: 2.0,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: '**same details** ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 2.0,
                                          ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '(e.g., name, description, specification, unit, unit price, acquisition date, and fund cluster) as an existing one, simply increase the quantity. Otherwise, it will be treated as a new record to accurately track each batch.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                height: 2.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : selectedItemType.value == 'Inventory'
                                  ? TextSpan(
                                      text: 'are stored as ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            height: 2.0,
                                          ),
                                      children: [
                                        TextSpan(
                                          text: '**separate records** ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                height: 2.0,
                                              ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  'in the database, with each having assigned a ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    height: 2.0,
                                                  ),
                                              children: [
                                                TextSpan(
                                                  text: '**unique id** ',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 2.0,
                                                      ),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          ', often issued or tracked individually, and may have different properties (e.g., serial no.) for simplified tracking and management.',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 2.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const TextSpan(
                                      text: 'item type description...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                title: 'Information',
                subtitle: 'Please select an item type.',
              );
              return;
            }

            context.pop();

            final Map<String, dynamic> extra = {
              'is_update': false,
            };

            if (selectedType == 'Supply') {
              context.go(
                RoutingConstants.nestedRegisterSupplyItemViewRoutePath,
                extra: extra,
              );
            } else if (selectedType == 'Inventory') {
              context.go(
                RoutingConstants.nestedRegisterInventoryItemViewRoutePath,
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
