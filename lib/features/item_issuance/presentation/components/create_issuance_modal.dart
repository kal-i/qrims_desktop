import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/base_modal.dart';

// this will allow them to create issuance even though the items doesn't exist in the inventory
// this will also include issuance for services
final List<String> _issuanceType = [
  'Request and Issuance Slip',
  'Inventory Custodian Slip',
  'Property Acknowledgement Request',
];

class CreateIssuanceModal extends StatelessWidget {
  const CreateIssuanceModal({
    super.key,
    this.content,
    this.onCreate,
  });

  final Widget? content;
  final Function()? onCreate;

  @override
  Widget build(BuildContext context) {
    return const BaseModal(
      width: 900.0,
      height: 300.0,
      headerTitle: 'Create Empty Issuance',
      subtitle: 'This modal allows users to create an issuance for services or items that are not listed in the inventory.',
      content: _CreateIssuanceContent(),
      footer: _IssuanceModalFooter(),
    );
  }
}

class _CreateIssuanceContent extends StatelessWidget {
  const _CreateIssuanceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDropdownField(
          onChanged: (value) {},
          items: _issuanceType
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ),
              )
              .toList(),
          placeholderText: 'Issuance Type',
        ),
      ],
    );
  }
}

class _IssuanceModalFooter extends StatelessWidget {
  const _IssuanceModalFooter({
    super.key,
    this.onCreate,
  });

  final VoidCallback? onCreate;

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
          onTap: onCreate,
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
