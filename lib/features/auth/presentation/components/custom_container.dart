import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.width = 0, // 50.0,
    this.height = 0, // 50.0,
    this.paddingTop = 0.0,
    this.paddingLeft = 0.0,
    this.paddingBottom = 0.0,
    this.paddingRight = 0.0,
    required this.child,
    this.hasBorder,
  });

  final double? width;
  final double? height;
  final double paddingTop;
  final double paddingLeft;
  final double paddingBottom;
  final double paddingRight;
  final Widget? child;
  final bool? hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.only(
        top: paddingTop,
        left: paddingLeft,
        bottom: paddingBottom,
        right: paddingRight,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColor.darkPrimary.withOpacity(0.25),
        //     blurRadius: 4.0,
        //     spreadRadius: 0.0,
        //     offset: const Offset(0.0, 4.0),
        //   ),
        // ],
        color: Theme.of(context).cardColor,
      ),
      child: child,
    );
  }
}
