import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.onTap,
    this.tooltip,
    this.icon,
    this.height,
    this.width,
  });

  final VoidCallback? onTap;
  final String? tooltip;
  final IconData? icon;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineBorderColor = theme.dividerColor;
    final hoverColor = outlineBorderColor.withOpacity(0.6);
    final focusColor = outlineBorderColor.withOpacity(0.2);
    final splashColor = outlineBorderColor.withOpacity(0.3);

    return Tooltip(
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
            height: height ?? 40.0,
            width: width ?? 40.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: outlineBorderColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
