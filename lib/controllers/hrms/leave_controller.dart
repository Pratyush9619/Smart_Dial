import 'dart:convert';

import 'package:get/get.dart';

import '../../constants/api_urls.dart';
import '../../constants/static_stored_data.dart';
import '../../models/hrms/leave_count.dart';
import '../../services/api_service.dart';

class LeaveCountController extends GetxController {
  final leaveTypes = <LeaveCount>[].obs;

  final selectedLeaveType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getLeaveCounts();
  }

  Future<void> getLeaveCounts() async {
    try {
      final response = await ApiService().postRequest(
        APIUrls.leaveCounts,
        {
          "employee_id": StaticStoredData.userId,
        },
      );

      final data = response.body.isNotEmpty ? json.decode(response.body) : null;

      if (data != null && data['status'] == 200) {
        final Map<String, dynamic> leaveCounts = Map<String, dynamic>.from(
          data['leave_counts'] ?? {},
        );

        leaveTypes.clear();

        leaveCounts.forEach((key, value) {
          leaveTypes.add(
            LeaveCount.fromJson(
              key,
              Map<String, dynamic>.from(value),
            ),
          );
        });
      }
    } catch (e) {
      print("Leave Count API Error: $e");
    }
  }
}
