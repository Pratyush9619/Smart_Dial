import 'dart:convert';

import 'package:get/get.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/services/api_service.dart';
import '../models/hrms/leave_status_model.dart';

class LeaveStatusController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<LeaveData> allLeaves = <LeaveData>[].obs;

  Rxn<LeaveBalances> balances = Rxn<LeaveBalances>();

  @override
  void onInit() {
    super.onInit();
    getLeaveStatus();
  }

  Future<void> getLeaveStatus() async {
    try {
      isLoading.value = true;

      final response = await ApiService().postRequest(
        APIUrls.viewLeaveStatus,
        {
          'employee_id': StaticStoredData.userId,
        },
      );

      final Map<String, dynamic> json = jsonDecode(response.body);

      final model = LeaveStatusModel.fromJson(json);

      allLeaves.assignAll(model.data);
      balances.value = model.leaveBalances;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  List<LeaveData> getLeavesByStatus(String? status) {
    if (status == null) return allLeaves;

    return allLeaves
        .where(
          (e) => e.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }
}
