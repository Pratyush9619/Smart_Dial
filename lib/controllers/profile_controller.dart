import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import '../constants/api_urls.dart';
import '../constants/services.dart';
import '../services/api_service.dart';

class ProfileController extends GetxController {
  var imageFile = Rx<File?>(null);

  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  var isLoading = false.obs;
  var profileImageUrl = "".obs;
  final ImagePicker picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    getProfileData(StaticStoredData.userId);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Get.back(); // ✅ close bottom sheet first

                    await Future.delayed(const Duration(milliseconds: 300));

                    try {
                      final XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (pickedFile != null) {
                        imageFile.value = File(pickedFile.path);
                        await saveProfile();
                      }
                    } catch (e) {
                      Get.snackbar('Error', 'Unable to open gallery');
                    }
                  }),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back(); // close sheet safely
                  await Future.delayed(const Duration(milliseconds: 200));
                  await pickImageFromGallery();
                  //   final pickedFile =
                  //       await picker.pickImage(source: ImageSource.camera);

                  //   if (pickedFile != null) {
                  //     imageFile.value = File(pickedFile.path);

                  //     Get.back(); // Close the bottom sheet before saving
                  //     // ✅ AUTO SAVE AFTER SELECT
                  //     await saveProfile();
                  //   } else {
                  //     Get.back();
                  //   }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Save Profile (ONLY on button click)
  Future<void> saveProfile() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      var fields = {
        "telecaller_id": StaticStoredData.userId,
        "name": nameController.text.trim(),
        "mobileno": usernameController.text.trim(),
      };

      File? image = imageFile.value;

      var response =
          await ApiService().postRequest(APIUrls.profileUpdate, fields);

      if (image != null) {
        response = await ApiService().multipartPostRequest(
          APIUrls.profileUpdate,
          fields,
          image,
          'profile_image',
        );
      } else {
        response =
            await ApiService().postRequest(APIUrls.profileUpdate, fields);
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text(
              "Profile updated successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );

        await getProfileData(StaticStoredData.userId);

        //   Get.offAllNamed(AppRoutes.home);
      } else {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text("Failed to update profile"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      logOutput("Profile error: $e");
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Fetch Profile
  Future<void> getProfileData(String id) async {
    try {
      isLoading.value = true;

      var response = await ApiService().postRequest(
        APIUrls.fetchProfileImage,
        {"telecaller_id": id},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        nameController.text = data["data"]["name"] ?? "";
        usernameController.text = data["data"]["username"] ?? "";

        final imageData = data["data"]["profile_image"];

        if (imageData is String && imageData.isNotEmpty) {
          profileImageUrl.value = APIUrls.imagebaseUrl + imageData;
        } else if (imageData is Map && imageData["url"] != null) {
          profileImageUrl.value = APIUrls.imagebaseUrl + imageData["url"];
        }
      }
    } catch (e) {
      logOutput("Fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      PermissionStatus status;

      // ✅ Android permission handling
      if (Platform.isAndroid) {
        status = await Permission.photos.request();

        // Android < 13 fallback
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }

      // ❌ Permission denied
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Required',
          'Gallery permission denied\nStatus: $status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      // ✅ Open gallery
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      // ❌ User cancelled picker
      if (pickedFile == null) {
        Get.snackbar(
          'Cancelled',
          'No image selected',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // ✅ Set image
      imageFile.value = File(pickedFile.path);

      // ✅ Save profile / upload
      await saveProfile();
    } catch (e, stackTrace) {
      // 🧪 Debug logs
      debugPrint('Gallery Error: $e');
      debugPrint('StackTrace: $stackTrace');

      // 🚨 Visible error for tester/user
      Get.snackbar(
        'Gallery Error (${e.runtimeType})',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 10),
        margin: const EdgeInsets.all(12),
        isDismissible: true,
      );
    }
  }
  // Future<void> pickImageFromGallery() async {
  //   try {
  //     final status = await Permission.photos.request();

  //     if (!status.isGranted) {
  //       Get.snackbar('Permission Required', 'Please allow gallery access');
  //       return;
  //     }

  //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //     if (pickedFile != null) {
  //       imageFile.value = File(pickedFile.path);
  //       await saveProfile();
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error', 'Unable to open gallery');
  //   }
  // }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
