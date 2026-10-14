import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';

import '../../constants/api_urls.dart';
import '../../constants/static_stored_data.dart';
import '../../models/hrms/profile.dart';
import '../../services/api_service.dart';

class ViewProfileController extends GetxController {
  final ApiService apiService = ApiService();

  RxBool isLoading = false.obs;

  Rxn<ProfileModel> profile = Rxn<ProfileModel>();

  RxString profileImageUrl = ''.obs;
  Rx<File?> imageFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    getProfileDetails();
  }

  Future<void> getProfileDetails() async {
    try {
      isLoading(true);

      final response = await apiService.getNewBaseUrlRequest(
        "${APIUrls.userDetails}?user_id=${StaticStoredData.userId}",
      );

      print("PROFILE RESPONSE: $response");

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        profile.value = ProfileModel.fromJson(
          data['data'],
        );

        profileImageUrl.value = profile.value?.profileImage ?? '';
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Unable to fetch profile",
        );
      }
    } catch (e) {
      print("Profile API Error: $e");

      Get.snackbar(
        "Error",
        "Something went wrong while loading profile",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage() async {
    // Your existing image picker logic
  }
}
