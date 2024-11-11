import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/utils/readable_enum_converter.dart';

class FilterUserModal extends StatelessWidget {
  const FilterUserModal({
    super.key,
    required this.selectedAuthStatusNotifier,
  });

  final ValueNotifier<AuthStatus?> selectedAuthStatusNotifier;

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 900.0,
      height: 300.0,
      headerTitle: 'Filter User',
      subtitle: 'Filter user based on their authentication status.',
      content: _FilterContent(
        selectedAuthStatusNotifier: selectedAuthStatusNotifier,
      ),
      footer: const _ActionsRow(),
    );
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent({
    super.key,
    required this.selectedAuthStatusNotifier,
  });

  final ValueNotifier<AuthStatus?> selectedAuthStatusNotifier;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownField(
      value: selectedAuthStatusNotifier.value,
      onChanged: (value) {
        selectedAuthStatusNotifier.value = value;
      },
      items: AuthStatus.values
          .map(
            (type) => DropdownMenuItem(
          value: type,
          child: Text(
            readableEnumConverter(type),
          ),
        ),
      )
          .toList(),
      label: 'Authentication Status',
      placeholderText: 'Select Authentication Status',
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    super.key,
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
            // The Apply button sets the selectedAuthStatusNotifier value
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
