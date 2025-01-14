import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_router.dart';
import 'config/sizing/sizing_config.dart';
import 'config/themes/bloc/theme_bloc.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'core/common/components/custom_filled_button/bloc/button_bloc.dart';
import 'core/common/components/search_button/bloc/search_button_bloc.dart';

import 'features/archive/presentation/bloc/archive_user_bloc/archive_users_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/components/custom_auth_password_text_box/bloc/custom_auth_password_text_box_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/inventory_summary/inventory_summary_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/low_stock/low_stock_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/requests_summary/requests_summary_bloc.dart';
import 'features/dashboard/presentation/bloc/user_activity/user_activity_bloc.dart';
import 'features/item_inventory/presentation/bloc/item_inventory_bloc.dart';
import 'features/item_inventory/presentation/bloc/item_suggestions/item_suggestions_bloc.dart';
import 'features/item_issuance/presentation/bloc/issuances_bloc.dart';
import 'features/navigation/presentation/bloc/notifications_bloc.dart';
import 'features/navigation/presentation/components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';
import 'features/officer/presentation/bloc/officers_bloc.dart';
import 'features/purchase_request/presentation/bloc/purchase_requests_bloc.dart';
import 'features/users_management/presentation/bloc/users_management_bloc.dart';
import 'init_dependencies.dart';

// TODO: consider opting for persistent base auth view - done
// pros: perf and reduce codes rebuilt
// cons: tight coupled and complex state management;
// tight coupled - one changes in base auth view will affect the associated views

// TODO: check if the code is still valid even after its expiration // ongoing
// TODO: validate if otp is expired b4 sending a new one

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  //debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();

    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }

    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setResizable(false);
      await windowManager.setMaximizable(false);
      await windowManager.setMinimumSize(const Size(1280, 720));
      await windowManager.center();
      await windowManager.show();
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      SizingConfig().init(constraints);
      return MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc()..add(SetInitialTheme()),
          ),
          BlocProvider<AuthBloc>(
            create: (_) => serviceLocator<AuthBloc>(),
          ),
          BlocProvider<CustomAuthPasswordTextBoxBloc>(
            create: (_) => CustomAuthPasswordTextBoxBloc(),
          ),
          BlocProvider<SideNavigationDrawerBloc>(
            create: (_) => serviceLocator<SideNavigationDrawerBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<InventorySummaryBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<RequestsSummaryBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<LowStockBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<UsersManagementBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<NotificationsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<UserActivityBloc>(),
          ),
          BlocProvider(
            create: (_) => SearchButtonBloc(),
          ),
          BlocProvider(
            create: (_) => ButtonBloc(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<ItemInventoryBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<PurchaseRequestsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<IssuancesBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<ItemSuggestionsBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<ArchiveUsersBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<OfficersBloc>(),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeData>(
          builder: (context, state) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: state,
              routerConfig: AppRoutingConfig.router,
            );
          },
        ),
      );
    });
  }
}
