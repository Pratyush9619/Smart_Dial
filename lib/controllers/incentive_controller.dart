import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/api_urls.dart';
import '../constants/static_stored_data.dart';
import '../models/team_leader_model.dart';
import '../services/api_service.dart';
import '../views/incentive/model/incentive_model.dart';

class IncentiveController extends GetxController {
  final ApiService _apiService = ApiService();
  // 🔍 Search
  final TextEditingController searchController = TextEditingController();
  RxString searchText = ''.obs;
  final teamleaderList = <TeamleaderData>[].obs;

  // 🎯 Filters (like AdminCallBack)
  RxList<String> filters = <String>[].obs;

  RxInt selectedFilter = 0.obs;
  final ScrollController filterScrollController = ScrollController();

  // 📊 DATA
  RxBool isLoading = false.obs;
  RxBool isApiLoaded = false.obs;
  final RxList<IncentiveUser> incentiveList = <IncentiveUser>[].obs;
  final RxList<IncentiveUser> filteredList = <IncentiveUser>[].obs;
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  final Rx<DateTime?> selectedMonth = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    getteamLeaderData();
    loadFromApi();

    ever(selectedFilter, (_) => applyFilters());
  }

  // MOCK / API DATA
  Map<String, dynamic> buildFilterParams() {
    final params = <String, dynamic>{};

    params['telecaller_id'] = StaticStoredData.userId;
    if (searchText.value.isNotEmpty) {
      params['search'] = searchText.value;
    }

    if (selectedMonth.value != null) {
      params['daterange'] = DateFormat('yyyy-MM').format(selectedMonth.value!);
    }

    return params;
  }

  /// 🔥 LOAD FROM API
  Future<void> loadFromApi() async {
    try {
      isLoading.value = true;
      isApiLoaded.value = false;

      final params = buildFilterParams();
      final response =
          await ApiService().postRequest(APIUrls.incentiveData, params);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List list = decoded['data'] ?? [];
        final users = list.map((e) => IncentiveUser.fromJson(e)).toList();

        incentiveList.assignAll(users);
        filteredList.assignAll(users);
      } else {
        Get.snackbar(
          'Error',
          'Failed to load data (${response.statusCode})',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong',
      );
      debugPrint('API ERROR: $e');
    } finally {
      isLoading.value = false;
      isApiLoaded.value = true;
    }
  }

  /// 🔍 FILTER

  /// 🔍 SEARCH + FILTER LOGIC /// 🎯 FILTER SELECT
  void selectFilter(int index) {
    selectedFilter.value = index;
  }

  void clearFilters() {
    searchController.clear();
    searchText.value = '';
    selectedFilter.value = 0;

    selectedMonth.value = null; // ✅ FIX

    loadFromApi();

    applyFilters();
  }

  void selectMonth(DateTime month) {
    selectedMonth.value = month;

    searchController.text = DateFormat('MMM yyyy').format(month);

    loadFromApi(); // or updateFilteredList()
  }

  /// 🔢 TOTALS (LIVE)
  int get totalUsers => filteredList.length;

  double get totalTarget => filteredList.fold(0, (s, e) => s + e.totalTarget);

  double get totalAchieved => filteredList.fold(0, (s, e) => s + e.achievement);

  double get totalIncentive => filteredList.fold(
        0,
        (s, e) => s + (e.achievement * e.achievementPercent / 100),
      );

  Future<void> getteamLeaderData() async {
    isLoading.value = true;
    try {
      final response =
          await _apiService.getRequest(APIUrls.loginRequestTeamLeader);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final model = TealLeaderModel.fromJson(json);

        teamleaderList.assignAll(model.data);
        filters.assignAll(['All', ...model.data.map((e) => e.name)]);
      }
    } catch (e) {
      debugPrint('❌ Team leader error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    if (selectedFilter.value == 0) {
      // All
      filteredList.assignAll(incentiveList);
      return;
    }

    final selectedLeader = teamleaderList[selectedFilter.value - 1];

    filteredList.assignAll(
      incentiveList.where(
        (user) => user.teamLeaderId == selectedLeader.id,
      ),
    );
  }
}
