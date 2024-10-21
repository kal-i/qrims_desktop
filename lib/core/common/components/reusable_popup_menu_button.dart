import 'package:flutter/material.dart';

class ReusablePopupMenuButton extends StatelessWidget {
  const ReusablePopupMenuButton({
    super.key,
    required this.onSelected,
    this.icon,
    this.tooltip,
    required this.popupMenuItems,
  });

  final Function(String)? onSelected;
  final Widget? icon;
  final String? tooltip;
  final List<PopupMenuEntry<String>> popupMenuItems;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      splashRadius: 40.0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).dividerColor,), borderRadius: BorderRadius.circular(10.0)),
      onSelected: onSelected,
      icon: icon,
      tooltip: tooltip,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => popupMenuItems,
      style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20.0))),
    );
  }

  static PopupMenuItem<String> reusableListTilePopupMenuItem({
    required BuildContext context,
    String? value,
    String? title,
    Widget? leading,
    IconData? icon,
    String? imagePath,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: leading != null
            ? SizedBox(
                width: 200.0,
                child: leading,
              )
            : icon != null
                ? Icon(
                    icon,
                    //color: AppColor.accent,
                    size: 20.0,
                  )
                : imagePath != null
                    ? SizedBox(height: 20.0, child: Image.asset(imagePath))
                    : null,
        title: Text(
          title ?? '',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
