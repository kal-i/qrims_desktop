import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/issuance_type.dart';
import '../../core/enums/verification_purpose.dart';
import '../../features/archive/presentation/views/archive_issuances_view.dart';
import '../../features/archive/presentation/views/archive_officers_view.dart';
import '../../features/archive/presentation/views/archive_users_view.dart';
import '../../features/archive/presentation/views/archive_view.dart';
import '../../features/auth/presentation/views/base_auth_view.dart';
import '../../features/auth/presentation/views/change_email_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/otp_verification_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/set_new_password_view.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/item_inventory/presentation/views/item_inventory_view.dart';
import '../../features/item_inventory/presentation/views/reusable_inventory_item_view.dart';
import '../../features/item_inventory/presentation/views/reusable_supply_item_view.dart';
import '../../features/item_issuance/presentation/views/item_issuance_view.dart';
import '../../features/item_issuance/presentation/views/officer_accountability_view.dart';
import '../../features/item_issuance/presentation/views/register_multiple_issuance_view.dart';
import '../../features/item_issuance/presentation/views/reusable_item_issuance_view.dart';
import '../../features/item_issuance/presentation/views/view_issuance_information.dart';
import '../../features/navigation/presentation/views/navigation_view.dart';
import '../../features/officer/presentation/views/officers_management_view.dart';
import '../../features/purchase_request/presentation/view/create_purchase_order_view.dart';
import '../../features/purchase_request/presentation/view/purchase_request_reusable_view.dart';
import '../../features/purchase_request/presentation/view/purchase_request_view.dart';
import '../../features/settings/presentation/views/account_profile_view.dart';
import '../../features/settings/presentation/views/general_setting_view.dart';
import '../../features/settings/presentation/views/settings_view.dart';
import '../../features/users_management/presentation/views/users_management_view.dart';
import 'app_routing_constants.dart';

