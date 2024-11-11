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
  static const viewItemRouteName = 'viewItem';
  static const viewItemRoutePath = 'viewItem';
  static const registerItemViewRouteName = 'registerItemView';
  static const registerItemViewRoutePath = 'registerItem';
  static const updateItemViewRouteName = 'updateItemView';
  static const updateItemViewRoutePath = 'updateItem';
  static const nestedViewItemRouteName = '$itemInventoryViewRouteName/$viewItemRouteName';
  static const nestedViewItemRoutePath = '$itemInventoryViewRoutePath/$viewItemRoutePath';
  static const nestedRegisterItemViewRouteName = '$itemInventoryViewRouteName/$registerItemViewRouteName';
  static const nestedRegisterItemViewRoutePath = '$itemInventoryViewRoutePath/$registerItemViewRoutePath';
  static const nestedUpdateItemViewRouteName = '$itemInventoryViewRouteName/$updateItemViewRouteName';
  static const nestedUpdateItemViewRoutePath = '$itemInventoryViewRoutePath/$updateItemViewRoutePath';

  /// purchase request route paths
  static const purchaseRequestViewRouteName = 'purchaseRequestView';
  static const purchaseRequestViewRoutePath = '/purchaseRequest';
  static const registerPurchaseRequestViewRouteName = 'registerPurchaseRequestView';
  static const registerPurchaseRequestViewRoutePath = 'registerPurchaseRequest';
  static const nestedRegisterPurchaseRequestViewRouteName = '$purchaseRequestViewRouteName/$registerPurchaseRequestViewRouteName';
  static const nestedRegisterPurchaseRequestViewRoutePath = '$purchaseRequestViewRoutePath/$registerPurchaseRequestViewRoutePath';

  /// item issuance route paths
  static const itemIssuanceViewRouteName = 'itemIssuanceView';
  static const itemIssuanceViewRoutePath = '/itemIssuance';
  static const viewItemIssuanceRouteName = 'viewItemIssuance';
  static const viewItemIssuanceRoutePath = 'viewItemIssuance';
  static const registerItemIssuanceViewRouteName = 'registerItemIssuanceView';
  static const registerItemIssuanceViewRoutePath = 'registerItemIssuance';
  static const updateItemIssuanceViewRouteName = 'updateItemIssuanceView';
  static const updateItemIssuanceViewRoutePath = 'updateItemIssuance';
  static const nestedViewItemIssuanceViewRouteName = '$itemIssuanceViewRouteName/$viewItemIssuanceRouteName';
  static const nestedViewItemIssuanceViewRoutePath = '$itemIssuanceViewRoutePath/$viewItemIssuanceRoutePath';
  static const nestedRegisterItemIssuanceViewRouteName = '$itemIssuanceViewRouteName/$registerItemIssuanceViewRouteName';
  static const nestedRegisterItemIssuanceViewRoutePath = '$itemIssuanceViewRoutePath/$registerItemIssuanceViewRoutePath';
  static const nestedUpdateItemIssuanceViewRouteName = '$itemIssuanceViewRouteName/$updateItemIssuanceViewRouteName';
  static const nestedUpdateItemIssuanceViewRoutePath = '$itemIssuanceViewRoutePath/$updateItemIssuanceViewRoutePath';

  /// user management route path
  static const usersManagementViewRouteName = 'usersManagementView';
  static const usersManagementViewRoutePath = '/usersManagement';

  /// office management route path
  static const officersManagementViewRouteName = 'officersManagementView';
  static const officersManagementViewRoutePath = '/officersManagement';

  /// archive management route path
  static const archiveUserViewRouteName = 'archiveUserViewRouteName';
  static const archiveUserViewRoutePath = '/archiveUserView';

  /// settings route paths
  static const settingsViewRouteName = 'settingsView';
  static const settingsViewRoutePath = '/settings';
  static const generalSettingViewRouteName = 'generalSettingView';
  static const generalSettingViewRoutePath = '/general';
  static const accountProfileViewRouteName = 'accountProfileView';
  static const accountProfileViewRoutePath = '/accountProfile';
}