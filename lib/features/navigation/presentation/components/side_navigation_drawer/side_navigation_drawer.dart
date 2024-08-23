import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../config/routes/app_routing_constants.dart';
import '../../../../../config/themes/app_color.dart';
import '../../../../../core/common/components/reusable_popup_menu_button.dart';
import '../../../../../core/constants/assets_path.dart';
import '../../../../../core/entities/supply_department_employee.dart';
import '../../../../../core/utils/capitalizer.dart';
import '../../../../../core/utils/readable_enum_converter.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import 'bloc/side_navigation_drawer_bloc.dart';

/// If I want to further customize the appearance, I could change the border radius and margin later on
class SideNavigationDrawer extends StatelessWidget {
  const SideNavigationDrawer({
    super.key,
    //required this.onTap,
    required this.isAdmin,
    this.sideBarColor = const Color(0xff1D1D1D),
    this.sideBarAnimationDuration = const Duration(milliseconds: 700),
    this.floatingAnimationDuration = const Duration(milliseconds: 500),
    this.animatedContainerColor = const Color(0xff323232),
    this.selectedIconColor = Colors.white,
    this.unselectedIconColor = const Color(0xffA0A5A9),
    this.dividerColor = const Color(0xff929292),
    this.hoverColor = Colors.black38,
    this.splashColor = Colors.black87,
    this.highlightColor = Colors.black,
    this.unSelectedTextColor = const Color(0xffA0A5A9),
    required this.widthSwitch,
    this.borderRadius = 10.0, // 0.0
    this.sideBarWidth = 260.0,
    this.sideBarSmallWidth = 84.0,
    this.mainLogoImage,
    required this.sidebarItems,
    this.settingsDivider = true,
    this.curve = Curves.easeOut,
    this.textStyle = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 16.0,
      color: Colors.white,
    ),
  });

  //final Function() onTap;
  final bool isAdmin;
  final Color sideBarColor;
  final Duration sideBarAnimationDuration;
  final Duration floatingAnimationDuration;
  final Color animatedContainerColor;
  final Color selectedIconColor;
  final Color unselectedIconColor;
  final Color dividerColor;
  final Color hoverColor;
  final Color splashColor;
  final Color highlightColor;
  final Color unSelectedTextColor;
  final double widthSwitch;
  final double borderRadius;
  final double sideBarWidth;
  final double sideBarSmallWidth;
  final String? mainLogoImage;
  final List<SideBarItem> sidebarItems;
  final bool settingsDivider;
  final Curve curve;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    const sideBarItemHeight = 48.0;

    // final filteredItems = sidebarItems.where((item) {
    //   if (item.text == 'User Management' && !isAdmin) {
    //     return false;
    //   }
    //   return true;
    // });

    return BlocBuilder<SideNavigationDrawerBloc, SideNavigationDrawerState>(
      builder: (context, sideNavState) {
        return AnimatedContainer(
          curve: curve,
          height: height,
          margin: const EdgeInsets.all(10.0),
          width: width >= widthSwitch && !sideNavState.isMinimized
              ? sideBarWidth
              : sideBarSmallWidth,
          decoration: BoxDecoration(
            color: sideBarColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          duration: sideBarAnimationDuration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Profile Section
              BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
                String name = 'Unknown';
                String role = 'Unknown';
                Uint8List? profile;

                if (authState is AuthSuccess) {
                  final userData = authState.data;

                  if (userData is SupplyDepartmentEmployeeEntity) {
                    name = capitalizeWord(userData.name);
                    role = readableEnumConverter(userData.role);
                    profile = userData.profileImage;
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(
                    top: 40,
                    left: width >= widthSwitch && !sideNavState.isMinimized
                        ? 20
                        : 18,
                    right: width >= widthSwitch && !sideNavState.isMinimized
                        ? 20
                        : 18,
                    bottom: 24,
                  ),
                  child: Row(
                    children: [
                      // Profile Image
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: width >= widthSwitch &&
                                    !sideNavState.isMinimized
                                ? 48.0
                                : 32.0, // Adjust size as needed
                            height: width >= widthSwitch &&
                                    !sideNavState.isMinimized
                                ? 48.0
                                : 32.0, // Adjust size as needed
                            decoration: BoxDecoration(
                              shape: BoxShape
                                  .rectangle, // Use rectangle for custom container
                              borderRadius:
                                  BorderRadius.circular(10.0), // Border radius
                              image: DecorationImage(
                                image: profile != null
                                    ? MemoryImage(profile)
                                    : const AssetImage(ImagePath.profile)
                                        as ImageProvider,
                                fit: BoxFit.cover, // Adjust as needed
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Profile Name and Role
                      if (width >= widthSwitch && !sideNavState.isMinimized)
                        Expanded(
                          flex: 2,
                          child: AnimatedAlign(
                            alignment: Alignment.centerLeft,
                            curve: curve,
                            duration: sideBarAnimationDuration,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalizeWord(name),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: AppColor.lightPrimary,
                                        ),
                                  ),
                                  Text(
                                    readableEnumConverter(role),
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // chevron icon
                      if (width >= widthSwitch && !sideNavState.isMinimized)
                        ReusablePopupMenuButton(
                          tooltip: 'Manage Account',
                          icon: const Icon(
                            CupertinoIcons.chevron_up_chevron_down,
                            size: 16.0,
                          ),
                          onSelected: (String? value) async {
                            if (value == 'Logout') {
                              print(value);
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('authToken');
                              print(token);
                              context.read<AuthBloc>().add(
                                AuthLogout(
                                  token: token!,
                                ),
                              );
                              print(token);
                            } else if (value == 'Profile') {
                              print('profile');
                            }
                          },
                          popupMenuItems: [
                            ReusablePopupMenuButton
                                .reusableListTilePopupMenuItem(
                              context: context,
                              value: 'View Profile',
                              title: 'View Profile',
                              icon: Icons.manage_accounts_outlined,
                            ),
                            ReusablePopupMenuButton
                                .reusableListTilePopupMenuItem(
                              context: context,
                              value: 'Account Settings',
                              title: 'Account Settings',
                              icon: Icons.settings_outlined,
                            ),
                            ReusablePopupMenuButton
                                .reusableListTilePopupMenuItem(
                              context: context,
                              value: 'Logout',
                              title: 'Logout',
                              icon: Icons.logout_outlined,
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),

              /// Side Navigation Items
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: 40,
                    left: width >= widthSwitch && !sideNavState.isMinimized
                        ? 20
                        : 18,
                    right: width >= widthSwitch && !sideNavState.isMinimized
                        ? 20
                        : 18,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 786.0,
                        child: Stack(
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sidebarItems.length,
                              itemBuilder: (context, index) {
                                return sideBarItem(
                                  icon: sidebarItems[index].iconSelected,
                                  text: sidebarItems[index].text,
                                  width: width,
                                  widthSwitch: widthSwitch,
                                  minimize: sideNavState.isMinimized,
                                  height: sideBarItemHeight,
                                  hoverColor: hoverColor,
                                  unselectedIconColor: unselectedIconColor,
                                  splashColor: splashColor,
                                  highlightColor: highlightColor,
                                  unselectedTextColor: unSelectedTextColor,
                                  onTap: () {
                                    context
                                        .read<SideNavigationDrawerBloc>()
                                        .add(SideNavigationItemTapped(
                                            index: index));
                                    _onItemTapped(context, isAdmin, index);
                                  },
                                  textStyle: textStyle,
                                );
                              },
                              separatorBuilder: (context, index) {
                                if (index == sidebarItems.length - 2 &&
                                    settingsDivider) {
                                  return Divider(
                                    height: 12.0,
                                    thickness: 0.2,
                                    color: dividerColor,
                                  );
                                } else {
                                  return const SizedBox(
                                    height: 8.0,
                                  );
                                }
                              },
                            ),
                            AnimatedAlign(
                              alignment: Alignment(
                                0,
                                -1 -
                                    (-0.152 *
                                        sideNavState.selectedIndex.toDouble()),
                              ),
                              curve: curve,
                              duration: floatingAnimationDuration,
                              child: Container(
                                height: sideBarItemHeight,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: animatedContainerColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListView(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Icon(
                                      sidebarItems[sideNavState.selectedIndex]
                                          .iconSelected,
                                      color: Colors.white,
                                    ),
                                    if (width >= widthSwitch &&
                                        !sideNavState.isMinimized)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          sidebarItems[
                                                  sideNavState.selectedIndex]
                                              .text,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (width >= widthSwitch)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 24.0),
                  child: IconButton(
                    hoverColor: Colors.black38,
                    splashColor: Colors.black87,
                    highlightColor: Colors.black,
                    onPressed: () => context
                        .read<SideNavigationDrawerBloc>()
                        .add(SideNavigationToggleMinimize()),
                    icon: Icon(
                      width >= widthSwitch && sideNavState.isMinimized
                          ? Icons.arrow_forward_ios_outlined
                          : Icons.space_dashboard_outlined,
                      color: selectedIconColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(BuildContext context, bool isAdmin, int index,) {
    List<String> routes = [
      RoutingConstants.dashboardViewRoutePath,
      RoutingConstants.itemInventoryViewRoutePath,
      RoutingConstants.itemIssuanceViewRoutePath,
      if (isAdmin)
        RoutingConstants.usersManagementViewRoutePath,
      RoutingConstants.settingsViewRoutePath,
    ];

    if (index < 0 || index >= routes.length) {
      print('Invalid index: $index');
      return;
    }

    context.go(routes[index]);
  }
}

/// Helper method to create a side bar item
Widget sideBarItem({
  required IconData icon,
  required String text,
  required double width,
  required double widthSwitch,
  required bool minimize,
  required double height,
  required Color hoverColor,
  required Color unselectedIconColor,
  required Color splashColor,
  required Color highlightColor,
  required Color unselectedTextColor,
  required Function() onTap,
  required TextStyle textStyle,
}) {
  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12.0),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    child: InkWell(
      onTap: onTap,
      hoverColor: hoverColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: SizedBox(
        height: height,
        child: ListView(
          padding: const EdgeInsets.all(12.0),
          shrinkWrap: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          scrollDirection: Axis.horizontal,
          children: [
            Icon(
              icon,
              color: unselectedIconColor,
            ),
            if (width >= widthSwitch && !minimize)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  text,
                  overflow: TextOverflow.clip,
                  style: textStyle.copyWith(
                    color: unselectedIconColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class SideBarItem {
  const SideBarItem({
    required this.iconSelected,
    required this.text,
    this.iconUnselected,
  });

  final IconData iconSelected;
  final IconData? iconUnselected;
  final String text;
}
