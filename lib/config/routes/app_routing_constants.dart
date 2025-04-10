class RoutingConstants {
  /// base/ login route path
  static const loginViewRouteName = 'loginView';
  static const loginViewRoutePath = '/';

  /// register route path
  static const registerViewRouteName = 'registerView';
  static const registerViewRoutePath = '/register';

  /// change email route path
  static const changeEmailViewRouteName = 'changeEmailView';
  static const changeEmailViewRoutePath = '/changeEmail';

  /// otp verification route path
  static const otpVerificationViewRouteName = 'otpVerificationView';
  static const otpVerificationViewRoutePath = '/otpVerification';

  /// set up password route path
  static const setUpNewPasswordViewRouteName = 'setNewPasswordView';
  static const setUpNewPasswordViewRoutePath = '/setNewPassword';

  /// base navigation route path
  static const navigationViewRouteName = 'navigationView';
  static const navigationViewRoutePath = '/navigation';

  /// dashboard route path
  static const dashboardViewRouteName = 'dashboardView';
  static const dashboardViewRoutePath = '/dashboard';

  /// item inventory route paths
  static const itemInventoryViewRouteName = 'itemInventoryView';
  static const itemInventoryViewRoutePath = '/itemInventory';

  static const viewSupplyItemRouteName = 'viewSupplyItem';
  static const viewSupplyItemRoutePath = 'viewSupplyItem';
  static const viewInventoryItemRouteName = 'viewInventoryItem';
  static const viewInventoryItemRoutePath = 'viewInventoryItem';

  static const registerSupplyItemViewRouteName = 'registerSupplyItemView';
  static const registerSupplyItemViewRoutePath = 'registerSupplyItem';
  static const registerInventoryItemViewRouteName = 'registerInventoryItemView';
  static const registerInventoryItemViewRoutePath = 'registerInventoryItem';

  static const updateSupplyItemViewRouteName = 'updateSupplyItemView';
  static const updateSupplyItemViewRoutePath = 'updateSupplyItem';
  static const updateInventoryItemViewRouteName = 'updateInventoryItemView';
  static const updateInventoryItemViewRoutePath = 'updateInventoryItem';

  static const nestedViewSupplyItemRouteName =
      '$itemInventoryViewRouteName/$viewSupplyItemRouteName';
  static const nestedViewSupplyItemRoutePath =
      '$itemInventoryViewRoutePath/$viewSupplyItemRoutePath';
  static const nestedViewInventoryItemRouteName =
      '$itemInventoryViewRouteName/$viewInventoryItemRouteName';
  static const nestedViewInventoryItemRoutePath =
      '$itemInventoryViewRoutePath/$viewInventoryItemRoutePath';

  static const nestedRegisterSupplyItemViewRouteName =
      '$itemInventoryViewRouteName/$registerSupplyItemViewRouteName';
  static const nestedRegisterSupplyItemViewRoutePath =
      '$itemInventoryViewRoutePath/$registerSupplyItemViewRoutePath';
  static const nestedRegisterInventoryItemViewRouteName =
      '$itemInventoryViewRouteName/$registerInventoryItemViewRouteName';
  static const nestedRegisterInventoryItemViewRoutePath =
      '$itemInventoryViewRoutePath/$registerInventoryItemViewRoutePath';

  static const nestedUpdateSupplyItemViewRouteName =
      '$itemInventoryViewRouteName/$updateSupplyItemViewRouteName';
  static const nestedUpdateSupplyItemViewRoutePath =
      '$itemInventoryViewRoutePath/$updateSupplyItemViewRoutePath';
  static const nestedUpdateInventoryItemViewRouteName =
      '$itemInventoryViewRouteName/$updateInventoryItemViewRouteName';
  static const nestedUpdateInventoryItemViewRoutePath =
      '$itemInventoryViewRoutePath/$updateInventoryItemViewRoutePath';

  /// purchase request route paths
  static const purchaseRequestViewRouteName = 'purchaseRequestView';
  static const purchaseRequestViewRoutePath = '/purchaseRequest';
  static const viewPurchaseRequestRouteName = 'viewPurchaseRequest';
  static const viewPurchaseRequestRoutePath = 'viewPurchaseRequest';
  static const registerPurchaseRequestViewRouteName =
      'registerPurchaseRequestView';
  static const registerPurchaseRequestViewRoutePath = 'registerPurchaseRequest';
  static const nestedViewPurchaseRequestRouteName =
      '$purchaseRequestViewRouteName/$viewPurchaseRequestRouteName';
  static const nestedViewPurchaseRequestRoutePath =
      '$purchaseRequestViewRoutePath/$viewPurchaseRequestRoutePath';
  static const nestedRegisterPurchaseRequestViewRouteName =
      '$purchaseRequestViewRouteName/$registerPurchaseRequestViewRouteName';
  static const nestedRegisterPurchaseRequestViewRoutePath =
      '$purchaseRequestViewRoutePath/$registerPurchaseRequestViewRoutePath';

  /// purchase order route paths
  static const registerPurchaseOrderViewRouteName = 'registerPurchaseOrderView';
  static const registerPurchaseOrderViewRoutePath = 'registerPurchaseOrder';
  static const nestedRegisterPurchaseOrderViewRouteName =
      '$purchaseRequestViewRouteName/$registerPurchaseOrderViewRouteName';
  static const nestedRegisterPurchaseOrderViewRoutePath =
      '$purchaseRequestViewRoutePath/$registerPurchaseOrderViewRoutePath';

  /// item issuance route paths
  static const itemIssuanceViewRouteName = 'itemIssuanceView';
  static const itemIssuanceViewRoutePath = '/itemIssuance';
  static const viewItemIssuanceRouteName = 'viewItemIssuance';
  static const viewItemIssuanceRoutePath = 'viewItemIssuance';
  static const registerItemIssuanceViewRouteName = 'registerItemIssuanceView';
  static const registerItemIssuanceViewRoutePath = 'registerItemIssuance';
  static const updateItemIssuanceViewRouteName = 'updateItemIssuanceView';
  static const updateItemIssuanceViewRoutePath = 'updateItemIssuance';
  static const nestedViewItemIssuanceViewRouteName =
      '$itemIssuanceViewRouteName/$viewItemIssuanceRouteName';
  static const nestedViewItemIssuanceViewRoutePath =
      '$itemIssuanceViewRoutePath/$viewItemIssuanceRoutePath';
  static const nestedRegisterItemIssuanceViewRouteName =
      '$itemIssuanceViewRouteName/$registerItemIssuanceViewRouteName';
  static const nestedRegisterItemIssuanceViewRoutePath =
      '$itemIssuanceViewRoutePath/$registerItemIssuanceViewRoutePath';
  static const nestedUpdateItemIssuanceViewRouteName =
      '$itemIssuanceViewRouteName/$updateItemIssuanceViewRouteName';
  static const nestedUpdateItemIssuanceViewRoutePath =
      '$itemIssuanceViewRoutePath/$updateItemIssuanceViewRoutePath';

  /// user management route path
  static const usersManagementViewRouteName = 'usersManagementView';
  static const usersManagementViewRoutePath = '/usersManagement';

  /// office management route path
  static const officersManagementViewRouteName = 'officersManagementView';
  static const officersManagementViewRoutePath = '/officersManagement';

  /// archive management route path
  static const archiveUserViewRouteName = 'archiveUserView';
  static const archiveUserViewRoutePath = '/archiveUser';
  static const archiveOfficerViewRouteName = 'archiveOfficeView';
  static const archiveOfficerViewRoutePath = '/archiveOfficer';
  static const archiveIssuanceViewRouteName = 'archiveIssuanceView';
  static const archiveIssuanceViewRoutePath = '/archiveIssuance';

  /// settings route paths
  static const settingsViewRouteName = 'settingsView';
  static const settingsViewRoutePath = '/settings';
  static const generalSettingViewRouteName = 'generalSettingView';
  static const generalSettingViewRoutePath = '/general';
  static const accountProfileViewRouteName = 'accountProfileView';
  static const accountProfileViewRoutePath = '/accountProfile';
}
