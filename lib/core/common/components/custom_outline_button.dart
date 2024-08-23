import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    this.onTap,
    this.text,
    this.icon,
    this.imagePath,
    this.height,
    this.width,
  });

  final VoidCallback? onTap;
  final String? text;
  final IconData? icon;
  final String? imagePath;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineBorderColor = theme.dividerColor;
    final hoverColor = outlineBorderColor.withOpacity(0.1);
    final focusColor = outlineBorderColor.withOpacity(0.2);
    final splashColor = outlineBorderColor.withOpacity(0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        hoverColor: hoverColor,
        focusColor: focusColor,
        splashColor: splashColor,
        onTap: onTap,
        child: Container(
          height: height ?? 40.0,
          width: width ?? 100.0,
          decoration: BoxDecoration(
            border: Border.all(
              color: outlineBorderColor,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColor.accent,
                  fontSize: 13.0,
                ),
              ),
              if (icon != null || imagePath != null) // add space conditionally
                const SizedBox(
                  width: 5.0,
                ),
              if (icon != null)
                Icon(
                  icon,
                  color: AppColor.accent,
                  size: 20.0,
                ),
              if (imagePath != null)
                SizedBox(
                  height: 20.0,
                  child: Image.asset(
                    imagePath!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
