import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    this.onTap,
    required this.text,
    this.color,
    this.height,
    this.width,
  });

  final VoidCallback? onTap;
  final String text;
  final Color? color;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = color ?? AppColor.accent;
    final hoverColor = baseColor.withOpacity(0.3);
    final focusColor = baseColor.withOpacity(0.1);
    final splashColor = baseColor.withOpacity(0.6);

    return Material(
      borderRadius: BorderRadius.circular(10.0),
      color: baseColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        hoverColor: hoverColor,
        focusColor: focusColor,
        splashColor: splashColor,
        child: Container(
          height: height ?? 40.0,
          width: width ?? 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColor.lightPrimary,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
