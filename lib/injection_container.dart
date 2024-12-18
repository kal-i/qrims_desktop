import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Core Services
import 'core/services/document_service.dart';
import 'core/services/entity_suggestions_service.dart';
import 'core/services/http_service.dart';

// Authentication
import 'core/services/item_suggestions_service.dart';
import 'core/services/officer_suggestions_service.dart';
import 'core/services/purchase_request_suggestions_service.dart';
import 'features/archive/data/user/data_sources/remote/archive_users_remote_data_source.dart';
import 'features/archive/data/user/data_sources/remote/archive_users_remote_data_source_impl.dart';
import 'features/archive/data/user/repository/archive_user_repository_impl.dart';
import 'features/archive/domain/users/repository/archive_users_repository.dart';
import 'features/archive/domain/users/usecases/get_archived_users.dart';
import 'features/archive/domain/users/usecases/update_user_archive_status.dart';
import 'features/archive/presentation/bloc/archive_user_bloc/archive_users_bloc.dart';
import 'features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'features/auth/data/data_sources/remote/auth_remote_data_source_impl.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/user_login.dart';
import 'features/auth/domain/usecases/user_logout.dart';
import 'features/auth/domain/usecases/user_register.dart';
import 'features/auth/domain/usecases/user_reset_password.dart';
import 'features/auth/domain/usecases/user_send_otp.dart';
import 'features/auth/domain/usecases/user_update_info.dart';
import 'features/auth/domain/usecases/user_verify_otp.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard
import 'features/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'features/dashboard/data/data_sources/remote/dashboard_remote_data_source_impl.dart';
import 'features/dashboard/data/data_sources/remote/user_activity_remote_data_source.dart';
import 'features/dashboard/data/data_sources/remote/user_activity_remote_data_source_impl.dart';
import 'features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'features/dashboard/data/repository/user_activity_repository_impl.dart';
import 'features/dashboard/domain/repository/dashboard_repository.dart';
import 'features/dashboard/domain/repository/user_activity_repository.dart';
import 'features/dashboard/domain/usecases/get_inventory_summary.dart';
import 'features/dashboard/domain/usecases/get_low_stock_items.dart';
import 'features/dashboard/domain/usecases/get_most_requested_items.dart';
import 'features/dashboard/domain/usecases/get_user_activities.dart';
import 'features/dashboard/presentation/bloc/dashboard/inventory_summary/inventory_summary_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/low_stock/low_stock_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/requests_summary/requests_summary_bloc.dart';
import 'features/dashboard/presentation/bloc/user_activity/user_activity_bloc.dart';

// Item Inventory
import 'features/item_inventory/data/data_sources/remote/item_inventory_remote_data_source_impl.dart';
import 'features/item_inventory/data/data_sources/remote/item_inventory_remote_date_source.dart';
import 'features/item_inventory/data/repository/item_inventory_repository_impl.dart';
import 'features/item_inventory/domain/repository/item_inventory_repository.dart';
import 'features/item_inventory/domain/usecases/get_item_by_id.dart';
import 'features/item_inventory/domain/usecases/get_items.dart';
import 'features/item_inventory/domain/usecases/register_item.dart';
import 'features/item_inventory/domain/usecases/update_item.dart';
import 'features/item_inventory/presentation/bloc/item_inventory_bloc.dart';

// Navigation
import 'features/item_issuance/data/data_sources/remote/issuance_remote_data_source.dart';
import 'features/item_issuance/data/data_sources/remote/issuance_remote_data_source_impl.dart';
import 'features/item_issuance/data/repository/issuance_repository_impl.dart';
import 'features/item_issuance/domain/repository/issuance_repository.dart';
import 'features/item_issuance/domain/usecases/create_ics.dart';
import 'features/item_issuance/domain/usecases/create_par.dart';
import 'features/item_issuance/domain/usecases/get_issuance_by_id.dart';
import 'features/item_issuance/domain/usecases/get_paginated_issuances.dart';
import 'features/item_issuance/domain/usecases/match_item_with_pr.dart';
import 'features/item_issuance/domain/usecases/update_issuance_archive_status.dart';
import 'features/item_issuance/presentation/bloc/issuances_bloc.dart';
import 'features/navigation/data/data/data_sources/remote/notification_remote_data_source.dart';
import 'features/navigation/data/data/data_sources/remote/notification_remote_data_source_impl.dart';
import 'features/navigation/data/data/repository/notification_repository_impl.dart';
import 'features/navigation/domain/domain/repository/notification_repository.dart';
import 'features/navigation/domain/domain/usecases/get_notifications.dart';
import 'features/navigation/domain/domain/usecases/read_notification.dart';
import 'features/navigation/presentation/bloc/notifications_bloc.dart';
import 'features/navigation/presentation/components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';

