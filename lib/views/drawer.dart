import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/profile_controller.dart';
import 'package:smart_solutions/views/followBackForm.dart';
import 'package:smart_solutions/views/forget_password.dart';
import 'package:smart_solutions/views/listing_screen.dart';
import 'package:smart_solutions/views/theme_change_screen.dart';
import '../controllers/theme_controller.dart';
import '../services/logout_helper.dart';
import 'hrms/hrm_screen.dart';
import 'hrms/profile_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final ProfileController _profileController = Get.find<ProfileController>();

  String _userName = "";
  final RxInt _secureType = 0.obs;

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Name";
      _secureType.value = prefs.getInt('secureType') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final statusBarHeight = MediaQuery.of(context).padding.top;

    return SafeArea(
      top: true,
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.65,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // ================= HEADER =================
                Obx(
                  () => Container(
                    height: screenHeight.clamp(500, 900) * 0.25,
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: 16.w,
                      top: 16.h,
                      right: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: themeController.primaryColor.value,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => ProfileScreen()),
                          child: CircleAvatar(
                            radius: screenHeight * 0.05, // responsive avatar
                            backgroundColor: Colors.white,
                            backgroundImage: _profileController
                                        .imageFile.value !=
                                    null
                                ? FileImage(_profileController.imageFile.value!)
                                : (_profileController
                                        .profileImageUrl.value.isNotEmpty
                                    ? NetworkImage(_profileController
                                        .profileImageUrl.value)
                                    : const AssetImage(
                                            "assets/images/app_login.png")
                                        as ImageProvider),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _userName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 5.h,
                        ),
                        Text(
                          StaticStoredData.roleName.isEmpty
                              ? StaticStoredData.roleName.toUpperCase()
                              : "",
                          style: TextStyle(
                              fontSize: 12.sp, color: AppColors.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= BODY =================
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // if (StaticStoredData.roleName == 'telecaller')

                        (_secureType.value == 0 &&
                                StaticStoredData.roleName == 'telecaller')
                            ? _drawerSvgTile(
                                'assets/drawer/pin_marker.svg',
                                'Company & Pincode',
                                () => Get.to(
                                  () => ListingScreen(
                                    title: 'Listing',
                                    isShowBack: true,
                                    isDrawer: false,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        // if (StaticStoredData.roleName == 'telecaller')
                        //   _drawerSvgTile(
                        //     'assets/drawer/login_request.svg',
                        //     'Login Request',
                        //     () => Get.to(
                        //       () => LoginRequestScreen(
                        //         title: 'Login Request',
                        //         isShowBack: true,
                        //         isDrawer: false,
                        //       ),
                        //     ),
                        //   ),

                        // if (StaticStoredData.roleName == 'telecaller')
                        //   _drawerSvgTile(
                        //     'assets/drawer/about_us.svg',
                        //     'About Us',
                        //     () {},
                        //   ),
                        // if (StaticStoredData.roleName == 'telecaller')
                        // _drawerSvgTile(
                        //   'assets/drawer/lock.svg',
                        //   'Reset Password',
                        //   () => Get.to(() => const ForgetView()),
                        // ),

                        if (StaticStoredData.roleName == 'telecaller')
                          _drawerSvgTile(
                            'assets/drawer/hrm.svg',
                            'HRM',
                            () => Get.to(() => const HrmScreen()),
                          ),
                        // if (StaticStoredData.roleName == 'telecaller')
                        _drawerSvgTile(
                          'assets/drawer/theme.svg',
                          'Theme',
                          () => Get.to(() => ThemeChangeScreen()),
                        ),
                        const Spacer(),
                        const Divider(),

                        _drawerSvgTile(
                          'assets/drawer/lock.svg',
                          'Reset Password',
                          () => Get.to(() => const ForgetView()),
                        ),
                        _drawerTile(
                          'assets/drawer/log_out.svg',
                          'Log Out',
                          () async {
                            // Show a quick confirmation dialog

                            showLogoutDialog(context,
                                themeController: themeController);

                            // Get.defaultDialog(
                            //     title: "Logout",
                            //     middleText: "Are you sure you want to logout?",
                            //     textConfirm: "Yes",
                            //     textCancel: "No",
                            //     confirmTextColor: Colors.white,
                            //     onConfirm: () async {
                            //       // Close the dialog
                            //       Get.back();

                            //       // Pass the CURRENT context to the helper
                            //       await LogoutHelper.logout(context);
                            //     });

                            //previous logout  on upper side

                            // final prefs = await SharedPreferences.getInstance();
                            // await prefs.clear();

                            // StaticStoredData.userId = '';
                            // StaticStoredData.number = '';

                            // await Get.deleteAll(force: true);
                            // Get.put(ConnectivityController(), permanent: true);
                            // Get.put(ThemeController(), permanent: true);

                            // Get.offAll(() => const LoginView(),
                            //     binding: AppBinding());
                            // _followBackFormController.clearForm();

                            // final prefs = await SharedPreferences.getInstance();
                            // prefs.clear();

                            // StaticStoredData.userId = '';
                            // StaticStoredData.number = '';

                            // //       _profileController.nameController.clear();
                            // //       _profileController.usernameController.clear();
                            // _profileController.imageFile.value = null;
                            // _profileController.profileImageUrl.value = '';

                            // // if (Get.isRegistered<ProfileController>()) {
                            // //   Get.delete<ProfileController>();
                            // // }

                            // await Get.deleteAll(force: true);

                            // // 4️⃣ Re-register GLOBAL controllers
                            // Get.put(ConnectivityController(), permanent: true);
                            // Get.put(ThemeController(), permanent: true);

                            // Get.put(LoginViewModel());
                            // Get.offAll(() => const LoginView(),
                            //     binding: AppBinding());
                          },
                          isBottomTile: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ================= CLOSE BUTTON =================
            Positioned(
              top: 12.h,
              right: 12.w,
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.all(8.w), // optional padding inside safe area
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/drawer/cross.svg',
                      // width: 24.w,
                      // height: 24.h,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SVG TILE =================
  Widget _drawerSvgTile(String asset, String title, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.srcIn,
        ),
      ),
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      onTap: onTap,
    );
  }

  // ================= ICON TILE =================
  Widget _drawerTile(
    String asset,
    String title,
    VoidCallback onTap, {
    bool isBottomTile = false,
  }) {
    return ListTile(
      dense: true,
      leading: SizedBox(
        width: 24.w,
        height: 24.h,
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isBottomTile ? 16.sp : 14.sp,
          color: isBottomTile ? Colors.red : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}

void showLogoutDialog(BuildContext context,
    {required ThemeController themeController}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔵 Icon Circle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeController.primaryColor.value.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: themeController.primaryColor.value,
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              /// Buttons Row
              Row(
                children: [
                  /// Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: themeController.primaryColor.value),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: themeController.primaryColor.value,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeController.primaryColor.value,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Get.back();
                        await LogoutHelper.logout(context);
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
