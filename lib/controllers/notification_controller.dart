import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import '../services/api_service.dart';
import '../constants/api_urls.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = ApiService();

  var notificationData = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  Rx<int> unreadCount = 0.obs;

  RxInt notificationPage = 1.obs;
  RxBool notificationHasMore = true.obs;
  RxBool notificationInitialLoading = false.obs;
  RxBool notificationMoreLoading = false.obs;

  final int notificationLimit = 20; // or API limit

  @override
  void onInit() {
    getNotificationCount();
    getNotificationList();
    super.onInit();
  }

  Future<void> getNotificationList({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!notificationHasMore.value) return; // ⭐ stop extra calls
        notificationMoreLoading.value = true;
      } else {
        notificationInitialLoading.value = true;
        notificationPage.value = 1;
        notificationHasMore.value = true;
        notificationData.clear();
      }

      var response = await _apiService.postRequest(
        APIUrls.getnotificationData,
        {
          "telecaller_id": StaticStoredData.userId,
          "page": notificationPage.value.toString(), // ⭐ pagination param
          "limit": notificationLimit.toString()
        },
      );

      debugPrint("notification --> ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final contacts = responseData['data'];

        if (contacts is List) {
          final newList = List<Map<String, dynamic>>.from(contacts);

          if (loadMore) {
            notificationData.addAll(newList);
          } else {
            notificationData.assignAll(newList);
          }

          // unreadCount.value =
          //     notificationData.where((e) => e['is_read'] == '0').length;

          notificationHasMore.value = newList.length >= notificationLimit;

          if (newList.isNotEmpty) {
            notificationPage.value++;
          }

          /// ⭐ mark read only on first load
          // if (!loadMore) {
          //   Future.microtask(() => markAllAsRead());
          // }
        }
      } else if (response.statusCode == 204) {
        notificationHasMore.value = false;
      }
    } catch (e) {
      print(e);
    } finally {
      notificationInitialLoading.value = false;
      notificationMoreLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      var response = await _apiService.postRequest(
        APIUrls.updatenotificationData,
        {
          "telecaller_id": StaticStoredData.userId,
        },
      );

      if (response.statusCode == 200) {
        // ⭐ Update local list instantly
        for (var item in notificationData) {
          item['is_read'] = '1';
        }

        // ⭐ Refresh RxList UI
        //    notificationData.refresh();

        // ⭐ Update count
        unreadCount.value = 0;

        debugPrint("✅ All notifications marked as read");
      }
    } catch (e) {
      debugPrint("Mark read error $e");
    }
  }

  Future<void> getNotificationCount() async {
    try {
      var response = await _apiService.postRequest(
        APIUrls.getnotificationCount,
        {"telecaller_id": StaticStoredData.userId},
      );

      debugPrint(
          "notification count --> ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        unreadCount.value = int.tryParse(responseData['data'].toString()) ?? 0;
      }
    } catch (e) {
      debugPrint("Get count error $e");
    }
  }
}
