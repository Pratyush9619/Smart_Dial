import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/models/disbursement_model.dart';
import 'package:smart_solutions/models/team_leader_model.dart';
import 'package:smart_solutions/services/api_service.dart';

import '../../constants/static_stored_data.dart';
import '../common_filter_controller.dart';

class DisbursementController extends GetxController {
  final ApiService _apiService = ApiService();

  /// Loading flags
  final isLoading = false.obs;
  final iscallDisbursedLoading = false.obs;

  /// Filters
  final filters = <String>[].obs;
  final selectedFilter = 0.obs;
  final searchController = TextEditingController();
  final filterScrollController = ScrollController();

  /// Data
  final teamleaderList = <TeamleaderData>[].obs;
  RxList<DisbursementData> disbursementList = <DisbursementData>[].obs;
  RxList<DisbursementData> allDisbursementList = <DisbursementData>[].obs;

  /// Totals (single object)
  final disbursementTotal = Rxn<disbursementTotals>();

  final String teamleaderId = StaticStoredData.userId;
  final CommonFilterController filterController =
      Get.find<CommonFilterController>();
  RxString searchText = ''.obs;

  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();
    getteamLeaderData();
    getDisbursementData(); // initial load (All)

    ever(filterController.selectedRange, (_) {
      getDisbursementData();
    });

    searchController.addListener(_onSearchChanged);

    _searchWorker = debounce(
      searchText,
      (value) async {
        if (isLoading.value) return;

        await getDisbursementData(
          query: value.trim(),
        );
      },
      time: const Duration(milliseconds: 600),
    );
  }

  void _onSearchChanged() {
    searchText.value = searchController.text;
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    _searchWorker.dispose();
    clearFilters();
    super.onClose();
  }

  // ---------------- TEAM LEADERS ----------------
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

  Future<void> getDisbursementData({
    String? query,
  }) async {
    if (iscallDisbursedLoading.value) return;

    iscallDisbursedLoading.value = true;

    final Map<String, dynamic> formData = {
      'teamleader_id': StaticStoredData.userId
    };

    final range = filterController.selectedRange.value;

    if (query != null && query.trim().isNotEmpty) {
      formData['search'] = query.trim();
    }

    if (range != null) {
      formData['daterange'] = "${DateFormat('dd-MM-yyyy').format(range.start)},"
          "${DateFormat('dd-MM-yyyy').format(range.end)}";
    }

    try {
      final response = await _apiService.postRequest(
          APIUrls.getDisbursementForAdmin, formData);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final model = DisbursementModel.fromJson(json);

        // Store original list
        allDisbursementList.assignAll(model.data);
        disbursementList.assignAll(allDisbursementList);
      }
    } catch (e) {
      debugPrint('❌ Disbursement error: $e');
    } finally {
      iscallDisbursedLoading.value = false;
    }
  }

  void applyFilters({String? query, String? teamleaderId}) {
    List<DisbursementData> filtered = allDisbursementList;

    if (teamleaderId != null && teamleaderId.isNotEmpty) {
      filtered =
          filtered.where((item) => item.teamleaderId == teamleaderId).toList();
    }

    if (query != null && query.isNotEmpty) {
      filtered = filtered
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    disbursementList.assignAll(filtered);
  }

  // Future<void> getDisbursementData(
  //     {String? query, String? teamleaderId}) async {
  //   iscallDisbursedLoading.value = true;

  //   try {
  //     // Fetch only once

  //     final response =
  //         await _apiService.postRequest(APIUrls.getDisbursementForAdmin, {});

  //     if (response.statusCode == 200) {
  //       final json = jsonDecode(response.body);
  //       final model = DisbursementModel.fromJson(json);
  //       disbursementList.assignAll(model.data);
  //     }

  //     if (teamleaderId != null && teamleaderId.isNotEmpty) {
  //       final filtered = allDisbursementList
  //           .where((item) => item.teamleaderId == teamleaderId)
  //           .toList();

  //       disbursementList.assignAll(filtered);
  //     }

  //     // SEARCH FILTER
  //     if (query != null && query.isNotEmpty) {
  //       final filtered = allDisbursementList.where((item) {
  //         final name = item.name.toLowerCase();

  //         return name.contains(query.toLowerCase());
  //       }).toList();

  //       disbursementList.assignAll(filtered);
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Disbursement error: $e');
  //   } finally {
  //     iscallDisbursedLoading.value = false;
  //   }
  // }

  // ---------------- FILTER ----------------
  void selectFilter(int index) async {
    selectedFilter.value = index;
    String? teamleader = getSelectedTeamLeaderId();
    applyFilters(teamleaderId: teamleader);
    // await getDisbursementData(teamleaderId: teamleader);
  }

  void clearFilters() {
    selectedFilter.value = 0;
    searchController.clear();
    filterController.clearDateFilter();
    getDisbursementData();
  }

  String? getSelectedTeamLeaderId() {
    if (selectedFilter.value == 0) return null; // "All" selected

    if (selectedFilter.value < filters.length) {
      final selectedName = filters[selectedFilter.value];
      final tl = teamleaderList.firstWhereOrNull((e) => e.name == selectedName);
      return tl?.id;
    }
    return null;
  }
}
