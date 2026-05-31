class APIUrls {
  static const String baseUrl = 'https://smartdial.co.in/api/index.php/';
  static const String imagebaseUrl =
      'https://smartdial.co.in/misadmin/uploads/profile_images/';

  static const String loginUrl = 'Auth/login_user';
  static const String apiKey = 'ftc_apikey@';
  static const String loginApiKey = 'Surplus_apikey@';

  static const String todaysDashboard = 'Auth/getdashboarddata';
  static const String followListData = 'Auth/followupsave';
  static const String followListData2 = 'Auth/followupsave2';
  static const String remarkStatusCode = 'Auth/getremarkstatus';
  static const String followUpSubmitedData = 'Auth/getfollowuplist';
  static const String callBackdData = 'Auth/getfollowuplistbyfilter';
  static const String dataEntryFeild = 'Auth/getdataentry';
  static const String fetchNumber = 'Auth/mobile_fetch';
  static const String allBankNames = 'Auth/getBanksGroupbyName';
  static const String allLoginRequestBankNames = 'Auth/getBanksName';
  static const String loginRequestList = 'Auth/login_requestlist';
  static const String loginRequestSave = 'Auth/login_request_save';
  static const String getLoanStatus = 'Auth/getloanstatus';
  static const String getRemarkList = 'Auth/login_remarklist';

  static const String newBaseUrl = 'https://smartdial.co.in/';
  static const String logoutCheck = 'Auth/useractivecheck';
  static const String checkOnAnotherDeviceLogin = 'Auth/usertokencheck';

  static const String changePassword = "Auth/change_password";
  static const String activity = "Auth/useractivecheck";
  static const String sourcingList = "Auth/getdatasourcingapi";
  static const String getUserGroup = 'Auth/getstatusgroup';
  static const String getTimeGraphData = 'Auth/getdashboarddata';
  static const String getnotificationData = 'Auth/notificationlist';
  static const String updatenotificationData = 'Auth/notificationupdate';
  static const String pinCodelist = 'Auth/getpincodelist';
  static const String companylist = 'Auth/getcompanylist';
  static const String callLoglist = 'Auth/getcalllog';
  static const String callBacklist = 'Auth/getcallback';
  static const String disbursmentlist = 'Auth/getdisbursementbyid';
  static const String teamleaderlist = '/Auth/getallteamleader';

  // add new API for admin disbursement
  static const String disbursementForAdmin = 'Auth/getdisbursementforadmin';

  // add dataentry
  static const String dsaNameList = "Auth/getdsalist";
  static const String productTypeList = "Auth/getproductlist";
  static const String dsaBanklist = "Auth/getloginbankbydsa";
  static const String bankerNamelist = "Auth/getBankerDetailsbyid";
  static const String bankerNamedata = "Auth/getbanknamebyloginbank";
  static const String telecallerlist = 'Auth/gettelecallerdata';
  static const String statuslist = 'Auth/getleaddatastatus';
  static const String dataentrySave = 'Auth/savedataentry';
  static const String mobileByCustomeData = 'Auth/getmobilebycustomerdata';
  static const String teamLeadByTeamId = 'Auth/gettelecallerbyteamid';

  //profile Update
  static const String profileUpdate = 'Auth/profileupdate';
  static const String fetchProfileImage = 'Auth/getfetchprofile';

  //top disburse User
  static const String topDisburseUser = "Auth/gettopdisburseduser";

  //get lead status group
  static const String getAllStatusGroup = "Auth/getallstatusgroup";
  static const String getFollowUpStatus = "Auth/getallfollowupstatus";

  //get updated followup list
  static const String updatedcalllog = "Auth/getupdatedfollowuplist";

  static const String getYearlyMonthlyDisbursedAmounts =
      "Auth/getCurrentYearMonthlyDisbursedAmounts";

  static const getDisbursementForAdmin = "Auth/getdisbursementforadmin";
  static const String themeColor = "Auth/updatethemecolor";
  static const String adminLoginRequest = 'Auth/getloginrequestforadmin';
  static const String adminLoginFiles = 'Auth/getloginfilesforadmin';
  static const String loginRequestTeamLeader = 'Auth/getloginrequestteamleader';
  static const String getMobileDashboardData = 'Auth/getmobiledashboard';

  // notification
  static const String getnotificationCount = 'Auth/notificationcountlist';
  //forget password
  static const String verifyMobileNo = 'Auth/verifymobileno';
  static const String verifyOtp = 'Auth/verifyotp';
  static const String resetPassword = 'Auth/resetpassword';

  static const String getMoveToLoginData = 'Auth/getmovetologindata';

  static const String incentiveData = 'Auth/getincentive';
  static const String incentiveSummery = 'Auth/getincentivebytelecallerid';

  static const String logout = 'Auth//logout';
}
