import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final GlobalKey contextMenuKey = GlobalKey();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          hoverColor: Theme.of(context).dividerColor.withOpacity(0.1),
          splashColor: Theme.of(context).dividerColor.withOpacity(0.2),
          child: Container(
            key: contextMenuKey, // Assign the key here
            padding: const EdgeInsets.all(10.0),
            height: 80.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightOutline
                    : AppColor.darkOutlineCardBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color:
                            (context.watch<ThemeBloc>().state == AppTheme.light
                                ? AppColor.lightTertiary
                                : AppColor.darkTertiary),
                      ),
                      child: const Icon(
                        CupertinoIcons.folder,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document title',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 12.0,
                                  ),
                        ),
                        Row(
                          children: [
                            /// file size
                            Text(
                              '220 KB',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),

                            /// divider
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '|',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),

                            /// file extension
                            Text(
                              'pdf',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert_outlined,
                    size: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
