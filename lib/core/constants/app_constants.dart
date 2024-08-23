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
const bearerUsersUpdateAuthStatusEP = '$bearerUsersEP/update_user_auth_status';
const otpEP = '$authEP/otp';
const sendOtpEP = '$otpEP/send_otp';
const verifyOtpEP = '$otpEP/verify_otp';
const unAuth = '/logout';

/// user acts endpoint
const userActsEP = '/user_activities';

/// item endpoints
const itemsEP = '/items';
const registerItemsEP = '$itemsEP/register_item';
const getItemEP = '$itemsEP/get_item';
const updateItemEP = '$itemsEP/update_item';
const stocksEP = '$itemsEP/stocks';
const getStockByIdEP = '$stocksEP/get_stock_by_id';
const getStocksProductNameEP = '$stocksEP/get_product_names';
const getStocksDescriptionEP = '$stocksEP/get_descriptions';
