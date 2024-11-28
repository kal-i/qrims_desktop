import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';
import 'base_container.dart';

class KPICard extends StatelessWidget {
  const KPICard({
    super.key,
    required this.icon,
    required this.title,
    required this.data,
    this.bgColor,
    this.iconBackgroundColor,
    this.outlineColor,
    this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final String data;
  final Color? bgColor;
  final Color? iconBackgroundColor;
  final Color? outlineColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {

    return BaseContainer(
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: iconBackgroundColor ?? (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightTertiary
                  : AppColor.darkTertiary),
            ),
            child: Icon(
              icon,
              color: outlineColor,
              //color: AppColor.accent,
            ),
          ),
          const SizedBox(
            width: 10.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w900,
                  color: foregroundColor,
                ),
              ),
              Text(
                data,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
