import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../constants/assets_path.dart';
import '../custom_icon_button.dart';
import 'bloc/search_button_bloc.dart';

class ExpandableSearchButton extends StatelessWidget {
  const ExpandableSearchButton({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchButtonBloc, SearchButtonState>(
      builder: (context, state) {
        final isExpanded = state is SearchButtonExpanded;

        return AnimatedContainer(
          duration: const Duration(
            milliseconds: 300,
          ),
          width: isExpanded ? 300.0 : 44.0,
          height: 40.0,
          decoration: BoxDecoration(
            // border: Border.all(
            //   color: context.watch<ThemeBloc>().state == AppTheme.light
            //       ? AppColor.lightOutlineBorder
            //       : AppColor.darkOutlineBorder,
            //   width: 1.5,
            // ),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
            color: Theme.of(context).dividerColor.withOpacity(0.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isExpanded) ...[
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColor.darkPlaceHolderText,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                              ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        left: 10.0,
                        bottom: 10.0,
                      ),
                    ),
                    cursorColor: AppColor.accent,
                  ),
                ),
              ],
              CustomIconButton(
                onTap: () =>
                    context.read<SearchButtonBloc>().add(ToggleExpand()),
                tooltip: 'Search',
                icon: HugeIcons.strokeRoundedSearch01,
              ),
            ],
          ),
        );
      },
    );
  }
}
