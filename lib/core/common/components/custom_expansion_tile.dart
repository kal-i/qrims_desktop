import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CustomExpansionTile extends StatelessWidget {
  const CustomExpansionTile({
    super.key,
    required this.isExpandedNotifier,
    required this.title,
  });

  final ValueNotifier<bool> isExpandedNotifier;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return SingleChildScrollView(
          child: ExpansionTile(
            onExpansionChanged: (bool expanded) =>
            isExpandedNotifier.value = expanded,
            tilePadding: EdgeInsets.zero,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            trailing: Icon(
              isExpanded
                  ? HugeIcons.strokeRoundedArrowUp01
                  : HugeIcons.strokeRoundedArrowDown01,
              size: 20.0,
            ),
            //children: ,
          ),
        );
      },
    );
  }
}