// Officers Management
import 'features/officer/data/data_sources/remote/officer_remote_data_source.dart';
import 'features/officer/data/data_sources/remote/officer_remote_data_source_impl.dart';
import 'features/officer/data/repository/officer_repository_impl.dart';
import 'features/officer/domain/repository/officer_repository.dart';
import 'features/officer/domain/usecases/get_paginated_officers.dart';
import 'features/officer/domain/usecases/register_officer.dart';
import 'features/officer/domain/usecases/update_officer_archive_status.dart';
import 'features/officer/presentation/bloc/officers_bloc.dart';

/// Purchase Requests
import 'features/purchase_request/data/data_sources/remote/purchase_request_remote_data_source.dart';
import 'features/purchase_request/data/data_sources/remote/purchase_request_remote_data_source_impl.dart';
import 'features/purchase_request/data/repository/purchase_request_repository_impl.dart';
import 'features/purchase_request/domain/repository/purchase_request_repository.dart';
import 'features/purchase_request/domain/usecases/get_paginated_purchase_requests.dart';
import 'features/purchase_request/domain/usecases/get_purchase_request_by_id.dart';
import 'features/purchase_request/domain/usecases/register_purchase_request.dart';
import 'features/purchase_request/domain/usecases/update_purchase_request_status.dart';
import 'features/purchase_request/presentation/bloc/purchase_requests_bloc.dart';

/// Users Management
import 'features/users_management/data/data_sources/remote/users_management_remote_data_source.dart';
import 'features/users_management/data/data_sources/remote/users_management_remote_data_source_impl.dart';
import 'features/users_management/data/repository/users_management_repository_impl.dart';
import 'features/users_management/domain/repository/users_management_repository.dart';
import 'features/users_management/domain/usecases/get_pending_users.dart';
import 'features/users_management/domain/usecases/get_users.dart';
import 'features/users_management/domain/usecases/update_admin_approval_status.dart';
import 'features/users_management/domain/usecases/update_user_auth_status.dart';
import 'features/users_management/domain/usecases/update_user_archive_status.dart';
import 'features/users_management/presentation/bloc/users_management_bloc.dart';

// Archive Management

// Archive User

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  _registerCoreDependencies();
  _registerServicesDependencies();

  _registerAuthDependencies();
  _registerNavigationDependencies();
  _registerDashboardDependencies();
  _registerNotificationDependencies();
  _registerItemInventoryDependencies();
  _registerPurchaseRequestsDependencies();
  _registerItemIssuanceDependencies();
  _registerUsersManagementDependencies();
  _registerOfficersManagementDependencies();
  _registerArchiveManagementDependencies();
}

/// Core Services
void _registerCoreDependencies() {
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerSingleton<HttpService>(HttpService(serviceLocator()));
}