/// shell route is only necessary for persistent nav
class AppRoutingConfig {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _baseAuthShellNavigatorKey = GlobalKey<NavigatorState>();
  static final _baseNavigationShellNavigatorKey = GlobalKey<NavigatorState>();
  static final _officersManagementShellNavigationKey =
      GlobalKey<NavigatorState>();
  static final _archiveManagementShellNavigationKey =
      GlobalKey<NavigatorState>();
  static final _settingsShellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutingConstants.loginViewRoutePath,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: RouteChangeManager.pageTitle,
    routes: [
      ShellRoute(
        navigatorKey: _baseAuthShellNavigatorKey,
        pageBuilder: (context, state, child) {
          return MaterialPage(
            child: BaseAuthView(
              child: child,
            ),
          );
        },
        routes: [
          GoRoute(
            name: RoutingConstants.loginViewRouteName,
            path: RoutingConstants.loginViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: LoginView()),
          ),
          GoRoute(
            name: RoutingConstants.registerViewRouteName,
            path: RoutingConstants.registerViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: RegisterView()),
          ),
          GoRoute(
            name: RoutingConstants.changeEmailViewRouteName,
            path: RoutingConstants.changeEmailViewRoutePath,
            pageBuilder: (context, state) => MaterialPage(
              child: ChangeEmailView(
                purpose: state.extra as VerificationPurpose,
              ),
            ),
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
                ),
              );
            },
          ),
          GoRoute(
            name: RoutingConstants.setUpNewPasswordViewRouteName,
            path: RoutingConstants.setUpNewPasswordViewRoutePath,
            pageBuilder: (context, state) => MaterialPage(
              child: SetNewPasswordView(
                email: state.extra as String,
              ),
            ),
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: _baseNavigationShellNavigatorKey,
        pageBuilder: (context, state, child) {
          return MaterialPage(
            child: NavigationView(
              child: child,
            ),
          );
        },
        routes: [
          /// dashboard
          GoRoute(
            name: RoutingConstants.dashboardViewRouteName,
            path: RoutingConstants.dashboardViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: DashboardView()),
          ),

          /// item inventory management
          GoRoute(
            name: RoutingConstants.itemInventoryViewRouteName,
            path: RoutingConstants.itemInventoryViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: ItemInventoryView()),
            routes: [
              GoRoute(
                name: RoutingConstants.viewSupplyItemRouteName,
                path: RoutingConstants.viewSupplyItemRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as String?;

                  return MaterialPage(
                    child: ReusableSupplyItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.viewInventoryItemRouteName,
                path: RoutingConstants.viewInventoryItemRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as String?;

                  return MaterialPage(
                    child: ReusableInventoryItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.registerSupplyItemViewRouteName,
                path: RoutingConstants.registerSupplyItemViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as String?;

                  return MaterialPage(
                    child: ReusableSupplyItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.registerInventoryItemViewRouteName,
                path: RoutingConstants.registerInventoryItemViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as String?;

                  return MaterialPage(
                    child: ReusableInventoryItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.updateSupplyItemViewRouteName,
                path: RoutingConstants.updateSupplyItemViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as String?;

                  return MaterialPage(
                    child: ReusableSupplyItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.updateInventoryItemViewRouteName,
                path: RoutingConstants.updateInventoryItemViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final isUpdate = extras['is_update'] as bool;
                  final itemId = extras['item_id'] as String?;

                  return MaterialPage(
                    child: ReusableInventoryItemView(
                      isUpdate: isUpdate,
                      itemId: itemId,
                    ),
                  );
                },
              ),
            ],
          ),

          /// purchase request
          GoRoute(
            name: RoutingConstants.purchaseRequestViewRouteName,
            path: RoutingConstants.purchaseRequestViewRoutePath,
            pageBuilder: (context, state) {
              return const MaterialPage(
                child: PurchaseRequestView(),
              );
            },
            routes: [
              GoRoute(
                name: RoutingConstants.registerPurchaseRequestViewRouteName,
                path: RoutingConstants.registerPurchaseRequestViewRoutePath,
                pageBuilder: (context, state) {
                  return const MaterialPage(
                    child: PurchaseRequestReusableView(),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.viewPurchaseRequestRouteName,
                path: RoutingConstants.viewPurchaseRequestRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final prId = extras['pr_id'] as String;

                  return MaterialPage(
                    child: PurchaseRequestReusableView(
                      prId: prId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.registerPurchaseOrderViewRouteName,
                path: RoutingConstants.registerPurchaseOrderViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final prId = extras['pr_id'] as String;

                  return MaterialPage(
                    child: CreatePurchaseOrderView(
                      prId: prId,
                    ),
                  );
                },
              ),
            ],
          ),

          /// purchase order
          // GoRoute(
          //   name: RoutingConstants.purchaseOrderViewRouteName,
          //   path: RoutingConstants.purchaseOrderViewRoutePath,
          //   pageBuilder: (context, state) =>
          //   const MaterialPage(child: PurchaseOrderView()),
          // ),

          /// item issuance management
          GoRoute(
            name: RoutingConstants.itemIssuanceViewRouteName,
            path: RoutingConstants.itemIssuanceViewRoutePath,
            pageBuilder: (context, state) => const MaterialPage(
              child: ItemIssuanceView(),
            ),
            routes: [
              GoRoute(
                name: RoutingConstants.registerItemIssuanceViewRouteName,
                path: RoutingConstants.registerItemIssuanceViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final type = extras['type'] as IssuanceType;
                  final prId = extras['pr_id'] as String;

                  return MaterialPage(
                    child: ReusableItemIssuanceView(
                      issuanceType: type,
                      prId: prId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.registerMultipleIssuanceViewRouteName,
                path: RoutingConstants.registerMultipleIssuanceViewRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final type = extras['type'] as IssuanceType;

                  return MaterialPage(
                    child: RegisterMultipleIssuanceView(
                      issuanceType: type,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.viewItemIssuanceRouteName,
                path: RoutingConstants.viewItemIssuanceRoutePath,
                pageBuilder: (context, state) {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final issuanceId = extras['issuance_id'] as String;

                  return MaterialPage(
                    child: ViewIssuanceInformation(
                      issuanceId: issuanceId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: RoutingConstants.viewOfficerAccountabilityRouteName,
                path: RoutingConstants.viewOfficerAccountabilityRoutePath,
                pageBuilder: (context, state) {
                  return const MaterialPage(
                    child: OfficerAccountabilityView(),
                  );
                },
              ),
            ],
          ),

          /// user management
          GoRoute(
            name: RoutingConstants.usersManagementViewRouteName,
            path: RoutingConstants.usersManagementViewRoutePath,
            pageBuilder: (context, state) =>
                const MaterialPage(child: UsersManagementView()),
          ),

          /// officer management
          GoRoute(
            name: RoutingConstants.officersManagementViewRouteName,
            path: RoutingConstants.officersManagementViewRoutePath,
            pageBuilder: (context, state) => const MaterialPage(
              child: OfficersManagementView(),
            ),
          ),

          /// archive management
          ShellRoute(
            navigatorKey: _archiveManagementShellNavigationKey,
            pageBuilder: (context, state, child) => MaterialPage(
              child: BaseArchiveView(
                child: child,
              ),
            ),
            routes: [
              GoRoute(
                name: RoutingConstants.archiveUserViewRouteName,
                path: RoutingConstants.archiveUserViewRoutePath,
                pageBuilder: (context, state) => const MaterialPage(
                  child: ArchiveUsersView(),
                ),
              ),
              GoRoute(
                name: RoutingConstants.archiveOfficerViewRouteName,
                path: RoutingConstants.archiveOfficerViewRoutePath,
                pageBuilder: (context, state) => const MaterialPage(
                  child: ArchiveOfficersView(),
                ),
              ),
              GoRoute(
                name: RoutingConstants.archiveIssuanceViewRouteName,
                path: RoutingConstants.archiveIssuanceViewRoutePath,
                pageBuilder: (context, state) => const MaterialPage(
                  child: ArchiveIssuancesView(),
                ),
              ),
            ],
          ),

          /// settings
          ShellRoute(
            navigatorKey: _settingsShellNavigatorKey,
            pageBuilder: (context, state, child) => MaterialPage(
              child: SettingsView(
                child: child,
              ),
            ),
            routes: [
              GoRoute(
                name: RoutingConstants.generalSettingViewRouteName,
                path: RoutingConstants.generalSettingViewRoutePath,
                pageBuilder: (context, state) =>
                    const MaterialPage(child: GeneralSettingView()),
              ),
              GoRoute(
                name: RoutingConstants.accountProfileViewRouteName,
                path: RoutingConstants.accountProfileViewRoutePath,
                pageBuilder: (context, state) =>
                    const MaterialPage(child: AccountProfileView()),
              ),
            ],
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
      '/itemInventory': 'Inventory Management',
      '/itemInventory/viewItem': 'View Item Information',
      '/itemInventory/viewSupplyItem': 'View Supply Item Information',
      '/itemInventory/viewInventoryItem': 'View Inventory Item Information',
      '/itemInventory/registerItem': 'Register Item',
      '/itemInventory/registerSupplyItem': 'Register Supply Item',
      '/itemInventory/registerInventoryItem': 'Register Inventory Item',
      '/itemInventory/updateItem': 'Update Item',
      '/itemInventory/updateSupplyItem': 'Update Supply Item',
      '/itemInventory/updateInventoryItem': 'Update Inventory Item',
      '/purchaseRequest': 'Purchase Request',
      '/purchaseRequest/viewPurchaseRequest': 'View Purchase Request',
      '/purchaseRequest/registerPurchaseRequest': 'Register Purchase Request',
      //'/purchaseOrder': 'Purchase Order',
      '/itemIssuance': 'Item Issuance Management',
      '/itemIssuance/viewItemIssuance': 'View Item Issuance',
      '/itemIssuance/registerItemIssuance': 'Create Issuance',
      '/itemIssuance/registerMultipleItemIssuance': 'Create Issuance',
      '/itemIssuance/viewOfficerAccountability': 'View Officer Accountability',

      '/usersManagement': 'User Management',
      '/officersManagement': 'Officers Management',
      '/archiveUser': 'Archive Management',
      '/archiveOfficer': 'Archive Management',
      '/archiveIssuance': 'Archive Management',
      '/general': 'General Settings',
      '/accountProfile': 'Account Profile Settings',
    };
    return routeTitles[path] ?? 'Page';
  }
}

class PageTitleNotifier {
  static final ValueNotifier<String> pageTitle = ValueNotifier<String>('Page');
}

/// use shell route when need to have a base view
