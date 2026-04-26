import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/core/widgets/custom_snackbars.dart';
import 'package:smart_solutions/models/mobile_number_fetching.dart';
import 'package:smart_solutions/services/api_service.dart';
import 'package:smart_solutions/views/followBackForm.dart';
import '../constants/services.dart';
import '../services/CallHelper.dart';
import '../services/call_state_service.dart';
import 'follow_form_controller.dart';

class DialerController extends GetxController {
  var dialNumber = ''.obs;
  var isLoading = false.obs;
  var phoneNumber = ''.obs;
  var customerName = ''.obs;
  var customerLoan = ''.obs;
  var salary = ''.obs;
  var excel_id = ''.obs;
  var datatype = ''.obs;
  DateTime? callStartTime;
  var isCallOngoing = false.obs;
  RxBool isFirstTime = true.obs;
  Timer? _timer;
  RxInt elapsedTimeInSeconds = 0.obs;
  final ApiService apiService = ApiService();
  StreamSubscription<PhoneStateStatus>? _phoneStateSubscription;
  var followup_id = ''.obs;

  var isManual = true.obs;
  final customerNameController = TextEditingController();

  RxBool isCallInfoLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // ever(customerName, (name) => customerNameController.text = name);

    checkAndRequestPermissions();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _phoneStateSubscription?.cancel();
    customerNameController.dispose();
    super.onClose();
  }

  // Future<void> fetchLastCallInfoIfNeeded(bool shouldFetch) async {
  //   if (!shouldFetch) {
  //     return;
  //   }

  //   try {
  //     isCallInfoLoading.value = true;
  //     await CallStateService.getLastCallInfo();
  //   } catch (e) {
  //     debugPrint('Call info error: $e');
  //   } finally {
  //     isCallInfoLoading.value = false;
  //   }
  // }

  Future<void> fetchLastCallInfoIfNeeded(bool manualContact) async {
    final FollowBackFormController formController =
        Get.find<FollowBackFormController>();

    if (!manualContact) {
      if (!formController.isDurationAvailable.value) {
        formController.isDurationAvailable.value = true;
      }

      if (formController.contacted.value != 'No') {
        formController.contacted.value = 'No';
      }

      return;
    }

    /// ⭐ Prevent multiple API calls
    if (isCallInfoLoading.value) return;

    try {
      isCallInfoLoading(true);

      /// ⭐ Reset previous call state (VERY IMPORTANT)
      // resetDurationState();

      /// ⭐ Add timeout protection
      await CallStateService.getLastCallInfo()
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Call info error: $e');
    } finally {
      isCallInfoLoading(false);
    }
  }

  String formatElapsedTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  Future<void> fetchNextPhoneNumber() async {
    if (isManual.value) {
      return;
    }
    isLoading(true);
    try {
      final response = await apiService.postRequest(
        'Auth/mobile_fetch',
        {"telecaller_id": StaticStoredData.userId},
      );
      if (response.statusCode == 200) {
        final fetchedData = FetchingNumber.fromJson(jsonDecode(response.body));
        if (fetchedData.mobileNo != null) {
          phoneNumber.value = fetchedData.mobileNo!;
          customerName.value = fetchedData.name!;
          datatype.value = fetchedData.dataType ?? "";
          //   salary.value = fetchedData.
          customerLoan.value =
              double.tryParse(fetchedData.amount.toString())?.toString() ?? '0';
          excel_id.value = fetchedData.excelId!;

          print("CustomerName: ${customerName.value}");
          print("FID: ${followup_id.value}");
        } else if (response.statusCode == 204) {
          phoneNumber.value = '';
          customerName.value = '';
          datatype.value = '';
          customerLoan.value = '';
          excel_id.value = '';
          CustomSnackbars().showErrorSnackbar(
              title: "Opps", message: "No phone number found in response");
        }
      } else if (response.statusCode == 204) {
        phoneNumber.value = '';
        customerName.value = '';
        datatype.value = '';
        customerLoan.value = '';
        excel_id.value = '';
        CustomSnackbars().showWarningSnackbar(
            title: "Opps", message: "No phone number found in response");
      } else {
        CustomSnackbars().showErrorSnackbar(
            title: "Error", message: "Failed to fetch phone number");
      }
    } catch (e) {
      logOutput("$e");
      CustomSnackbars()
          .showErrorSnackbar(title: "Error", message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> makePhoneCall(String phone, {String? followUpId}) async {
    print("Phone number is $phone");
    print("Follow Up ID $followUpId");
    var status = await Permission.phone.request();
    if (status.isGranted) {
      CallHelper.makeDirectCall(phone);
    } else {
      CustomSnackbars().showErrorSnackbar(
          title: "Error", message: "Phone call permission not granted");
    }
  }

  Future<void> handlePhoneCall() async {
    callStartTime = DateTime.now();
    isCallOngoing.value = true;
    // startTimer();
  }

  void _initPhoneStateListener() async {
    PhoneState.stream.listen((PhoneState state) {
      final PhoneStateStatus status;
      if (isFirstTime.value) {
        status = PhoneStateStatus.NOTHING;
        isFirstTime.value = false;
      } else {
        status = state.status;
      }
      switch (status) {
        case PhoneStateStatus.CALL_STARTED:
          logOutput("Call started");
          handlePhoneCall();
          break;

        case PhoneStateStatus.CALL_ENDED:
          handleCallEnd();
          logOutput("Call Ended");
          break;

        case PhoneStateStatus.CALL_INCOMING:
          logOutput("Call started");
          handlePhoneCall();
          break;
        default:
          logOutput("No active call state detected");
          break;
      }
    });
  }

  Future<void> checkAndRequestPermissions() async {
    var status = await Permission.phone.status;

    if (status.isGranted) {
      _initPhoneStateListener();
    } else if (status.isDenied) {
      // Request permission and handle response.
      final result = await Permission.phone.request();
      if (result.isGranted) {
        _initPhoneStateListener();
      } else if (result.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        CustomSnackbars().showErrorSnackbar(
            title: "Permission Denied",
            message: "Phone permission is required.");
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    Get.defaultDialog(
      title: "Permission Required",
      middleText: "Phone permission is required. Please enable it in settings.",
      textConfirm: "Go to Settings",
      textCancel: "Cancel",
      onConfirm: () async {
        await openAppSettings();
        Get.back(); // Close the dialog after opening settings.
      },
    );
  }

  void handleCallEnd() async {
    print("handleCallEnd() called");
    isCallOngoing.value = false;
    //  _timer?.cancel();
    logOutput("${customerName.value}:${phoneNumber.value}");

    final role = StaticStoredData.roleName;

    if (role == 'telecaller') {
      Get.to(() => const FollowBackForm(isgetData: true));
    }

    // Get.to(() => const FollowBackForm(isgetData: true));

    // final callInfo = await CallStateService.getLastCallInfo();

    // debugPrint("Last Call Info: $callInfo");

    //  final callInfo =
//    await CallStateService.getLastCallInfo();

    // final int duration = callInfo['duration'] ?? 0;
    // final String type = callInfo['type'] ?? 'unknown';
    // final String name = callInfo['name'] ?? 'Unknown';
    // final String number = callInfo['number'] ?? '';

    // elapsedTimeInSeconds.value = duration;
    // callStartTime = null;
    // // customerLoan.value = '';
    // if (type == "incoming") {
    //   customerName.value = name;
    //   phoneNumber.value = number;
    // } else {
    //   customerName.value = '';
    //   // elapsedTimeInSeconds.value = 0;
    //   phoneNumber.value = '';
    // }
    // Log values for debugging
    logOutput(
        "incoming call data ${customerName.value}:${phoneNumber.value} | Duration: ${elapsedTimeInSeconds.value}s");
  }

  void handleFormSubmitAndFetchNext() {
    Get.back();
    phoneNumber.value = '';
    customerLoan.value = '';
    customerName.value = '';
    // fetchNextPhoneNumber();
  }

  String formatCurrency(String value) {
    try {
      double amount = double.parse(value);
      return NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      return ''; // Return default value if parsing fails
    }
  }

  void setPhoneNumberOnce(String number) {
    phoneNumber.value = number;
  }
}
