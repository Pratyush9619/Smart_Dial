import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import '../models/hrms/attendence_response.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

enum AttendanceStatus {
  notPunched,
  punchedIn,
  punchedOut,
}

class AttendanceController extends GetxController {
  // Punch state
  RxBool isPunchedIn = false.obs;

  // Camera
  CameraController? cameraController;
  RxBool cameraReady = false.obs;
  Rx<File?> selfie = Rx<File?>(null);

  // Face
  RxBool faceValid = false.obs;
  RxString faceError = ''.obs;
  late FaceDetector faceDetector;

  // Location
  RxBool locationAllowed = false.obs;
  RxString address = ''.obs;
  final RxBool isPunching = false.obs;

  String userName = '';

  final isAttendanceCompleted = false.obs;

  RxBool isLoading = false.obs;

  AttendanceResponse? response;

  RxList<Attendance> attendanceList = <Attendance>[].obs;
  Rxn<Attendance> selectedAttendance = Rxn<Attendance>();

  Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initializeAttendance();

    // initCamera();
    // fetchAttendanceSettings();
    // checkLocation();
    // _loadUserName();
    // checkTodayAttendance();
    // final today = DateTime.now();
    // getAttendanceDetails(date: today);

    // getMonthlyAttendance(
    //   month: DateTime.now().month,
    //   year: DateTime.now().year,

    // date: DateFormat('yyyy-MM-dd').format(DateTime.now()),

