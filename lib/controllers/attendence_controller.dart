// import 'package:get/get.dart';

// class AttendanceController extends GetxController {
//   var isLoading = true.obs;
//   var attendanceList = <Map<String, dynamic>>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchAttendance();
//   }

//   void fetchAttendance() async {
//     await Future.delayed(
//         const Duration(milliseconds: 600)); // simulate API delay

//     attendanceList.value = [
//       {
//         'date': DateTime(2025, 11, 1),
//         'status': 'Present',
//         'checkIn': '09:10 AM',
//         'checkOut': '06:12 PM',
//       },
//       {
//         'date': DateTime(2025, 10, 2),
//         'status': 'Absent',
//       },
//       {
//         'date': DateTime(2025, 10, 3),
//         'status': 'Half Day',
//         'checkIn': '09:25 AM',
//         'checkOut': '01:00 PM',
//       },
//       {
//         'date': DateTime(2025, 9, 30),
//         'status': 'Leave',
//       },
//     ];

//     isLoading.value = false;
//   }
// }

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceController extends GetxController {
  // Office Location
  final LatLng officeLocation = const LatLng(28.6139, 77.2090);

  RxBool canMarkAttendance = false.obs;
  RxDouble userDistance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLocation.latitude,
      officeLocation.longitude,
    );

    userDistance.value = distance;
    canMarkAttendance.value = distance <= 150;
  }

  void markAttendance() {
    Get.snackbar(
      "Attendance",
      "Attendance Marked Successfully",
    );
  }
}