void _registerServicesDependencies() {
  serviceLocator.registerSingleton<DocumentService>(DocumentService());
  serviceLocator.registerSingleton<EntitySuggestionService>(
      EntitySuggestionService(httpService: serviceLocator()));
  serviceLocator.registerSingleton<ItemSuggestionsService>(
      ItemSuggestionsService(httpService: serviceLocator()));
  serviceLocator.registerSingleton<OfficerSuggestionsService>(
      OfficerSuggestionsService(httpService: serviceLocator()));
  serviceLocator.registerSingleton(
      PurchaseRequestSuggestionsService(httpService: serviceLocator()));
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

  serviceLocator.registerFactory<UserUpdateInfo>(
    () => UserUpdateInfo(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      userRegister: serviceLocator(),
      userLogin: serviceLocator(),
      userSendOtp: serviceLocator(),
      userVerifyOtp: serviceLocator(),
      userResetPassword: serviceLocator(),
      userLogout: serviceLocator(),
      userUpdateInfo: serviceLocator(),
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
  serviceLocator.registerFactory<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<DashboardRepository>(
    () => DashboardRepositoryImpl(dashboardRemoteDataSource: serviceLocator()),
  );

  _registerInventorySummaryDependencies();
  _registerRequestsSummaryDependencies();
  _registerLowStockDependencies();
  _registerUserActivityDependencies();
}

void _registerInventorySummaryDependencies() {
  serviceLocator.registerFactory<GetInventorySummary>(
    () => GetInventorySummary(dashboardRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<InventorySummaryBloc>(
    () => InventorySummaryBloc(
      getInventorySummary: serviceLocator(),
    ),
  );
}

void _registerRequestsSummaryDependencies() {
  serviceLocator.registerFactory<GetMostRequestedItems>(
    () => GetMostRequestedItems(dashboardRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<RequestsSummaryBloc>(
    () => RequestsSummaryBloc(
      getMostRequestedItems: serviceLocator(),
    ),
  );
}

void _registerLowStockDependencies() {
  serviceLocator.registerFactory<GetLowStockItems>(
    () => GetLowStockItems(dashboardRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<LowStockBloc>(
    () => LowStockBloc(
      getLowStockItems: serviceLocator(),
    ),
  );
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
}

/// Purchase Request
void _registerPurchaseRequestsDependencies() {
  serviceLocator.registerFactory<PurchaseRequestRemoteDataSource>(
    () => PurchaseRequestRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<PurchaseRequestRepository>(
    () => PurchaseRequestRepositoryImpl(
        purchaseRequestRemoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetPaginatedPurchaseRequests>(
    () => GetPaginatedPurchaseRequests(
        purchaseRequestRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<RegisterPurchaseRequest>(
    () => RegisterPurchaseRequest(purchaseRequestRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdatePurchaseRequestStatus>(
    () => UpdatePurchaseRequestStatus(
        purchaseRequestRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<GetPurchaseRequestById>(
    () => GetPurchaseRequestById(purchaseRequestRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<PurchaseRequestsBloc>(
    () => PurchaseRequestsBloc(
      getPaginatedPurchaseRequests: serviceLocator(),
      registerPurchaseRequest: serviceLocator(),
      updatePurchaseRequestStatus: serviceLocator(),
      getPurchaseRequestById: serviceLocator(),
    ),
  );
}

/// Item Issuance
void _registerItemIssuanceDependencies() {
  serviceLocator.registerFactory<IssuanceRemoteDataSource>(
    () => IssuanceRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<IssuanceRepository>(
    () => IssuanceRepositoryImpl(issuanceRemoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetIssuanceById>(
    () => GetIssuanceById(issuanceRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<GetPaginatedIssuances>(
    () => GetPaginatedIssuances(issuanceRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<MatchItemWithPr>(
    () => MatchItemWithPr(issuanceRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<CreateICS>(
    () => CreateICS(issuanceRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<CreatePAR>(
    () => CreatePAR(issuanceRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateIssuanceArchiveStatus>(
        () => UpdateIssuanceArchiveStatus(issuanceRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<IssuancesBloc>(
    () => IssuancesBloc(
      getIssuanceById: serviceLocator(),
      getPaginatedIssuances: serviceLocator(),
      matchItemWithPr: serviceLocator(),
      createICS: serviceLocator(),
      createPAR: serviceLocator(),
      updateIssuanceArchiveStatus: serviceLocator(),
    ),
  );
}

/// Officers Management
void _registerOfficersManagementDependencies() {
  serviceLocator.registerFactory<OfficerRemoteDataSource>(
    () => OfficerRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<OfficerRepository>(
    () => OfficerRepositoryImpl(officerRemoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetPaginatedOfficers>(
    () => GetPaginatedOfficers(officerRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<RegisterOfficer>(
    () => RegisterOfficer(officerRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateOfficerArchiveStatus>(
    () => UpdateOfficerArchiveStatus(officerRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<OfficersBloc>(
    () => OfficersBloc(
      getPaginatedOfficers: serviceLocator(),
      registerOfficer: serviceLocator(),
      updateOfficerArchiveStatus: serviceLocator(),
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

  serviceLocator.registerFactory<GetPendingUsers>(
    () => GetPendingUsers(usersManagementRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateUserAuthStatus>(
    () => UpdateUserAuthStatus(usersManagementRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateUserArchiveStatus>(
    () => UpdateUserArchiveStatus(usersManagementRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UpdateAdminApprovalStatus>(
    () =>
        UpdateAdminApprovalStatus(usersManagementRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<UsersManagementBloc>(
    () => UsersManagementBloc(
      getUsers: serviceLocator(),
      getPendingUsers: serviceLocator(),
      updateUserAuthStatus: serviceLocator(),
      updateUserArchiveStatus: serviceLocator(),
      updateAdminApprovalStatus: serviceLocator(),
    ),
  );
}

/// Archive Management
void _registerArchiveManagementDependencies() {
  _registerArchiveUsersDependencies();
}

/// Archive User
void _registerArchiveUsersDependencies() {
  serviceLocator.registerFactory<ArchiveUsersRemoteDataSource>(
    () => ArchiveUsersRemoteDataSourceImpl(httpService: serviceLocator()),
  );
  serviceLocator.registerFactory<ArchiveUsersRepository>(
    () => ArchiveUsersRepositoryImpl(
        archiveUserRemoteDataSource: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => GetArchivedUsers(archiveUserRepository: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => UpdateUserIsArchiveStatus(archiveUserRepository: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => ArchiveUsersBloc(
      getArchivedUsers: serviceLocator(),
      updateUserArchiveStatus: serviceLocator(),
    ),
  );
}

/// Notification
void _registerNotificationDependencies() {
  serviceLocator.registerFactory<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(httpService: serviceLocator()),
  );

  serviceLocator.registerFactory<NotificationRepository>(
    () => NotificationRepositoryImpl(
        notificationRemoteDataSource: serviceLocator()),
  );

  serviceLocator.registerFactory<GetNotifications>(
    () => GetNotifications(notificationRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<ReadNotification>(
    () => ReadNotification(notificationRepository: serviceLocator()),
  );

  serviceLocator.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(
      getNotifications: serviceLocator(),
      readNotification: serviceLocator(),
    ),
  );
}

/// data source
/// repo
/// use case
/// bloc
