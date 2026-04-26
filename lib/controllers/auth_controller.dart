import 'dart:convert';
import 'package:get/get.dart';

import '../constants/static_stored_data.dart';
import '../models/plan_model.dart';
import '../services/api_service.dart';
import '../services/logout_helper.dart';
import 'login_controllers.dart';

bool _loggedOut = false;

class AuthController extends GetxController {
  void logout() {
    _loggedOut = true;
  }

  @override
  void onInit() {
    super.onInit();
    handlePlanExpiry();
  }

  bool get isLoggedOut => _loggedOut;

  handlePlanExpiry() async {
    if (_loggedOut) return;

    final response = await ApiService().postRequest('Auth/checkclientexpiry', {
      'telecaller_id': StaticStoredData.userId,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      PlanModel plan = PlanModel.fromJson(data['data']);

      if (plan.isExpired) {
        showErrorDialog(
          "Your subscription plan has expired. Please contact support to renew your subscription.",
          onComplete: () async {
            await LogoutHelper.logout(Get.context!);
            // Optional: You can perform additional actions after the dialog is closed
          },
        );
      }
    }
  }
}
