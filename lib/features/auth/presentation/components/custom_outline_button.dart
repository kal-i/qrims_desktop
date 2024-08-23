import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    required this.onTap,
    required this.text,
    this.width = 100.0,
    this.height = 30.0,
  });

  final VoidCallback onTap;
  final String text;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<ThemeBloc>().state;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: currentTheme == AppTheme.light
                ? AppColor.lightOutline
                : AppColor.darkOutline,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            text,
            style: currentTheme.textTheme.bodySmall?.copyWith(
              color: AppColor.accent,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }
}
