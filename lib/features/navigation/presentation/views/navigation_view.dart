import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../config/routes/app_router.dart';
import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/custom_drag_to_move_area.dart';
import '../../../../core/common/components/window_buttons.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';
import '../components/side_navigation_drawer/side_navigation_drawer.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final ValueNotifier<bool> _isAdmin = ValueNotifier(false);

  @override
  void dispose() {
    _isAdmin.dispose();
    super.dispose();
  }

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
          context
              .read<SideNavigationDrawerBloc>()
              .add(ResetSideNavigationState());
          await windowManager.unmaximize();
          await Future.delayed(const Duration(seconds: 3));
          context.go(RoutingConstants.loginViewRoutePath);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          /// emit these parts later
          if (state is AuthSuccess) {
            // Consume the entity returned by Bloc by converting it to a model
            final userModel =
                SupplyDepartmentEmployeeModel.fromEntity(state.data);

            _isAdmin.value = userModel.role == Role.admin;
          }

          if (state is UserInfoUpdated) {
            final userModel =
                SupplyDepartmentEmployeeModel.fromEntity(state.updatedUser);

            _isAdmin.value = userModel.role == Role.admin;
          }

          RouteChangeManager.handleRouteChange(GoRouter.of(context)
              .routerDelegate
              .currentConfiguration
              .uri
              .toString());

          return Scaffold(
            body: Row(
              children: [
                ValueListenableBuilder(
                    valueListenable: _isAdmin,
                    builder: (context, isAdmin, child) {
                      return _buildSideNavigationDrawer(isAdmin);
                    }),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      right: 20.0,
                      bottom: 20.0,
                      left: 10.0,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        if (state is AuthLoading)
                          LinearProgressIndicator(
                            backgroundColor: Theme.of(context).dividerColor,
                            color: AppColor.accent,
                          ),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// not susceptible to the changes of auth bloc
  Widget _buildHeader() {
    return CustomDragToMoveArea(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder(
              valueListenable: PageTitleNotifier.pageTitle,
              builder: (context, title, child) {
                return Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
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
    );
  }

  Widget _buildSideNavigationDrawer(bool isAdmin) {
    final sidebarItems = [
      const SideBarItem(
        iconSelected: HugeIcons.strokeRoundedDashboardSquare01,
        text: 'Dashboard',
      ),
      const SideBarItem(
        iconSelected: HugeIcons.strokeRoundedDeliveryBox01,
        text: 'Inventory',
      ),
      const SideBarItem(
        iconSelected: HugeIcons.strokeRoundedInvoice01,
        text: 'Purchase Requests',
      ),
      const SideBarItem(
        iconSelected: HugeIcons.strokeRoundedSent,
        text: 'Item Issuance',
      ),
      const SideBarItem(
        iconSelected: HugeIcons.strokeRoundedTimeManagement,
        text: 'Officers Management',
      ),
      if (isAdmin)
        const SideBarItem(
          iconSelected: HugeIcons.strokeRoundedUserGroup,
          text: 'Users Management',
        ),
      if (isAdmin)
        const SideBarItem(
          iconSelected: HugeIcons.strokeRoundedArchive,
          text: 'Archive Management',
        ),
      const SideBarItem(
        iconSelected: HugeIcons.strokeRoundedSettings01,
        text: 'Settings',
      ),
    ];

    return BlocBuilder<SideNavigationDrawerBloc, SideNavigationDrawerState>(
      builder: (context, state) {
        return SideNavigationDrawer(
          isAdmin: isAdmin,
          widthSwitch: 700.0,
          sidebarItems: sidebarItems,
        );
      },
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: widget.child,
    );
  }
}
