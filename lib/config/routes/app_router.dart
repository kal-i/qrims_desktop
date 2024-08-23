import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/verification_purpose.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/otp_verification_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/set_new_password_view.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/item_inventory/presentation/views/item_inventory_view.dart';
import '../../features/item_inventory/presentation/views/register_item_view.dart';
import '../../features/item_inventory/presentation/views/reusable_item_view.dart';
import '../../features/item_issuance/presentation/views/item_issuance_view.dart';
import '../../features/navigation/presentation/views/navigation_view.dart';
import '../../features/settings/presentation/views/settings_view.dart';
import '../../features/users_management/presentation/views/users_management_view.dart';
import 'app_routing_constants.dart';

class AppRoutingConfig {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutingConstants.loginViewRoutePath,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: RouteChangeManager.pageTitle,
    routes: [
      GoRoute(
        name: RoutingConstants.loginViewRouteName,
        path: RoutingConstants.loginViewRoutePath,
        pageBuilder: (context, state) => const MaterialPage(child: LoginView()),
      ),
      GoRoute(
        name: RoutingConstants.registerViewRouteName,
        path: RoutingConstants.registerViewRoutePath,
        pageBuilder: (context, state) =>
            const MaterialPage(child: RegisterView()),
      ),
      GoRoute(
        name: RoutingConstants.forgotPasswordViewRouteName,
        path: RoutingConstants.forgotPasswordViewRoutePath,
        pageBuilder: (context, state) =>
            const MaterialPage(child: ForgotPasswordView()),
      ),
      GoRoute(
        name: RoutingConstants.otpVerificationViewRouteName,
        path: RoutingConstants.otpVerificationViewRoutePath,
        pageBuilder: (context, state) {
          final Map<String, dynamic> extras =
              state.extra as Map<String, dynamic>;
          final email = extras['email'] as String;
          final purpose = extras['purpose'] as VerificationPurpose;

          return MaterialPage(
              child: OtpVerificationView(
            email: email,
            purpose: purpose,
          ));
        },
      ),
      GoRoute(
        name: RoutingConstants.setUpNewPasswordViewRouteName,
        path: RoutingConstants.setUpNewPasswordViewRoutePath,
        pageBuilder: (context, state) => MaterialPage(
            child: SetNewPasswordView(
          email: state.extra as String,
        )),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return MaterialPage(
            child: NavigationView(
              child: child,
            ),
          );
        },
        routes: [
          GoRoute(
            name: RoutingConstants.dashboardViewRouteName,
            path: RoutingConstants.dashboardViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: DashboardView()),
          ),
          GoRoute(
            name: RoutingConstants.itemInventoryViewRouteName,
            path: RoutingConstants.itemInventoryViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: ItemInventoryView()),
            routes: [
              GoRoute(
                name: RoutingConstants.viewItemRouteName,
                path: RoutingConstants.viewItemRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                  state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as int?;

                  return MaterialPage(
                    child: ReusableItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.registerItemViewRouteName,
                path: RoutingConstants.registerItemViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                  state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as int?;

                  return MaterialPage(
                    child: ReusableItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.updateItemViewRouteName,
                path: RoutingConstants.updateItemViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as int?;

                  return MaterialPage(
                    child: ReusableItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: RoutingConstants.itemIssuanceViewRouteName,
            path: RoutingConstants.itemIssuanceViewRoutePath,
            pageBuilder: (context, state) =>
            const MaterialPage(child: ItemIssuanceView()),
          ),
          GoRoute(
            name: RoutingConstants.usersManagementViewRouteName,
            path: RoutingConstants.usersManagementViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: UsersManagementView()),
          ),
          GoRoute(
            name: RoutingConstants.settingsViewRouteName,
            path: RoutingConstants.settingsViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: SettingsView()),
          ),
        ],
      ),
    ],
  );
}

class RouteChangeManager {
  static final ValueNotifier<String> pageTitle = ValueNotifier<String>('Page');

  static void handleRouteChange(String path) {
    PageTitleNotifier.pageTitle.value = _getPageTitle(path);
    // Add more logic as needed, like window size or state updates
  }

  static String _getPageTitle(String path) {
    final Map<String, String> routeTitles = {
      '/dashboard': 'Dashboard',
      '/itemInventory': 'Inventory',
      '/itemInventory/viewItem': 'View Item Information',
      '/itemInventory/registerItem': 'Register Item',
      '/itemInventory/updateItem': 'Update Item',
      '/itemIssuance': 'Item Issuance Management',
      '/usersManagement': 'User Management',
      '/settings': 'Settings',
    };
    return routeTitles[path] ?? 'Page';
  }
}

class PageTitleNotifier {
  static final ValueNotifier<String> pageTitle = ValueNotifier<String>('Page');
}
