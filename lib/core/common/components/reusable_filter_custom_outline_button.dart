import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'custom_outline_button.dart';
import 'custom_popup_menu.dart';

class ReusableFilterCustomOutlineButton extends StatelessWidget {
  const ReusableFilterCustomOutlineButton({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.initialItemSelected,
    this.menuWidth,
    this.menuHeight,
  });

  final List<Map<String, dynamic>> items;
  final Function(String) onItemSelected;
  final String? initialItemSelected;
  final double? menuWidth;
  final double? menuHeight;

  @override
  Widget build(BuildContext context) {
    return CustomMenuButton(
      tooltip: 'Filter',
      items: items,
      onItemSelected: onItemSelected,
      initialItemSelected: initialItemSelected,
      icon: FluentIcons.filter_add_20_regular,
      width: menuWidth,
      height: menuHeight,
    );
  }
}
