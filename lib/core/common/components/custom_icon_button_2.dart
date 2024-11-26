import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class CustomIconButton2 extends StatelessWidget {
  const CustomIconButton2({
    super.key,
    this.onTap,
    required this.icon,
    this.tooltip,
    this.color,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).primaryColor,
          ),
          child: Icon(
            icon,
            color: color ?? AppColor.accent,
            size: 24.0,
          ),
        ),
      ),
    );
  }
}
