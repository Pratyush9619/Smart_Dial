// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class LeaveController extends GetxController {
//   var leaveType = ''.obs;
//   var fromDate = Rxn<DateTime>();
//   var toDate = Rxn<DateTime>();
//   var reason = ''.obs;
//   var isSubmitting = false.obs;
//   var halfDaySession = ''.obs;

//   void updateLeaveType(String? value) => leaveType.value = value.toString();
//   void updateFromDate(DateTime date) => fromDate.value = date;
//   void updateToDate(DateTime date) => toDate.value = date;
//   void updateReason(String value) => reason.value = value;

//   void updateHalfDaySession(String? value) {
//     if (value != null) halfDaySession.value = value;
//   }

//   Future<void> submitLeave(BuildContext context) async {
//     if (leaveType.value.isEmpty ||
//         fromDate.value == null ||
//         toDate.value == null ||
//         reason.value.isEmpty) {
//       Get.snackbar('Error', 'Please fill all fields',
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }

//     isSubmitting.value = true;
//     await Future.delayed(const Duration(seconds: 1)); // simulate API call
//     isSubmitting.value = false;

//     Get.snackbar('Success', 'Leave request submitted successfully ✅',
//         snackPosition: SnackPosition.BOTTOM);

//     Get.back(); // navigate back
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../constants/api_urls.dart';
import '../constants/static_stored_data.dart';
import '../services/api_service.dart';
import '../views/hrms/leave_status_page.dart';

class LeaveController extends GetxController {
  // Loading
  RxBool isSubmitting = false.obs;

  // Form values
  RxString leaveType = ''.obs;
  RxString halfDaySession = ''.obs;
  Rxn<DateTime> fromDate = Rxn<DateTime>();
  Rxn<DateTime> toDate = Rxn<DateTime>();
  //RxString reason = ''.obs;
  Rx<TextEditingController> reasonController = TextEditingController().obs;

  // Update methods
  void updateLeaveType(String? value) {
    leaveType.value = value ?? '';
  }

  void updateHalfDaySession(String? value) {
    halfDaySession.value = value ?? '';
  }

  void updateFromDate(DateTime date) {
    fromDate.value = date;
  }

  void updateToDate(DateTime date) {
    toDate.value = date;
  }

  void updateReason(String value) {
    reasonController.value.text = value;
  }

  int get leaveTypeId {
    switch (leaveType.value) {
      case 'Sick Leave':
        return 1;
      case 'Casual Leave':
        return 2;
      case 'Paid Leave':
        return 3;
      case 'Unpaid Leave':
        return 4;
      case 'Half Day':
        return 5;
      default:
        return 0;
    }
  }

  Future<void> submitLeave({
    required BuildContext context,
    required String leaveTypeId,
    required DateTime fromDate,
    required DateTime toDate,
    required String reason,
  }) async {
    try {
      isSubmitting.value = true;

      final requestBody = {
        "employee_id": StaticStoredData.userId.toString(),
        "leave_type": leaveTypeId,
        "leaveFrom": DateFormat('yyyy-MM-dd').format(fromDate),
        "toFrom": DateFormat('yyyy-MM-dd').format(toDate),
        "reason": reason,
      };

      print("Leave Request Body: $requestBody");

      final response = await ApiService().postRequest(
        APIUrls.requestLeave,
        requestBody,
      );

      print("Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(data['message'] ?? "Leave request submitted successfully"),
            backgroundColor: Colors.green,
          ),
        );

        clearLeaveForm();

        isSubmitting.value = false;

        Get.to(() => LeaveStatusPage());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Leave Submit Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearLeaveForm() {
    leaveType.value = '';
    halfDaySession.value = '';
    fromDate.value = null;
    toDate.value = null;
    reasonController.value.text = '';
  }
}
