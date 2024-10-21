import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import 'account_profile_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSettingsNavigationRow(),
        const SizedBox(
          height: 20.0,
        ),
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }

  Widget _buildSettingsNavigationRow() {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          _navigationButton(
            'General',
            RoutingConstants.generalSettingViewRoutePath,
          ),
          _navigationButton(
            'Account',
            RoutingConstants.accountProfileViewRoutePath,
          ),
        ],
      ),
    );
  }

  Widget _navigationButton(
    String text,
    String path,
  ) {
    bool isSelected = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString() == path;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Theme.of(context).dividerColor : Colors.transparent, // AppColor.darkSecondary : Colors.transparent,
        child: InkWell(
          onTap: () => context.go(path),
          borderRadius: BorderRadius.circular(10.0),
          hoverColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
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
