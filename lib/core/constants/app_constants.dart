/// auth endpoints
const baseUrl = 'http://localhost:8080';
const authEP = '/authentication';
const basicAuthEP = '$authEP/basic';
const registerEP = '$basicAuthEP/register';
const loginEP = '$basicAuthEP/login';
const resetPasswordEP = '$basicAuthEP/reset_password';
const bearerAuthEP = '$authEP/bearer';
const bearerLoginEP = '$bearerAuthEP/login';
const bearerLogoutEP = '$bearerAuthEP/logout';
const bearerUsersEP = '$bearerAuthEP/users';
const bearerPendingUsersEP = '$bearerUsersEP/pending';
const bearerUsersUpdateAuthStatusEP = '$bearerUsersEP/update_user_auth_status';
const bearerUsersUpdateArchiveStatusEP = '$bearerUsersEP/update_user_archive_status';
const bearerUsersUpdateAdminApprovalStatusEP = '$bearerUsersEP/update_admin_approval_status';
const updateUserInfoEP = '$bearerUsersEP/update_user_info';
const otpEP = '$authEP/otp';
const sendOtpEP = '$otpEP/send_otp';
const verifyOtpEP = '$otpEP/verify_otp';
const unAuth = '/logout';

const dashboardEP = '/dashboard';
const inventorySummaryEP = '$dashboardEP/inventory_summary';
const mostRequestedItemsEP = '$dashboardEP/most_requested_items';

/// user acts endpoint
const userActsEP = '/user_activities';

/// item endpoints
const itemsEP = '/items';
const itemsIdEP = '$itemsEP/id';
const itemNamesEP = '$itemsEP/product_names';
const itemDescriptionsEP = '$itemsEP/product_descriptions';
const itemManufacturersEP = '$itemsEP/manufacturers';
const itemBrandsEP = '$itemsEP/brands';
const itemModelsEP = '$itemsEP/models';

const officesEP = '/offices';
const positionsEP = '/positions';
const officersEP = '/officers';
const officerNamesEP = '$officersEP/names';
const updateOfficerArchiveStatusEP = '$officersEP/update_archive_status';

const entitiesEP = '/entities';
const purchaseRequestsEP = '/purchase_requests';
const purchaseRequestIdEP = '$purchaseRequestsEP/id';
const purchaseRequestIdsEP = '$purchaseRequestsEP/ids';
const updatePurchaseRequestStatusEP = '$purchaseRequestsEP/update_status';

const issuancesEP = '/issuances';
const issuancesIdEP = '$issuancesEP/id';
const matchPurchaseRequestWithInventoryItemEP = '$issuancesEP/match';
const updateIssuanceArchiveStatusEP = '$issuancesEP/update_archive_status';
const icsEP = '$issuancesEP/ics';
const parEP = '$issuancesEP/par';

const notificationsEP = '/notifications';
