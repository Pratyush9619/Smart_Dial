import 'package:get/get.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/active_files_controller.dart';
import 'package:smart_solutions/controllers/admin/admin_disbursement.dart';
import 'package:smart_solutions/controllers/admin/call_back_controller.dart';
import 'package:smart_solutions/controllers/admin/call_log_controller.dart';
import 'package:smart_solutions/controllers/all_disbursement_controller.dart';
import 'package:smart_solutions/controllers/chartCard_controller.dart';
import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/controllers/dailer_controller.dart';
import 'package:smart_solutions/controllers/dashboard_controller.dart';
import 'package:smart_solutions/controllers/data_entry_controller.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/controllers/login_request_controller.dart';
import 'package:smart_solutions/controllers/profile_controller.dart';

import '../controllers/auth_controller.dart';
import '../services/tab_state_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainTabService(), permanent: true); // ⭐ ADD THIS
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => DialerController(), fenix: true);
    Get.lazyPut(() => DataController(), fenix: true);
    Get.lazyPut(() => ActiveFilesController(), fenix: true);
    Get.lazyPut(() => FollowBackFormController(), fenix: true);
    // Get.lazyPut(() => CommonFilterController(), fenix: true);
    Get.put(CommonFilterController());

    Get.lazyPut(() => DisbursementController(), fenix: true);
    Get.lazyPut(() => LoginRequestController(), fenix: true);
    Get.lazyPut(() => DisbursementDetailsController(), fenix: true);
    Get.lazyPut(() => DisbursementDetailsController(), fenix: true);
    Get.lazyPut(() => ChartCardsController());
    Get.lazyPut(() => AuthController(), fenix: true);

    if (StaticStoredData.roleName != 'telecaller') {
      Get.lazyPut(() => AdminCallLogController(), fenix: true);
      Get.lazyPut(() => AdminCallBackController(), fenix: true);
    }
  }
}
