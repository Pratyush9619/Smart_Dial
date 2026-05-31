import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/dashboard_controller.dart';
import 'package:smart_solutions/routes/app_routes.dart';
import 'package:smart_solutions/services/api_service.dart';
import '../constants/services.dart';

class LoginViewModel extends GetxController {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  Rxn<int> secureType = Rxn<int>(0); // Initialize with null
  var isLoading = false.obs;
  final ApiService _apiService = ApiService(); // ApiService instance
  final DashboardController dashboardController =
      Get.put(DashboardController(), permanent: true);

  RxnString loginError = RxnString();

  void login(String tokenData) async {
    isLoading.value = true;

    StaticStoredData.deviceId = await Services.getDeviceId();

    Map<String, dynamic> loginData = {
      'username': usernameController.text.trim(),
      'password': passwordController.text.trim(),
      'data_type': "${secureType.value}",
      'userimei': StaticStoredData.deviceId,
    };

    if (tokenData.isNotEmpty) {
      loginData['mobilefcm_token'] = tokenData;
    }
    logOutput(loginData.toString());
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      final response = await _apiService
          .postRequest(APIUrls.loginUrl, loginData, type: 'login');
      print("Login Response: ${response.statusCode} - ${response.body}");
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        StaticStoredData.userId = "";

        if (responseData['profile']['data']['message'] != null) {
          loginError.value =
              responseData['profile']['data']['message'].toString();

          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      responseData['profile']['data']['message']?.toString() ??
                          "Login Failed",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior:
                  SnackBarBehavior.floating, // Makes it float above the UI
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              elevation: 6,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          String userId = responseData['profile']['data']['profile']
              ['id']; // Adjust according to your API response structure
          String userName = responseData['profile']['data']['profile']
              ['name']; //  API returns name 1st change
          String roleName =
              responseData['profile']['data']['profile']['role_name'];

          String number =
              responseData['profile']['data']['profile']['username'];

          String colorCode =
              responseData['profile']['data']['profile']['theme_color'] ?? '';

          StaticStoredData.userId = userId;
          StaticStoredData.roleName = roleName;
          StaticStoredData.number = number;
          StaticStoredData.themeColor = colorCode;

          // Store the user ID locally using Shared Preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setString(
              'userName', userName); // Store username 2nd chnge
          await prefs.setString('roleName', roleName);
          await prefs.setString('themeColor', colorCode);
          // Secure Type
          if (secureType.value != null) {
            await prefs.setInt('secureType', secureType.value!);
          }
          // Store username 2nd chnge

          await prefs.setString(
              'companyname', responseData['profile']['companyname'].toString());

          await prefs.setString(
              'userToken', responseData['profile']['usertoken'].toString());

          showSuccessDialog(
            "Logged In Successfully",
            onComplete: () {
              Get.offAllNamed(AppRoutes.navigationscreen);
            },
          );

          //      Get.offAllNamed(AppRoutes.navigationscreen);

          // Get.off(() => const MainScreen(), binding: DashboardBinding());
          // showDialog(
          //     context: (Get.context!),
          //     builder: (context) => AlertDialog(
          //           // backgroundColor: Color(0xffFFE839),
          //           // title: Center(child: const Text("Attendance Marked")),
          //           content: Container(
          //               decoration: BoxDecoration(
          //                 // color: Colors.yellow,
          //                 borderRadius: BorderRadius.circular(20),
          //               ),
          //               child: Column(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   Lottie.asset("assets/animations/success.json",
          //                       height: 100, width: 100),
          //                   const Center(
          //                       child: Text(
          //                     "Logged In Successfully",
          //                     style: TextStyle(
          //                         color: Colors.black,
          //                         fontSize: 16,
          //                         fontWeight: FontWeight.bold),
          //                   )),
          //                 ],
          //               )),
          //           actions: [
          //             Center(
          //               child: FractionallySizedBox(
          //                 widthFactor: 0.6,
          //                 child: ElevatedButton(
          //                   style: ButtonStyle(
          //                       backgroundColor: WidgetStateProperty.all(
          //                           themeController.primaryColor.value)),
          //                   onPressed: () {
          //                     Get.back();
          //                   },
          //                   child: const Text(
          //                     "Okay",
          //                     style: TextStyle(color: Colors.white),
          //                   ),
          //                 ),
          //               ),
          //             )
          //           ],
          //         ));
        }
      } else if (response.statusCode == 401) {
        showErrorDialog(
          responseData['message'] ??
              "Unauthorized. Please check your credentials.",
          onComplete: () {},
        );
      } else if (response.statusCode == 402) {
        showErrorDialog(
          responseData['message'] ??
              "Payment Required. Please contact support.",
          onComplete: () {
            // Optional: You can perform additional actions after the dialog is closed
          },
        );
      } else if (response.statusCode == 409) {
        showErrorDialog(
          responseData['message'],
          onComplete: () {
            // Optional: You can perform additional actions after the dialog is closed
          },
        );
      } else {
        Get.snackbar('Error', 'Invalid username or password',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stackTrace) {
      logOutput("ERROR: $e");
      logOutput("STACKTRACE: $stackTrace");

      showErrorDialog(
        "An error occurred during login. Please contact your administrator.",
        onComplete: () {
          // Optional: You can perform additional actions after the dialog is closed
        },
      );
    }
    // logOutput('$e');
    // Get.snackbar('Error', 'Something went wrong. Please try again.');
    finally {
      isLoading.value = false;
    }
  }
}

void showSuccessDialog(String message, {VoidCallback? onComplete}) {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Animation
              Lottie.asset(
                "assets/animations/success.json",
                height: 120,
                repeat: false,
              ),

              const SizedBox(height: 15),

              const Text(
                "Success",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  /// Auto close after 2 seconds
  Future.delayed(const Duration(seconds: 2), () {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    if (onComplete != null) {
      onComplete();
    }
  });
}

void showErrorDialog(
  String message, {
  VoidCallback? onComplete,
  bool autoClose = true,
}) {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Error Animation
              // Lottie.asset(
              //   "assets/animations/error.json", // 🔴 add this
              //   height: 120,
              //   repeat: false,
              // ),

              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),

              const SizedBox(height: 15),

              const Text(
                "Error",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  /// Auto close
  if (autoClose) {
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      if (onComplete != null) {
        onComplete();
      }
    });
  }
}
