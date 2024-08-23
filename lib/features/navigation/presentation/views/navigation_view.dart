import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../config/routes/app_router.dart';
import '../../../../config/routes/app_routing_constants.dart';
import '../../../../core/common/components/loader.dart';
import '../../../../core/common/components/window_buttons.dart';
import '../../../../core/entities/supply_department_employee.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';
import '../components/side_navigation_drawer/side_navigation_drawer.dart';

/// why is the windows btn much performant when placed in the app bar instead of
class NavigationView extends StatelessWidget {
  const NavigationView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is Unauthenticated) {
          print('logout');
          DelightfulToastUtils.showDelightfulToast(
            context: context,
            icon: Icons.info_outline_rounded,
            title: 'Information',
            subtitle: 'You have logged out successfully.',
          );
          await windowManager.unmaximize();
          await Future.delayed(const Duration(seconds: 3));
          context.go(RoutingConstants.loginViewRoutePath);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            final userData = state.data;
            if (userData is SupplyDepartmentEmployeeEntity) {
              final isAdmin = userData.role == Role.admin;
              return _buildNavigationView(isAdmin, context);
            }
          }
          return const Loader();
        },
      ),
    );
  }

  Widget _buildNavigationView(bool isAdmin, BuildContext context) {
    final sidebarItems = [
      const SideBarItem(
        iconSelected: Icons.space_dashboard,
        text: 'Dashboard',
      ),
      const SideBarItem(
        iconSelected: CupertinoIcons.cube_fill,
        text: 'Inventory',
      ),
      const SideBarItem(
        iconSelected: Icons.send_rounded,
        text: 'Item Issuance',
      ),
      if (isAdmin)
        const SideBarItem(
          iconSelected: Icons.manage_accounts_rounded,
          text: 'User Management',
        ),
      const SideBarItem(
        iconSelected: Icons.settings_rounded,
        text: 'Settings',
      ),
    ];

    return BlocBuilder<SideNavigationDrawerBloc, SideNavigationDrawerState>(
      builder: (context, state) {
        print('nav view - side bar current index: ${state.selectedIndex}');
        RouteChangeManager.handleRouteChange(GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString());

        return Scaffold(
          body: Row(
            children: [
              SideNavigationDrawer(
                isAdmin: isAdmin,
                widthSwitch: 700.0,
                sidebarItems: sidebarItems,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, right: 20.0, bottom: 20.0, left: 10.0),
                  child: Column(
                    children: [
                      DragToMoveArea(
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 10.0,
                          ),
                          height: 50.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: PageTitleNotifier.pageTitle,
                                builder: (context, title, child) => Text(
                                  title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Row(
                                children: [
                                  const badges.Badge(
                                    //badgeContent: Text('0'),
                                    child: Icon(
                                      CupertinoIcons.bell,
                                      size: 20.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      CupertinoIcons.ellipsis_vertical,
                                      size: 20.0,
                                    ),
                                  ),
                                  const WindowButtons(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// appBar: AppBar(
//   // leading: const DragToMoveArea(
//   //   child: Icon(Icons.graphic_eq_outlined),
//   // ),
//   // title: DragToMoveArea(
//   //   child: Text(
//   //     'qrims.',
//   //     style: Theme.of(context).textTheme.displayLarge,
//   //   ),
//   // ),
//   actions: [
//     // CustomContainer(
//     //   child: IconButton(
//     //     onPressed: () {
//     //       context.read<ThemeBloc>().add(ToggleTheme());
//     //     },
//     //     icon: context.watch<ThemeBloc>().state == AppTheme.light
//     //         ? const Icon(
//     //             Icons.light_mode_outlined,
//     //             color: AppColor.darkPrimary,
//     //             size: 20.0,
//     //           )
//     //         : const Icon(
//     //             Icons.dark_mode_outlined,
//     //             color: AppColor.lightPrimary,
//     //             size: 20.0,
//     //           ),
//     //   ),
//     // ),
//     // const Row(
//     //   children: [
//     //     badges.Badge(
//     //       badgeContent: Text('3'),
//     //       child: Icon(
//     //         Icons.notifications_none_outlined,
//     //         size: 25.0,
//     //       ),
//     //     ),
//     //     SizedBox(
//     //       width: 10.0,
//     //     ),
//     //   ],
//     // ),
//     // const AccountProfile(imagePath: ImagePath.profile),
//     // const SizedBox(
//     //   width: 10.0,
//     // ),
//     const WindowButtons(),
//   ],
// ),

