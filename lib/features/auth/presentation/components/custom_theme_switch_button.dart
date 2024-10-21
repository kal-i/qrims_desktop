import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import 'custom_container.dart';

class CustomThemeSwitchButton extends StatelessWidget {
  const CustomThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      width: 50.0,
      height: 50.0,
      child: IconButton(
        onPressed: () {
          context.read<ThemeBloc>().add(ToggleTheme());
        },
        icon: context.watch<ThemeBloc>().state == AppTheme.light
            ? const Icon(
                Icons.light_mode_outlined,
                color: AppColor.darkPrimary,
                size: 20.0,
              )
            : const Icon(
                Icons.dark_mode_outlined,
                color: AppColor.lightPrimary,
                size: 20.0,
              ),
      ),
    );
  }
}
