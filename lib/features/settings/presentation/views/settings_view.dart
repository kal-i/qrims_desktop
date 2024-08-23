import 'package:flutter/material.dart';

import '../../../../core/common/components/base_container.dart';
import 'profile_tab_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BaseContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings Overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const TabBar(
                    //dividerColor: ,
                    //dividerHeight: ,
                    tabAlignment: TabAlignment.center,
                    tabs: [
                      Tab(
                        text: 'Profile',
                      ),
                      Tab(
                        text: 'Account',
                      ),
                      Tab(
                        text: 'Appearance',
                      ),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        ProfileTabView(),
                        ProfileTabView(),
                        ProfileTabView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
