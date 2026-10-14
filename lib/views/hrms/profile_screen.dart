import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import '../../controllers/hrms/profile_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_theme.dart';
import '../../widget/common_scaffold.dart';
import '../../widget/text_style.dart';
import 'attendence_detail_page.dart';
import 'bank_detail_page.dart';
import 'current_employement_page.dart';
import 'personal_detail_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final controller = Get.find<ProfileController>();
//   final ThemeController themeController = Get.find<ThemeController>();

//   ImageProvider? profileImage() {
//     if (controller.imageFile.value != null) {
//       return FileImage(controller.imageFile.value!);
//     } else if (controller.profileImageUrl.value.isNotEmpty) {
//       return NetworkImage(controller.profileImageUrl.value);
//     } else {
//       return null;
//     }
//   }

//   Widget buildSectionTile(
//     String iconPath,
//     String title,
//     Widget Function() pageBuilder,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(pageBuilder);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//         child: Row(
//           children: [
//             SvgPicture.asset(
//               iconPath,
//               height: 24,
//               width: 24,
//               color: themeController.primaryColor.value,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: AppTextStyle.headerTitle,
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16,
//               color: Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CommonScaffold(
//       title: "Profile",
//       body: SingleChildScrollView(
//         // ✅ FIX
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// PROFILE HEADER
//             Container(
//               color: AppColors.appBarTextColor,
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Stack(
//                     children: [
//                       Obx(
//                         () => CircleAvatar(
//                           radius: 55,
//                           backgroundImage: profileImage(),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: GestureDetector(
//                           onTap: controller.pickImage,
//                           // _openProfileImageBottomSheet,
//                           child: CircleAvatar(
//                             radius: 16,
//                             backgroundColor: themeController.primaryColor.value,
//                             child: SvgPicture.asset(
//                               "assets/hrms/pencil.svg",
//                               width: 17.w,
//                               height: 17.h,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(controller.nameController.text,
//                           style: AppTextStyle.headerTitle),
//                       const SizedBox(height: 6),
//                       Text(controller.usernameController.text,
//                           style: AppTextStyle.bodyBoldTxt),
//                       const SizedBox(height: 6),
//                       // Text(controller.roleController.text,
//                       //     style: AppTextStyle.label),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),

//             /// PROFILE SECTIONS
//             Container(
//               width: double.infinity,
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 color: AppColors.appBarTextColor,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 6,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   buildSectionTile(
//                     "assets/hrms/user.svg",
//                     "Personal Details",
//                     () => const PersonalDetailScreen(),
//                   ),
//                   Divider(height: 1, color: Colors.grey.shade300),
//                   buildSectionTile(
//                     "assets/hrms/current_employement.svg",
//                     "Current Employment",
//                     () => const CurrentEmploymentPage(),
//                   ),
//                   Divider(height: 1, color: Colors.grey.shade300),
//                   buildSectionTile(
//                     "assets/hrms/attendance_details.svg",
//                     "Attendance Details",
//                     () => const AttendanceModesScreen(),
//                   ),
//                   Divider(height: 1, color: Colors.grey.shade300),
//                   buildSectionTile(
//                     "assets/hrms/bank_details.svg",
//                     "Bank Details",
//                     () => const BankDetailsPage(),
//                   ),
//                   Divider(height: 1, color: Colors.grey.shade300),
//                   buildSectionTile(
//                     "assets/hrms/user_permission.svg",
//                     "User Permission",
//                     () => const CurrentEmploymentPage(),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = Get.find<ViewProfileController>();
  final ThemeController themeController = Get.find<ThemeController>();

  ImageProvider? profileImage() {
    if (controller.imageFile.value != null) {
      return FileImage(controller.imageFile.value!);
    }

    if (controller.profileImageUrl.value.isNotEmpty) {
      return NetworkImage(
        controller.profileImageUrl.value,
      );
    }

    return null;
  }

  Widget buildSectionTile(
    String iconPath,
    String title,
    Widget Function() pageBuilder,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(pageBuilder);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              width: 24,
              color: themeController.primaryColor.value,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyle.headerTitle,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "Profile",
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final profile = controller.profile.value;

        if (profile == null) {
          return const Center(
            child: Text("Profile data not available"),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PROFILE HEADER
              Container(
                color: AppColors.appBarTextColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: profileImage(),
                          child: profileImage() == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: controller.pickImage,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  themeController.primaryColor.value,
                              child: SvgPicture.asset(
                                "assets/hrms/pencil.svg",
                                width: 17.w,
                                height: 17.h,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name ?? "-",
                            style: AppTextStyle.headerTitle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.username ?? "-",
                            style: AppTextStyle.bodyBoldTxt,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            profile.roleName ?? "-",
                            style: AppTextStyle.label,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// PROFILE SECTIONS
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.appBarTextColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    buildSectionTile(
                      "assets/hrms/user.svg",
                      "Personal Details",
                      () => const PersonalDetailScreen(),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    buildSectionTile(
                      "assets/hrms/current_employement.svg",
                      "Current Employment",
                      () => const CurrentEmploymentPage(),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    buildSectionTile(
                      "assets/hrms/attendance_details.svg",
                      "Attendance Details",
                      () => const AttendanceModesScreen(),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    buildSectionTile(
                      "assets/hrms/bank_details.svg",
                      "Bank Details",
                      () => const BankDetailsPage(),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                    buildSectionTile(
                      "assets/hrms/user_permission.svg",
                      "User Permission",
                      () => const CurrentEmploymentPage(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
