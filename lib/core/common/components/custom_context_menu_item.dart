import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

final class CustomContextMenuItem extends ContextMenuItem<String> {
  const CustomContextMenuItem({
    required this.label,
    super.value,
    super.onSelected,
    this.subtitle,
    this.icon,
  });

  const CustomContextMenuItem.submenu({
    required this.label,
    required super.items,
    this.subtitle,
    this.icon
  }) : super.submenu();

  final String label;
  final String? subtitle;
  final IconData? icon;

  @override
  bool get isFocusMaintained => true;

  @override
  Widget builder(BuildContext context, ContextMenuState menuState, [FocusNode? focusNode]) {

    return ListTile(
      focusNode: focusNode, // important for highlighting item on focus
      title: SizedBox(width: double.maxFinite, child: Text(label),),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: () => handleItemSelection(context),
      trailing: Icon(isSubmenuItem ? Icons.arrow_right : null),
      leading: Icon(icon, size: 20.0,),
      dense: false,
      selected: menuState.isOpened(this),
      selectedColor: Colors.white,
      selectedTileColor: Colors.blue,
    );
  }

  @override
  String get debugLabel => '[${hashCode.toString().substring(0, 5)}] $label';
}
