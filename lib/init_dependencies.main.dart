part of 'init_dependencies.dart';

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

void _registerCoreDependencies() {
  serviceLocator
    ..registerSingleton<Dio>(
      Dio(),
    )
    ..registerSingleton<HttpService>(
      HttpService(
        serviceLocator(),
      ),
    );
}

void _registerServicesDependencies() {
  serviceLocator
    ..registerSingleton<FontService>(
      FontService(),
    )
    ..registerSingleton<ImageService>(
      ImageService(),
    )
    ..registerSingleton<DocumentService>(
      DocumentService(
        fontService: serviceLocator(),
        imageService: serviceLocator(),
      ),
    )
    ..registerSingleton<EntitySuggestionService>(
      EntitySuggestionService(
        httpService: serviceLocator(),
      ),
    )
    ..registerSingleton<ItemSuggestionsService>(
      ItemSuggestionsService(
        httpService: serviceLocator(),
      ),
    )
    ..registerSingleton<OfficerSuggestionsService>(
      OfficerSuggestionsService(
        httpService: serviceLocator(),
      ),
    )
    ..registerSingleton(
      PurchaseRequestSuggestionsService(
        httpService: serviceLocator(),
      ),
    );
}

void _registerAuthDependencies() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<UserRegister>(
      () => UserRegister(
        authRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserLogin>(
      () => UserLogin(
        authRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserSendOtp>(
      () => UserSendOtp(
        authRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserVerifyOtp>(
      () => UserVerifyOtp(
        authRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserResetPassword>(
      () => UserResetPassword(
        authRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserLogout>(
      () => UserLogout(
        authRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserUpdateInfo>(
      () => UserUpdateInfo(
        authRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<AuthBloc>(
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

void _registerNavigationDependencies() {
  serviceLocator.registerLazySingleton<SideNavigationDrawerBloc>(
    () => SideNavigationDrawerBloc(),
  );
}

void _registerDashboardDependencies() {
  serviceLocator
    ..registerFactory<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<DashboardRepository>(
      () => DashboardRepositoryImpl(
        dashboardRemoteDataSource: serviceLocator(),
      ),
    );

  _registerInventorySummaryDependencies();
  _registerRequestsSummaryDependencies();
  _registerLowStockDependencies();
  _registerOutOfStockDependencies();
  _registerUserActivityDependencies();
}

void _registerInventorySummaryDependencies() {
  serviceLocator
    ..registerFactory<GetInventorySummary>(
      () => GetInventorySummary(
        dashboardRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<InventorySummaryBloc>(
      () => InventorySummaryBloc(
        getInventorySummary: serviceLocator(),
      ),
    );
}

void _registerRequestsSummaryDependencies() {
  serviceLocator
    ..registerFactory<GetRequestsSummary>(
      () => GetRequestsSummary(
        dashboardRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<RequestsSummaryBloc>(
      () => RequestsSummaryBloc(
        getRequestsSummary: serviceLocator(),
      ),
    );
}

void _registerOutOfStockDependencies() {
  serviceLocator
    ..registerFactory<GetOutOfStockItems>(
      () => GetOutOfStockItems(
        dashboardRepository: serviceLocator(),
      ),
    )
    ..registerFactory<OutOfStockBloc>(
      () => OutOfStockBloc(
        getOutOfStockItems: serviceLocator(),
      ),
    );
}

void _registerLowStockDependencies() {
  serviceLocator
    ..registerFactory<GetLowStockItems>(
      () => GetLowStockItems(
        dashboardRepository: serviceLocator(),
      ),
    )
    ..registerFactory<LowStockBloc>(
      () => LowStockBloc(
        getLowStockItems: serviceLocator(),
      ),
    );
}

void _registerUserActivityDependencies() {
  serviceLocator
    ..registerFactory<UserActivityRemoteDataSource>(
      () => UserActivityRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<UserActivityRepository>(
      () => UserActivityRepositoryImpl(
        userActivityRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetUserActivities>(
      () => GetUserActivities(
        userActivityRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UserActivityBloc>(
      () => UserActivityBloc(
        getUserActivities: serviceLocator(),
      ),
    );
}

void _registerItemInventoryDependencies() {
  serviceLocator
    ..registerFactory<ItemInventoryRemoteDateSource>(
      () => ItemInventoryRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<ItemInventoryRepository>(
      () => ItemInventoryRepositoryImpl(
        itemInventoryRemoteDateSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetItems>(
      () => GetItems(
        itemInventoryRepository: serviceLocator(),
      ),
    )
    ..registerFactory<RegisterSupplyItem>(
      () => RegisterSupplyItem(
        itemInventoryRepository: serviceLocator(),
      ),
    )
    ..registerFactory<RegisterEquipmentItem>(
      () => RegisterEquipmentItem(
        itemInventoryRepository: serviceLocator(),
      ),
    )
    ..registerFactory<GetItemById>(
      () => GetItemById(
        itemInventoryRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdateItem>(
      () => UpdateItem(
        itemInventoryRepository: serviceLocator(),
      ),
    )
    ..registerFactory<ItemInventoryBloc>(
      () => ItemInventoryBloc(
        getItems: serviceLocator(),
        registerSupplyItem: serviceLocator(),
        registerEquipmentItem: serviceLocator(),
        getItemById: serviceLocator(),
        updateItem: serviceLocator(),
      ),
    );
}

void _registerPurchaseRequestsDependencies() {
  serviceLocator
    ..registerFactory<PurchaseRequestRemoteDataSource>(
      () => PurchaseRequestRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<PurchaseRequestRepository>(
      () => PurchaseRequestRepositoryImpl(
        purchaseRequestRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetPaginatedPurchaseRequests>(
      () => GetPaginatedPurchaseRequests(
        purchaseRequestRepository: serviceLocator(),
      ),
    )
    ..registerFactory<RegisterPurchaseRequest>(
      () => RegisterPurchaseRequest(
        purchaseRequestRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdatePurchaseRequestStatus>(
      () => UpdatePurchaseRequestStatus(
        purchaseRequestRepository: serviceLocator(),
      ),
    )
    ..registerFactory<GetPurchaseRequestById>(
      () => GetPurchaseRequestById(
        purchaseRequestRepository: serviceLocator(),
      ),
    )
    ..registerFactory<PurchaseRequestsBloc>(
      () => PurchaseRequestsBloc(
        getPaginatedPurchaseRequests: serviceLocator(),
        registerPurchaseRequest: serviceLocator(),
        updatePurchaseRequestStatus: serviceLocator(),
        getPurchaseRequestById: serviceLocator(),
      ),
    );
}

void _registerItemIssuanceDependencies() {
  serviceLocator
    ..registerFactory<IssuanceRemoteDataSource>(
      () => IssuanceRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<IssuanceRepository>(
      () => IssuanceRepositoryImpl(
        issuanceRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetIssuanceById>(
      () => GetIssuanceById(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<GetPaginatedIssuances>(
      () => GetPaginatedIssuances(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<MatchItemWithPr>(
      () => MatchItemWithPr(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<CreateICS>(
      () => CreateICS(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<CreatePAR>(
      () => CreatePAR(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<CreateRIS>(
      () => CreateRIS(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdateIssuanceArchiveStatus>(
      () => UpdateIssuanceArchiveStatus(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetInventorySupplyReport(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetInventorySemiExpendablePropertyReport(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetInventoryPropertyReport(
        issuanceRepository: serviceLocator(),
      ),
    )
    ..registerFactory<IssuancesBloc>(
      () => IssuancesBloc(
        getIssuanceById: serviceLocator(),
        getPaginatedIssuances: serviceLocator(),
        matchItemWithPr: serviceLocator(),
        createICS: serviceLocator(),
        createPAR: serviceLocator(),
        createRIS: serviceLocator(),
        updateIssuanceArchiveStatus: serviceLocator(),
        getInventorySupplies: serviceLocator(),
        getInventorySemiExpendablePropertyReport: serviceLocator(),
        getInventoryPropertyReport: serviceLocator(),
      ),
    );
}

void _registerOfficersManagementDependencies() {
  serviceLocator
    ..registerFactory<OfficerRemoteDataSource>(
      () => OfficerRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<OfficerRepository>(
      () => OfficerRepositoryImpl(
        officerRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetPaginatedOfficers>(
      () => GetPaginatedOfficers(
        officerRepository: serviceLocator(),
      ),
    )
    ..registerFactory<RegisterOfficer>(
      () => RegisterOfficer(
        officerRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdateOfficerArchiveStatus>(
      () => UpdateOfficerArchiveStatus(
        officerRepository: serviceLocator(),
      ),
    )
    ..registerFactory<OfficersBloc>(
      () => OfficersBloc(
        getPaginatedOfficers: serviceLocator(),
        registerOfficer: serviceLocator(),
        updateOfficerArchiveStatus: serviceLocator(),
      ),
    );
}

void _registerUsersManagementDependencies() {
  serviceLocator
    ..registerFactory<UsersManagementRemoteDataSource>(
      () => UsersManagementRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<UsersManagementRepository>(
      () => UsersManagementRepositoryImpl(
        usersManagementRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetUsers>(
      () => GetUsers(
        usersManagementRepository: serviceLocator(),
      ),
    )
    ..registerFactory<GetPendingUsers>(
      () => GetPendingUsers(
        usersManagementRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdateUserAuthStatus>(
      () => UpdateUserAuthStatus(
        usersManagementRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdateUserArchiveStatus>(
      () => UpdateUserArchiveStatus(
        usersManagementRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UpdateAdminApprovalStatus>(
      () => UpdateAdminApprovalStatus(
        usersManagementRepository: serviceLocator(),
      ),
    )
    ..registerFactory<UsersManagementBloc>(
      () => UsersManagementBloc(
        getUsers: serviceLocator(),
        getPendingUsers: serviceLocator(),
        updateUserAuthStatus: serviceLocator(),
        updateUserArchiveStatus: serviceLocator(),
        updateAdminApprovalStatus: serviceLocator(),
      ),
    );
}

void _registerArchiveManagementDependencies() {
  _registerArchiveUsersDependencies();
}

void _registerArchiveUsersDependencies() {
  serviceLocator
    ..registerFactory<ArchiveUsersRemoteDataSource>(
      () => ArchiveUsersRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<ArchiveUsersRepository>(
      () => ArchiveUsersRepositoryImpl(
        archiveUserRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetArchivedUsers(
        archiveUserRepository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateUserIsArchiveStatus(
        archiveUserRepository: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ArchiveUsersBloc(
        getArchivedUsers: serviceLocator(),
        updateUserArchiveStatus: serviceLocator(),
      ),
    );
}

void _registerNotificationDependencies() {
  serviceLocator
    ..registerFactory<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(
        httpService: serviceLocator(),
      ),
    )
    ..registerFactory<NotificationRepository>(
      () => NotificationRepositoryImpl(
        notificationRemoteDataSource: serviceLocator(),
      ),
    )
    ..registerFactory<GetNotifications>(
      () => GetNotifications(
        notificationRepository: serviceLocator(),
      ),
    )
    ..registerFactory<ReadNotification>(
      () => ReadNotification(
        notificationRepository: serviceLocator(),
      ),
    )
    ..registerFactory<NotificationsBloc>(
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
