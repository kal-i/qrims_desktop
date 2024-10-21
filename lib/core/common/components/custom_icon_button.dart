import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.onTap,
    this.tooltip,
    this.imagePath,
    this.icon,
    this.height,
    this.width,
    this.isOutlined = false,
  });

  final VoidCallback? onTap;
  final String? tooltip;
  final String? imagePath;
  final IconData? icon;
  final double? height;
  final double? width;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineBorderColor = theme.dividerColor;
    final hoverColor = outlineBorderColor.withOpacity(0.6);
    final focusColor = outlineBorderColor.withOpacity(0.2);
    final splashColor = outlineBorderColor.withOpacity(0.3);

    return Tooltip(
      textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColor.darkPrimary,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          hoverColor: hoverColor,
          focusColor: focusColor,
          splashColor: splashColor,
          child: Container(
            padding: const EdgeInsets.all(7.0),
            height: height ?? 40.0,
            width: width ?? 40.0,
            decoration: BoxDecoration(
              border: isOutlined
                  ? Border.all(
                      color: outlineBorderColor,
                      width: 1.5,
                    )
                  : null,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: imagePath != null
                ? Image.asset(imagePath!)
                : icon != null
                    ? Icon(
                        icon,
                        size: 20.0,
                      )
                    : null,
          ),
        ),
      ),
    );
  }
}
