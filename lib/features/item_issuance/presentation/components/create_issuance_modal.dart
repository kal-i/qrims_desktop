import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../users_management/presentation/components/base_modal.dart';

class CreateIssuanceModal extends StatelessWidget {
  const CreateIssuanceModal({
    super.key,
    required this.headerTitle,
    this.content,
    this.onCreate,
  });

  final String headerTitle;
  final Widget? content;
  final Function()? onCreate;

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 450.0,
      height: 300.0,
      headerTitle: headerTitle,
      content: content,
      footer: const _IssuanceModalFooter(),
    );
  }
}

class _IssuanceModalFooter extends StatelessWidget {
  const _IssuanceModalFooter({
    super.key,
    this.onCreate,
  });

  final Function()? onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomFilledButton(
          onTap: onCreate,
          text: 'Create',
          width: 180.0,
          height: 40.0,
        ),
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          width: 180.0,
        ),
      ],
    );
  }
}
