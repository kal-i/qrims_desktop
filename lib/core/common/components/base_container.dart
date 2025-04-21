import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class BaseContainer extends StatelessWidget {
  const BaseContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.marginBottom,
    this.padding,
    this.borderRadius,
    this.color,
    this.hasBoxShadow = false,
  });

  final Widget? child;
  final double? width;
  final double? height;
  final double? marginBottom;
  final double? padding;
  final double? borderRadius;
  final Color? color;
  final bool hasBoxShadow;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(
        bottom: marginBottom ?? 0.0,
      ),
      padding: EdgeInsets.all(padding ?? 20.0),
      width: width,
      height: height ?? 160.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: currentTheme.dividerColor,
          width: .4,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
        boxShadow: hasBoxShadow
            ? [
                BoxShadow(
                  color: AppColor.darkPrimary.withOpacity(0.25),
                  blurRadius: 4.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 4.0),
                )
              ]
            : null,
        color: color ?? currentTheme.cardColor,
      ),
      child: child,
    );
  }
}
