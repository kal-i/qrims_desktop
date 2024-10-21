import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationRow extends StatelessWidget {
  const NavigationRow({
    super.key,
    required this.items,
  });

  final List<NavigationItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: items
            .map(
              (item) => _navigationButton(
                context,
                item.text,
                item.path,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _navigationButton(
    BuildContext context,
    String text,
    String path,
  ) {
    bool isSelected = GoRouter.of(context)
            .routerDelegate
            .currentConfiguration
            .uri
            .toString() ==
        path;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Theme.of(context).dividerColor : Colors.transparent,
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: BorderRadius.circular(10.0),
          hoverColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
          splashColor:
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.03),
          child: Container(
            width: 80.0,
            height: 40.0,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                text,
                style: isSelected
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 13.0,
                        )
                    : Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 13.0,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final String text;
  final String path;

  const NavigationItem({
    required this.text,
    required this.path,
  });
}
