import 'package:flutter/material.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../core/common/components/navigation_row.dart';

class BaseArchiveView extends StatefulWidget {
  const BaseArchiveView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<BaseArchiveView> createState() => _BaseArchiveViewState();
}

class _BaseArchiveViewState extends State<BaseArchiveView> {
  final List<NavigationItem> _navItems = [
    const NavigationItem(
      text: 'Users',
      path: RoutingConstants.archiveUserViewRoutePath,
    ),
    const NavigationItem(
      text: 'Officers',
      path: '',
    ),
    const NavigationItem(
      text: 'Issuance',
      path: '',
    ),
    const NavigationItem(
      text: 'Reports',
      path: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(
            height: 20.0,
          ),
          _buildNavigationRow(),
          const SizedBox(
            height: 50.0,
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow() {
    return NavigationRow(
      items: _navItems,
    );
  }

  Widget _buildHeader() {
    return Text(
      'Management of archived data.',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
    );
  }
}
