import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/theme_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkForUpdate();
    _loadVersion();
    _checkLoginStatus(); // Check login status when the splash screen initializes
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    return Color(int.parse(hex, radix: 16));
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(
      'userId',
    ); // Retrieve user ID from Shared Preferences
    String? roleName = prefs.getString('roleName');
    String? number = prefs.getString('userName');
    String? colorCode = prefs.getString('themeColor');

    if (colorCode != null && colorCode.isNotEmpty) {
      StaticStoredData.themeColor = colorCode;
      themeController.loadSavedTheme();
    }

    Future.delayed(const Duration(seconds: 3), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userId != null) {
          StaticStoredData.userId = userId;
          StaticStoredData.roleName = roleName ?? '';
          StaticStoredData.number = number ?? '';
          StaticStoredData.themeColor = colorCode ?? '';

          Get.offAllNamed(AppRoutes.navigationscreen);
        } else {
          StaticStoredData.userId = '';
          StaticStoredData.roleName = '';
          Get.offAllNamed(AppRoutes.login);
        }
      });
    });
  }

  Future<void> checkForUpdate() async {
    // Skip update checks entirely in debug mode
    if (kDebugMode) {
      debugPrint("🚫 Skipping in-app update in debug mode.");
      _checkLoginStatus();
      return;
    }

    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.immediateUpdateAllowed) {
        // Force the user to update immediately
        await InAppUpdate.performImmediateUpdate();
      } else {
        _checkLoginStatus();
      }
    } catch (e) {
      final errorMsg = e.toString();

      // Specific handling for sideload/debug error
      if (errorMsg.contains("ERROR_APP_NOT_OWNED") ||
          errorMsg.contains("Install Error(-10)") ||
          errorMsg.contains('PlatformException(TASK_FAILURE') ||
          errorMsg.contains('java.lang.NullPointerException')) {
        debugPrint("⚠️ Skipping update: app not owned by Play Store.");
        // Don’t stop app — just continue normally
        _checkLoginStatus();
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   navigateToHome();
        // });
      } else {
        debugPrint("❌ Update check failed: $e");
        _checkLoginStatus();
      }
    }
  }

  String appVersion = '';

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "Version ${info.version}";
    });
  }

  static final ThemeController themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1976D2), // Your theme color
              Color(0xFF1565C0), // Slight darker shade
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 900),
                tween: Tween(begin: 0.7, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    height: 140.h,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Smart Dial",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Smart Business Tracking",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              /// Loading Indicator
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),

              const SizedBox(height: 20),

              Text(
                appVersion,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
