import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';

class GeneralSettingView extends StatelessWidget {
  const GeneralSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Appearance(),
        // SizedBox(
        //   height: 50.0,
        // ),
        // Expanded(
        //   child: _FileDirectory(),
        // ),
      ],
    );
  }
}

class _Appearance extends StatelessWidget {
  const _Appearance({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Change how your app looks.',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
        ),
        SizedBox(
          height: 50.0,
          child: Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1.5,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interface Theme',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 13.0, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Change how your app looks.',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _ThemePreviewContainer(
                    onTap: () => theme.add(SetLightTheme()),
                    title: 'Light Theme',
                    icon: HugeIcons.strokeRoundedSun01,
                    color: AppColor.lightSecondary,
                    isSelected: theme.state == AppTheme.light,
                  ),
                  const SizedBox(
                    width: 50.0,
                  ),
                  _ThemePreviewContainer(
                    onTap: () => theme.add(SetDarkTheme()),
                    title: 'Dark Theme',
                    icon: HugeIcons.strokeRoundedMoon02,
                    color: AppColor.darkSecondary,
                    isSelected: theme.state == AppTheme.dark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemePreviewContainer extends StatefulWidget {
  const _ThemePreviewContainer({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;

  @override
  State<_ThemePreviewContainer> createState() => _ThemePreviewContainerState();
}

class _ThemePreviewContainerState extends State<_ThemePreviewContainer> {
  final ValueNotifier<bool> _isHovered = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: _isHovered,
              builder: (context, isHovered, child) {
                return Column(
                  children: [
                    Container(
                      width: 250.0,
                      height: 150.0,
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isHovered || widget.isSelected
                              ? AppColor.accent
                              : Theme.of(context).dividerColor,
                          width: isHovered ? 2.0 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              key: ValueKey<bool>(widget.isSelected),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: widget.color,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 2.0,
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: widget.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Row(
                    //   children: [
                    //     Icon(widget.icon, color: isHovered || widget.isSelected ? AppColor.accent : Theme.of(context).dividerColor, size: 20.0,),
                    //     const SizedBox(
                    //       width: 5.0,
                    //     ),
                    //     Text(
                    //       widget.title,
                    //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    //         fontSize: 13.0,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}

class _FileDirectory extends StatelessWidget {
  const _FileDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'File Directory',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Set the locations for saving, and downloading files.',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
        ),
        SizedBox(
          height: 50.0,
          child: Divider(
            color: Theme.of(context).dividerColor,
            thickness: 1.5,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Root Directory',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Change how your app looks.',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
