class AppApis {
  static String appBaseUrl = "https://api.tellatrust.com";

  ///Authentication Endpoints
  static String signUpApi = "$appBaseUrl/auth/c/register";
  static String verifyEmail = "$appBaseUrl/auth/c/verify-email";
  static String verifyPhone = "$appBaseUrl/auth/c/verify-phone";
  static String verifyDeviceChange = "$appBaseUrl/auth/c/change-device";
  static String createAccessPin = "$appBaseUrl/auth/c/access-pin";
  static String sendPhoneToken = "$appBaseUrl/auth/c/send-token";
  static String resetPassword = "$appBaseUrl/auth/c/reset-password";
  static String changePassword = "$appBaseUrl/auth/c/change-password";
  static String changeAccessPin = "$appBaseUrl/auth/c/change-access-pin";
  static String login = "$appBaseUrl/auth/c/login-mobile";
  static String refreshTokenApi = "$appBaseUrl/auth/c/refresh-token";
  static String loginAccessPin = "$appBaseUrl/auth/c/login-access-pin";

  static String addWithdrawalAccount = "$appBaseUrl/c/w/add-withdrawal-nuban";
  static String userProfile = "$appBaseUrl/user/c/profile";
  static String updateProfile = "$appBaseUrl/user/c/update-profile/";
  static String getOneTransactionDetails = "$appBaseUrl/c/w/get-transaction";
  //static String userProfile = "$appBaseUrl/user/c/profile";

  ///PRODUCTS ENDPOINTS
  static String listCategory = "$appBaseUrl/c/p/list-category";
  static String listProduct = "$appBaseUrl/c/p/list-product";
  static String listService = "$appBaseUrl/c/p/list-service";
  static String purchaseProduct = "$appBaseUrl/c/pay/create-wallet-order";
  static String a2cDetails = "$appBaseUrl/c/pay/get-a2c-details";
  static String createA2c = "$appBaseUrl/c/pay/create-a2c";
  static String reportA2c = "$appBaseUrl/c/pay/report-transfer-a2c";
  static String createBeneficiary = "$appBaseUrl/user/c/create-beneficiary";
  static String listBeneficiary = "$appBaseUrl/user/c/list-beneficiary";
  static String deleteBeneficiary = "$appBaseUrl/user/c/delete-beneficiary";
  static String listPointHistory = "$appBaseUrl/user/c/list-point-history";
  static String listWalletHistory = "$appBaseUrl/user/c/list-wallet-history";
  static String verifyEntityNumber = "$appBaseUrl/c/pay/verify-entity-number";
  static String quickPay = "$appBaseUrl/c/pay/initiate-checkout";

  static String initiateVerification = "$appBaseUrl/c/w/initiate-verification";
  static String validateVerification = "$appBaseUrl/c/w/validate-verification";
  static String listTransaction = "$appBaseUrl/c/w/list-transaction";

  static String tellaCustomerVerification = '$appBaseUrl/user/c/get-customers';

  static String banks = '$appBaseUrl/misc/banks?search=&page=1';
  static String sendInternalFund = '$appBaseUrl/c/pay/send-funds-internal';
  static String sendExternalFund = '$appBaseUrl/c/pay/send-funds-external';
  static String verifyAccount = '$appBaseUrl/c/pay/verify-nuban';

  static String refreshToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0NmE3M2YwNy1lMWEyLTRkODUtYjFmNi0zNTM4ZTg0N2Q3MjkiLCJleHAiOjE3MTAxNTk0OTIsImlhdCI6MTcwNzU2NzQ5Mn0.QLpqzjkn9PSzI3tnyOL0rHxCPZUx9dEOw14W2EQtE_M";
}
