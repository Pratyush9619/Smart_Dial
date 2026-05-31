import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/routes/app_routes.dart';
import 'package:smart_solutions/services/api_service.dart';
import '../constants/static_stored_data.dart';
import '../controllers/internet_checker.dart';

class LogoutHelper {
  // Add BuildContext as a parameter
  // static Future<void> logout(BuildContext context) async {
  //   // 1. Clear Data
  //   final prefs = await SharedPreferences.getInstance();

  //   // 2. Clear GetX state
  //   // We use force: true to ensure all controllers are removed
  //   Get.deleteAll(force: true);

  //   final response = await ApiService().postRequest(
  //       APIUrls.logout, {'tellecaller_id': StaticStoredData.userId});

  //   if (response.statusCode == 200) {
  //     await prefs.clear();
  //     StaticStoredData.userId = '';
  //     StaticStoredData.number = '';
  //     Get.offAllNamed(AppRoutes.login);
  //     // 4. Re-initialize after navigation if needed
  //     Get.put(ConnectivityController(), permanent: true);
  //     Get.put(ThemeController(), permanent: true);
  //   }
  // }

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final userId = StaticStoredData.userId;

    try {
      // 1️⃣ Call logout API first (don’t block UI flow)
      await ApiService().postRequest(
        APIUrls.logout,
        {'telecaller_id': userId},
      );
    } catch (e) {
      // ignore API failure → still logout locally
    }

    // 2️⃣ Clear storage
    await prefs.clear();
    StaticStoredData.userId = '';
    StaticStoredData.number = '';

    // 3️⃣ Remove all controllers
    Get.deleteAll(force: true);

    // 4️⃣ Smooth navigation (IMPORTANT FIX)
    Future.microtask(() {
      Get.offAllNamed(AppRoutes.login);
    });

    Get.put(ConnectivityController(), permanent: true);
    Get.put(ThemeController(), permanent: true);
  }
}
