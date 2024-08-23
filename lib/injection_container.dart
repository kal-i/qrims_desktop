import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Core Services
import 'core/services/document_service.dart';
import 'core/services/http_service.dart';

// Authentication
import 'features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'features/auth/data/data_sources/remote/auth_remote_data_source_impl.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/user_login.dart';
import 'features/auth/domain/usecases/user_logout.dart';
import 'features/auth/domain/usecases/user_register.dart';
import 'features/auth/domain/usecases/user_reset_password.dart';
import 'features/auth/domain/usecases/user_send_otp.dart';
import 'features/auth/domain/usecases/user_verify_otp.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard
import 'features/dashboard/data/data_sources/remote/user_activity_remote_data_source.dart';
import 'features/dashboard/data/data_sources/remote/user_activity_remote_data_source_impl.dart';
import 'features/dashboard/data/repository/user_activity_repository_impl.dart';
import 'features/dashboard/domain/repository/user_activity_repository.dart';
import 'features/dashboard/domain/usecases/get_user_activities.dart';
import 'features/dashboard/presentation/bloc/user_activity/user_activity_bloc.dart';

// Item Inventory
import 'features/item_inventory/data/data_sources/remote/item_inventory_remote_data_source_impl.dart';
import 'features/item_inventory/data/data_sources/remote/item_inventory_remote_date_source.dart';
import 'features/item_inventory/data/repository/item_inventory_repository_impl.dart';
import 'features/item_inventory/domain/repository/item_inventory_repository.dart';
import 'features/item_inventory/domain/usecases/get_item_by_id.dart';
import 'features/item_inventory/domain/usecases/get_items.dart';
import 'features/item_inventory/domain/usecases/get_paginated_stocks_product_name.dart';
import 'features/item_inventory/domain/usecases/get_stocks.dart';
import 'features/item_inventory/domain/usecases/get_stocks_product_description.dart';
import 'features/item_inventory/domain/usecases/get_stocks_product_name.dart';
import 'features/item_inventory/domain/usecases/register_item.dart';
import 'features/item_inventory/domain/usecases/update_item.dart';
import 'features/item_inventory/presentation/bloc/item_inventory_bloc.dart';
import 'features/item_inventory/presentation/bloc/stock/stock_bloc.dart';

// Navigation
import 'features/navigation/presentation/components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';

// Users Management
import 'features/users_management/data/data_sources/remote/users_management_remote_data_source.dart';
import 'features/users_management/data/data_sources/remote/users_management_remote_data_source_impl.dart';
import 'features/users_management/data/repository/users_management_repository_impl.dart';
import 'features/users_management/domain/repository/users_management_repository.dart';
import 'features/users_management/domain/usecases/get_users.dart';
import 'features/users_management/domain/usecases/update_user_auth_status.dart';
import 'features/users_management/presentation/bloc/users_management_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  _registerCoreDependencies();
  _registerAuthDependencies();
  _registerNavigationDependencies();
  _registerDashboardDependencies();
  _registerItemInventoryDependencies();
  _registerUsersManagementDependencies();
}

/// Core Services
void _registerCoreDependencies() {
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerSingleton<HttpService>(HttpService(serviceLocator()));
  serviceLocator.registerSingleton<DocumentService>(DocumentService());
}

/// Authentication
void _registerAuthDependencies() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<UserRegister>(
    () => UserRegister(authRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UserLogin>(
    () => UserLogin(authRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UserSendOtp>(
    () => UserSendOtp(authRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UserVerifyOtp>(
    () => UserVerifyOtp(authRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UserResetPassword>(
    () => UserResetPassword(authRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UserLogout>(
    () => UserLogout(authRepository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      userRegister: serviceLocator(),
      userLogin: serviceLocator(),
      userSendOtp: serviceLocator(),
      userVerifyOtp: serviceLocator(),
      userResetPassword: serviceLocator(),
      userLogout: serviceLocator(),
      sideNavigationDrawerBloc: serviceLocator(),
    ),
  );
}

/// Navigation
void _registerNavigationDependencies() {
  serviceLocator.registerLazySingleton<SideNavigationDrawerBloc>(
    () => SideNavigationDrawerBloc(),
  );
}

/// Dashboard
void _registerDashboardDependencies() {
  _registerUserActivityDependencies();
}

/// User Activity
void _registerUserActivityDependencies() {
  serviceLocator.registerFactory<UserActivityRemoteDataSource>(
    () => UserActivityRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<UserActivityRepository>(
    () => UserActivityRepositoryImpl(
        userActivityRemoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetUserActivities>(
    () => GetUserActivities(userActivityRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UserActivityBloc>(
    () => UserActivityBloc(getUserActivities: serviceLocator()),
  );
}

/// Item Inventory
void _registerItemInventoryDependencies() {
  serviceLocator.registerFactory<ItemInventoryRemoteDateSource>(
    () => ItemInventoryRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<ItemInventoryRepository>(
    () => ItemInventoryRepositoryImpl(
        itemInventoryRemoteDateSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetItems>(
    () => GetItems(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<RegisterItem>(
    () => RegisterItem(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<GetItemById>(
    () => GetItemById(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateItem>(
    () => UpdateItem(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<ItemInventoryBloc>(
    () => ItemInventoryBloc(
      getItems: serviceLocator(),
      registerItem: serviceLocator(),
      getItemById: serviceLocator(),
      updateItem: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<GetStocks>(
    () => GetStocks(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<GetStocksProductName>(
    () => GetStocksProductName(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<GetStocksProductDescription>(
    () =>
        GetStocksProductDescription(itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<GetPaginatedStocksProductName>(
    () => GetPaginatedStocksProductName(
        itemInventoryRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<StocksBloc>(
    () => StocksBloc(
      getStocks: serviceLocator(),
      getStocksProductName: serviceLocator(),
      getPaginatedStocksProductName: serviceLocator(),
      getStockProductDescription: serviceLocator(),
    ),
  );
}

/// Users Management
void _registerUsersManagementDependencies() {
  serviceLocator.registerFactory<UsersManagementRemoteDataSource>(
        () => UsersManagementRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<UsersManagementRepository>(
        () => UsersManagementRepositoryImpl(
        usersManagementRemoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetUsers>(
        () => GetUsers(usersManagementRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateUserAuthStatus>(
        () => UpdateUserAuthStatus(usersManagementRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UsersManagementBloc>(
        () => UsersManagementBloc(
      getUsers: serviceLocator(),
      updateUserAuthStatus: serviceLocator(),
    ),
  );
}

/// data source
/// repo
/// use case
/// bloc
