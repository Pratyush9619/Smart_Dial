import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import 'package:smart_solutions/controllers/profile_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';

import '../../theme/app_theme.dart';
import '../../widget/common_scaffold.dart';
import '../../widget/text_style.dart';
import 'attendence_detail_page.dart';
import 'bank_detail_page.dart';
import 'current_employement_page.dart';
import 'personal_detail_screen.dart';

// class ProfileScreen extends StatelessWidget {
//   ProfileScreen({super.key});

//   final ProfileController controller = Get.find<ProfileController>();
//   final ThemeController themeController = Get.find<ThemeController>();

//   ImageProvider? profileImage() {
//     if (controller.imageFile.value != null) {
//       return FileImage(controller.imageFile.value!);
//     } else if (controller.profileImageUrl.value.isNotEmpty) {
//       return NetworkImage(controller.profileImageUrl.value);
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CommonScaffold(
//       title: "Profile Photo",
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 30),

//             /// IMAGE PREVIEW
//             Obx(
//               () => CircleAvatar(
//                 radius: 70,
//                 backgroundColor: Colors.grey.shade200,
//                 backgroundImage: profileImage(),
//                 child: profileImage() == null
//                     ? const Icon(Icons.person, size: 70, color: Colors.grey)
//                     : null,
//               ),
//             ),

//             const SizedBox(height: 40),

//             /// CHANGE PHOTO
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.photo_library),
//                 label: const Text("Change Photo"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: themeController.primaryColor.value,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 onPressed: () async {
//                   await controller.pickImage();
//                 },
//               ),
//             ),

//             const SizedBox(height: 15),

//             /// REMOVE PHOTO
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 icon: const Icon(Icons.delete, color: Colors.red),
//                 label: const Text(
//                   "Remove Photo",
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Colors.red),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 onPressed: () {
//                   controller.imageFile.value = null;
//                   controller.profileImageUrl.value = '';
//                 },
//               ),
//             ),

//             const Spacer(),

//             /// SAVE BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: Obx(() {
//                 final hasImage = controller.imageFile.value != null;

//                 return ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: hasImage
//                         ? themeController.primaryColor.value
//                         : Colors.grey,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   onPressed: hasImage
//                       ? () async {
//                           await controller.saveProfile();
//                           Get.back();
//                         }
//                       : null, // 🚫 disabled
//                   child: const Text("Save"),
//                 );
//               }),
//             ),
//             // SizedBox(
//             //   width: double.infinity,
//             //   child: ElevatedButton(
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: themeController.primaryColor.value,
//             //       padding: const EdgeInsets.symmetric(vertical: 14),
//             //     ),
//             //     onPressed: () async {
//             //       await controller.saveProfile();
//             //       Get.back();
//             //     },
//             //     child: const Text("Save"),
//             //   ),
//             // ),
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
  final controller = Get.find<ProfileController>();
  final ThemeController themeController = Get.find<ThemeController>();

  ImageProvider? profileImage() {
    if (controller.imageFile.value != null) {
      return FileImage(controller.imageFile.value!);
    } else if (controller.profileImageUrl.value.isNotEmpty) {
      return NetworkImage(controller.profileImageUrl.value);
    } else {
      return null;
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
      body: SingleChildScrollView(
        // ✅ FIX
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PROFILE HEADER
            Container(
              color: AppColors.appBarTextColor,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 55,
                          backgroundImage: profileImage(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.pickImage,
                          // _openProfileImageBottomSheet,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: themeController.primaryColor.value,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.nameController.text,
                          style: AppTextStyle.headerTitle),
                      const SizedBox(height: 6),
                      Text(controller.usernameController.text,
                          style: AppTextStyle.bodyBoldTxt),
                      const SizedBox(height: 6),
                      // Text(controller.roleController.text,
                      //     style: AppTextStyle.label),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// PROFILE SECTIONS
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 10),
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
                  Divider(height: 1, color: Colors.grey.shade300),
                  buildSectionTile(
                    "assets/hrms/current_employement.svg",
                    "Current Employment",
                    () => const CurrentEmploymentPage(),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  buildSectionTile(
                    "assets/hrms/attendance_details.svg",
                    "Attendance Details",
                    () => const AttendanceModesScreen(),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
                  buildSectionTile(
                    "assets/hrms/bank_details.svg",
                    "Bank Details",
                    () => const BankDetailsPage(),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),
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
      ),
    );
  }

  // void _openProfileImageBottomSheet() {
  //   if (Get.isBottomSheetOpen == true) return;

  //   Get.bottomSheet(
  //     Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             height: 4,
  //             width: 40,
  //             margin: const EdgeInsets.only(bottom: 15),
  //             decoration: BoxDecoration(
  //               color: Colors.grey.shade400,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //           Row(
  //             children: [
  //               const Expanded(
  //                 child: Text(
  //                   "Upload Profile Photo",
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //                 ),
  //               ),
  //               GestureDetector(
  //                 onTap: () => Get.back(),
  //                 child: const Icon(Icons.close, color: Colors.grey),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 15),
  //           ListTile(
  //             leading: SvgPicture.asset("assets/hrms/gallery.svg"),
  //             title: const Text("Gallery"),
  //             onTap: () {
  //               Get.back();
  //               controller.pickImage();
  //             },
  //           ),
  //           ListTile(
  //             leading: SvgPicture.asset("assets/hrms/camera.svg"),
  //             title: const Text("Camera"),
  //             onTap: () {
  //               Get.back();
  //               controller.pickImage();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     backgroundColor: Colors.white,
  //   );
  // }
}
