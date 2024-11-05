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
    this.baseColor,
  });

  final IconData icon;
  final String title;
  final String data;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return BaseContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: (context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightTertiary
                  : AppColor.darkTertiary),
            ),
            child: Icon(
              icon,
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
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                data,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
