import 'package:flutter/material.dart';

import '../../../../core/common/components/base_modal.dart';

class RegisterNewItemModal extends StatelessWidget {
  const RegisterNewItemModal({super.key});


  @override
  Widget build(BuildContext context) {
    return const BaseModal(
      width: 900.0,
      height: 300.0,
      headerTitle: 'Register New Item',
      subtitle: 'Choose an item type to register.',
      content: SizedBox.shrink(),
    );
  }
}