    //  isHoliday(selectedDate.value);
  }

  Future<void> _initializeAttendance() async {
    await _loadUserName();

    await checkTodayAttendance();

    await getAttendanceDetails(
      date: DateTime.now(),
    );

    await getMonthlyAttendance(
      month: DateTime.now().month,
      year: DateTime.now().year,
    );

    await fetchAttendanceSettings();
    await initCamera();
    await checkLocation();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();

    userName = prefs.getString('userName') ?? "Name";
  }

  /// CAMERA
  Future<void> initCamera() async {
    await getAttendanceSettings();
    final cams = await availableCameras();
    final front = cams.firstWhere(
      (e) => e.lensDirection == CameraLensDirection.front,
    );

    cameraController = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController!.initialize();
    cameraReady.value = true;
  }

  /// SELFIE + FACE
  // Future<void> captureSelfie() async {
  //   final pic = await cameraController!.takePicture();
  //   final file = File(pic.path);
  //   selfie.value = file;
  //   await detectFace(file);

  //   if (isPunchedIn.value) {
  //     await punchOut();
  //   } else {
  //     await punch();
  //   }
  // }

  Future<void> captureSelfie() async {
    final pic = await cameraController!.takePicture();
    final file = File(pic.path);

    selfie.value = file;

    await detectFace(file);

    if (isPunchedIn.value) {
      await punchOut();
    } else {
      await punch();
    }
  }

  Future<void> detectFace(File img) async {
    final input = InputImage.fromFile(img);
    final faces = await faceDetector.processImage(input);

    if (faces.isEmpty) {
      faceValid.value = false;
      faceError.value = "No face detected";
    } else if (faces.length > 1) {
      faceValid.value = false;
      faceError.value = "Multiple faces detected";
    } else {
      faceValid.value = true;
      faceError.value = "";
    }
  }

  /// LOCATION
  Future<void> checkLocation() async {
    try {
      final result = await LocationService.getLocation();

      print("Office Latitude: ${LocationService.officeLat}");
      print("Office Longitude: ${LocationService.officeLng}");
      print("Allowed Radius: ${LocationService.radius}");
      // print("Within Range: ${result.withinRange}");

      locationAllowed.value = result.isWithinRadius;
      address.value = result.address;
    } catch (e) {
      print("checkLocation Error: $e");
    }
  }

  // Future<void> punch() async {
  //   if (isPunching.value) return;

  //   isPunching.value = true;

  //   try {
  //     final success = await ApiService.punchAttendance(
  //         employeeId: int.parse(StaticStoredData.userId),
  //         lat:
  //             // 28.59720461,
  //             LocationService.currentLat,
  //         lng:
  //             //77.34718441,
  //             LocationService.currentLng,
  //         isPunchedIn: isPunchedIn.value,
  //         image: File(selfie.value!.path),
  //         radius: LocationService.radius,
  //         url: APIUrls.markAttendance);

  //     if (success) {
  //       isPunchedIn.toggle();

  //       selfie.value = null;

  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             isPunchedIn.value
  //                 ? "Punch In successful"
  //                 : "Punch Out successful",
  //           ),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         const SnackBar(
  //           content: Text("Unable to mark attendance"),
  //         ),
  //       );
  //     }
  //   } finally {
  //     isPunching.value = false;
  //   }
  // }

  Future<void> punch() async {
    if (isPunching.value) return;

    if (selfie.value == null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Please capture selfie"),
        ),
      );
      return;
    }

    isPunching.value = true;

    try {
      final success = await ApiService.punchAttendance(
        employeeId: int.parse(StaticStoredData.userId),
        lat: LocationService.currentLat,
        lng: LocationService.currentLng,
        isPunchedIn: false,
        image: File(selfie.value!.path),
        radius: LocationService.radius,
        url: APIUrls.markAttendance,
      );

      if (success) {
        final prefs = await SharedPreferences.getInstance();

        final today = DateTime.now().toString().split(" ")[0];

        await prefs.setString("attendance_date", today);
        await prefs.setBool("is_punched_in", true);
        await prefs.setBool("attendance_completed", false);

        isPunchedIn.value = true;
        isAttendanceCompleted.value = false;

        selfie.value = null;

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Punch In successful"),
          ),
        );

        Get.back();
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Unable to mark attendance"),
          ),
        );
      }
    } finally {
      isPunching.value = false;
    }
  }

  // Future<void> punchOut() async {
  //   if (isPunching.value) return;

  //   if (!isPunchedIn.value) {
  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(
  //         content: Text("Please punch in first"),
  //       ),
  //     );
  //     return;
  //   }

  //   if (selfie.value == null) {
  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(
  //         content: Text("Please capture selfie"),
  //       ),
  //     );
  //     return;
  //   }

  //   isPunching.value = true;

  //   try {
  //     final success = await ApiService.punchAttendance(
  //       employeeId: int.parse(StaticStoredData.userId),
  //       lat: LocationService.currentLat,
  //       lng: LocationService.currentLng,
  //       isPunchedIn: true, // true means punch out
  //       image: File(selfie.value!.path),
  //       radius: LocationService.radius,
  //       url: APIUrls.markOutAttendance, // Use the punch out URL
  //     );

  //     if (success) {
  //       isPunchedIn.value = false;

  //       selfie.value = null;

  //       await saveTodayAttendance();

  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         const SnackBar(
  //           content: Text("Punch Out successful"),
  //         ),
  //       );
  //       isPunchedIn.value = false;
  //       isAttendanceCompleted.value = true;
  //     } else {
  //       ScaffoldMessenger.of(Get.context!).showSnackBar(
  //         const SnackBar(
  //           content: Text("Unable to mark punch out"),
  //         ),
  //       );
  //     }
  //   } finally {
  //     isPunching.value = false;
  //   }
  // }

  Future<void> punchOut() async {
    if (isPunching.value) return;

    if (!isPunchedIn.value) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Please punch in first"),
        ),
      );
      return;
    }

    if (selfie.value == null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Please capture selfie"),
        ),
      );
      return;
    }

    isPunching.value = true;

    try {
      final success = await ApiService.punchAttendance(
        employeeId: int.parse(StaticStoredData.userId),
        lat: LocationService.currentLat,
        lng: LocationService.currentLng,
        isPunchedIn: true,
        image: File(selfie.value!.path),
        radius: LocationService.radius,
        url: APIUrls.markOutAttendance,
      );

      if (success) {
        final prefs = await SharedPreferences.getInstance();

        final today = DateTime.now().toString().split(" ")[0];

        await prefs.setString("attendance_date", today);
        await prefs.setBool("is_punched_in", false);
        await prefs.setBool("attendance_completed", true);

        isPunchedIn.value = false;
        isAttendanceCompleted.value = true;

        selfie.value = null;

        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Punch Out successful"),
          ),
        );
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Unable to mark punch out"),
          ),
        );
      }
    } finally {
      isPunching.value = false;
    }
  }

  Future<void> fetchAttendanceSettings() async {
    try {
      final response = await getAttendanceSettings();

      if (response['status'] == 'success') {
        final data = response['data'];

        LocationService.officeLat = double.parse(data['office_latitude']);

        LocationService.officeLng = double.parse(data['office_longitude']);

        LocationService.radius = double.parse(data['allowed_punch_radius']);

        print("Office Latitude: ${LocationService.officeLat}");
        print("Office Longitude: ${LocationService.officeLng}");
        print("Radius: ${LocationService.radius}");
      }
    } catch (e) {
      print("Error fetching settings: $e");
    }
  }

  Future<Map<String, dynamic>> getAttendanceSettings() async {
    try {
      SharedPreferences shared = await SharedPreferences.getInstance();

      final companyName = shared.get("companyname");

      final url =
          "${APIUrls.newBaseUrl}$companyName/Webapi/get_attendance_setting";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-api-key": APIUrls.apiKey,
        },
      );

      print("Attendance Settings URL ---> $url");
      print("Response ---> ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Failed to fetch attendance settings: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> getAttendanceDetails({
    required DateTime date,
  }) async {
    try {
      isLoading.value = true;

      final res = await ApiService().postRequest(
        APIUrls.viewAttendance,
        {
          "employee_id": StaticStoredData.userId,
          "year": date.year.toString(),
          "month": date.month.toString().padLeft(2, '0'),
          "date": DateFormat('yyyy-MM-dd').format(date),
        },
      );

      final jsonResponse = jsonDecode(res.body);

      response = AttendanceResponse.fromJson(jsonResponse);

      final data = response!.data;

      debugPrint("Today's attendance count: ${data.length}");

      if (data.isNotEmpty) {
        selectedAttendance.value = data.first;

        debugPrint(
          "Today's status: ${selectedAttendance.value!.status}",
        );
      } else {
        selectedAttendance.value = null;
      }
    } catch (e) {
      debugPrint("Attendance Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMonthlyAttendance({
    required int month,
    required int year,
  }) async {
    try {
      isLoading(true);

      final res = await ApiService().postRequest(
        APIUrls.viewAttendance,
        {
          "employee_id": StaticStoredData.userId,
          "year": year.toString(),
          "month": month.toString().padLeft(2, '0'),
        },
      );

      final jsonResponse = jsonDecode(res.body);

      response = AttendanceResponse.fromJson(jsonResponse);

      attendanceList.assignAll(response!.data);
    } catch (e) {
      debugPrint("Attendance Error: $e");
    } finally {
      isLoading(false);
    }
  }

  Attendance? attendanceOf(DateTime day) {
    return attendanceList.firstWhereOrNull(
      (e) => onlyDate(DateTime.parse(e.date)) == onlyDate(day),
    );
  }

  void onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    selectedDate.value = selectedDay;

    selectedAttendance.value = attendanceOf(selectedDay);
  }

  DateTime onlyDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  // /// PUNCH API
  // Future<void> punch() async {
  //   if (!faceValid.value) {
  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(
  //         content: Text("Face verification required"),
  //       ),
  //     );
  //     return;
  //   }

  //   if (!locationAllowed.value) {
  //     print("Location Allowed Value: ${locationAllowed.value}");

  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(
  //         content: Text("You are outside allowed area"),
  //       ),
  //     );

  //     return;
  //   }

  //   if (selfie.value == null) {
  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(
  //         content: Text("Please capture selfie"),
  //       ),
  //     );
  //     return;
  //   }

  //   final success = await ApiService.punchAttendance(
  //     employeeId: int.parse(StaticStoredData.userId),
  //     lat: LocationService.officeLat, // user's current latitude
  //     lng: LocationService.officeLng, // user's current longitude
  //     isPunchedIn: isPunchedIn.value,
  //     image: File(selfie.value!.path),
  //     radius: LocationService.radius,
  //   );

  //   if (success) {
  //     isPunchedIn.toggle();

  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           isPunchedIn.value ? "Punch In successful" : "Punch Out successful",
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(
  //         content: Text("Unable to mark attendance"),
  //       ),
  //     );
  //   }
  // }

  // Future<void> checkTodayAttendance() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   String today = DateTime.now().toString().split(" ")[0];

  //   String? attendanceDate = prefs.getString("attendance_date");

  //   if (attendanceDate == today) {
  //     isAttendanceCompleted.value = true;
  //   }
  // }

  // Future<void> checkTodayAttendance() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   final today = DateTime.now().toString().split(" ")[0];

  //   final attendanceDate = prefs.getString("attendance_date");
  //   final punchedIn = prefs.getBool("is_punched_in") ?? false;

  //   if (attendanceDate == today) {
  //     isPunchedIn.value = punchedIn;

  //     // Only true after punch-out
  //     isAttendanceCompleted.value = !punchedIn;
  //   } else {
  //     // New day
  //     isPunchedIn.value = false;
  //     isAttendanceCompleted.value = false;

  //     // Optional: clear old attendance state
  //     await prefs.remove("attendance_date");
  //     await prefs.remove("is_punched_in");
  //   }
  // }
  Future<void> checkTodayAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(today);

    final attendanceDate = prefs.getString("attendance_date");
    final punchedIn = prefs.getBool("is_punched_in") ?? false;

    // New day
    if (attendanceDate != todayString) {
      await prefs.setString("attendance_date", todayString);
      await prefs.setBool("is_punched_in", false);
      await prefs.setBool("attendance_completed", false);

      isPunchedIn.value = false;
      isAttendanceCompleted.value = false;

      return;
    }

    // Same day
    isPunchedIn.value = punchedIn;

    // IMPORTANT:
    // Do NOT use !punchedIn here.
    // Attendance completion will be decided by API.
    isAttendanceCompleted.value =
        prefs.getBool("attendance_completed") ?? false;
  }

  // bool isHoliday(DateTime day) {
  //   final attendance = attendanceOf(day);

  //   if (attendance == null) return false;

  //   return attendance.status.toLowerCase() == "Holiday (Holiday)";
  // }

  bool isHoliday(DateTime day) {
    final attendance = selectedAttendance.value;

    if (attendance == null) {
      return false;
    }

    final attendanceDate = DateTime.parse(attendance.date);

    final sameDate = attendanceDate.year == day.year &&
        attendanceDate.month == day.month &&
        attendanceDate.day == day.day;

    if (!sameDate) {
      return false;
    }

    final status = attendance.status.toLowerCase().trim();

    debugPrint("Date: ${attendance.date}");
    debugPrint("Status: $status");

    return status.contains("holiday");
  }

  @override
  void onClose() {
    cameraController?.dispose();
    faceDetector.close();
    super.onClose();
  }
}
