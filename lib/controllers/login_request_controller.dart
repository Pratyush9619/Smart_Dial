import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/models/loan_status_model.dart';
import 'package:smart_solutions/models/login_request_bank_list_model';
import 'package:smart_solutions/models/login_request_list_model.dart'; // Ensure this model is defined
import 'package:smart_solutions/models/remark_list.dart';
import 'package:smart_solutions/models/source_model.dart';
import 'package:smart_solutions/services/api_service.dart';
import '../constants/services.dart';
import '../models/status_list_model.dart';

class LoginRequestController extends GetxController {
  var allLoginRequestList = <LoginRequest>[].obs;
  var loginRequestList = <LoginRequest>[].obs;
  var loanStatusList = <LoanStatus>[].obs;
  List<RemarkList> remarks = [];
  var isLoading = false.obs;
  RxBool isSubmitting = false.obs;
  RxBool isBankLoading = false.obs;
  RxBool isSourcingLoading = false.obs;
  var iseditLoading = false.obs;
  var currentId = ''.obs;
  var isEdit = false.obs;
  var isNew = false.obs;

  var loginRequestDate = DateTime.now().obs;
  var telecallerId = StaticStoredData.userId.obs;
  var customerName = ''.obs;
  var contactNumber = ''.obs;
  var loanStatus = '1'.obs; // Default loan status
  var bankId = ''.obs;
  var sendingBankId = ''.obs;
  var loanAmount = ''.obs;
  var commonRemark = ''.obs;
  var remarksList = <String>[].obs;
//  var id = ''.obs; // For existing records

  var allBankNamesList = <LoginRequestBankList>[].obs;

  var sourcingList = <SourceModel>[].obs;
  var sourceId = ''.obs;

  final searchController = TextEditingController();
  var selectedFilter = 0.obs;
  var filters = <String>[].obs;
  RxList<dynamic> todayCount = <dynamic>[].obs;
  RxList<dynamic> monthlyCount = <dynamic>[].obs;

  var selectedLoanStatus = ''.obs;
  var selectedStatus = ''.obs;
  var statuslist = <statusData>[].obs;
  var selectedStatusName = ''.obs;

  final CommonFilterController filterController =
      Get.find<CommonFilterController>();
  @override
  void onInit() async {
    super.onInit();
    ever(allLoginRequestList, (_) => updateFilteredList());
    ever(selectedFilter, (_) => filterLoginRequests());

    await getLoginRequestList();
    await editLoadData();
    // fetchLoanStatuses();
    // getLoginRequestBanks();
    // getSourcingList();
  }

  Future<void> editLoadData() async {
    try {
      iseditLoading(true);
      await Future.wait([
        fetchLoanStatuses(),
        getLoginRequestBanks(),
        getSourcingList(),
      ]);
    } catch (e) {
      logOutput("Error loading data: $e");
    } finally {
      iseditLoading(false); // 👈 stop loading in all cases
    }
  }

  // Fetch the login request list
  Future<void> getLoginRequestList() async {
    try {
      isLoading(true);
      var body = {'telecaller_id': StaticStoredData.userId};

      final response =
          await ApiService().postRequest(APIUrls.loginRequestList, body);

      if (response.statusCode == 200) {
        var resData = jsonDecode(response.body);
        if (resData['data'] is List) {
          final List list = resData['data'];

          final loginData = list.map((e) => LoginRequest.fromJson(e)).toList();
          allLoginRequestList.assignAll(loginData);
          loginRequestList.assignAll(loginData);

          final today = DateTime.now();

          monthlyCount.value = loginData
              .where((e) =>
                  e.loginRequestDate != null && // ✅ NULL CHECK
                  e.loginRequestDate.year == today.year &&
                  e.loginRequestDate.month == today.month)
              .map((e) => e.telecallerId ?? '') // ✅ SAFE
              .toList();

          todayCount.value = loginData
              .where((e) =>
                  e.loginRequestDate != null && // ✅ NULL CHECK
                  e.loginRequestDate.year == today.year &&
                  e.loginRequestDate.month == today.month &&
                  e.loginRequestDate.day == today.day)
              .map((e) => e.telecallerId ?? '') // ✅ SAFE
              .toList();

          if (currentId.value.isNotEmpty) {
            await getRemarks();
          }

          isLoading(false);
        }
        // if (resData['data'] != null && resData['data'] is List) {
        //   var loginData = (resData['data'] as List)
        //       .map((json) => LoginRequest.fromJson(json))
        //       .toList();

        //   // log('raw -->>> ${resData['data'] }');
        //   allLoginRequestList.value = loginData; // store original
        //   loginRequestList.value = loginData;

        //   monthlyCount.value = allLoginRequestList
        //       .where((e) => e.loginRequestDate.month == today.month)
        //       .map((e) => e.telecallerId)
        //       .toList();

        //   todayCount.value = allLoginRequestList
        //       .where((e) =>
        //           // e.loginRequestDate.year == today.year &&
        //           e.loginRequestDate.day == today.day)
        //       //&&
        //       //e.loginRequestDate.day == today.day)
        //       .map((e) => e.telecallerId)
        //       .toList();

        //   await getRemarks();
        //   isLoading(false);
        // }
        else {
          logOutput("No data found");
          isLoading(false);
        }
      } else if (response.statusCode == 204) {
        loginRequestList.clear();
      } else {
        isLoading(false);
        logOutput("Error: ${response.statusCode}");
      }
      isLoading(false);
    } catch (e) {
      isLoading(false);
      logOutput("An error occurred while fetching the login request list: $e");
    }
  }

  // Fetch loan statuses
  Future<void> fetchLoanStatuses() async {
    try {
      isLoading.value = true; // Start loading
      final response = await ApiService().getRequest(APIUrls.getLoanStatus);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        logOutput('Response data: $responseData'); // Log response

        // Update loanStatusList with parsed data
        loanStatusList.value = (responseData['data'] as List)
            .map((item) => LoanStatus.fromJson(item))
            .toList();
      } else {
        logOutput(
            "Failed to fetch loan status. Status code: ${response.statusCode}");
      }
    } catch (e) {
      logOutput("An error occurred while fetching loan statuses: $e");
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  Future<void> getRemarks() async {
    var body = {'login_request_id': currentId.value};
    var response = await ApiService().postRequest(APIUrls.getRemarkList, body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body); // Decode JSON

      // Check if 'data' is present in the response
      if (data['data'] != null) {
        // Map each JSON object to RemarkList and store in the list
        remarks = (data['data'] as List)
            .map((remarkJson) => RemarkList.fromJson(remarkJson))
            .toList();
        remarksList.value = remarks.map((remark) => remark.remark).toList();
      }
    }
  }

  // Save login request
  Future<bool> saveLoginRequest() async {
    isSubmitting.value = true;

    try {
      // Prepare the fields map
      var fields = {
        'login_request_date': DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(loginRequestDate.value.toString())),
        'loan_status': selectedLoanStatus.value,
        'telecaller_id': telecallerId.value.toString(),
        'customer_name': customerName.value.toString(),
        'contact_number': contactNumber.value.toString(),
        'bank_id': sendingBankId.value.toString(),
        'loan_amount': loanAmount.value.replaceAll(",", ""),
        'common_remark': commonRemark.value.toString(),
        'id': currentId.value.toString(),
        'data_sourcing': sourceId.value.toString(),
      };

      // Add each remark separately to the fields map
      if (remarksList.isNotEmpty) {
        for (int i = 0; i < remarksList.length; i++) {
          fields['remarks[$i]'] = remarksList[i];
        }
      }

      // logOutput fields to verify the data
      logOutput('Request fields: $fields');

      // Make the API request
      final response = await ApiService().multipartPostRequest(
        APIUrls.loginRequestSave,
        fields,
        null, // No file handling needed
        null, // Empty field name for file (not used)
      );

      // Handle the response
      if (response.statusCode == 200) {
        Get.back(); // Close the form
        await getLoginRequestList();
        currentId.value = '';

        loginRequestDate = DateTime.now().obs;
        telecallerId.value = '';
        customerName.value = '';
        contactNumber.value = '';
        selectedLoanStatus.value = ''; // Default loan status
        bankId.value = '';
        sendingBankId.value = '';
        loanAmount.value = '';
        commonRemark.value = '';
        remarksList.value = []; // To hold multiple remarks
        //    id = ''.obs;
        sourceId.value = '';

        return true;
      } else {
        Get.snackbar('Error', 'Failed to save login request.');
        return false;
      }
    } catch (e) {
      logOutput("An error occurred while saving the login request: $e");
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> getLoginRequestBanks() async {
    try {
      isLoading(true);
      var body = {
        "telecaller_id": StaticStoredData.userId
      }; // You can define your request body as needed
      var response = await ApiService()
          .postRequest(APIUrls.allLoginRequestBankNames, body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<LoginRequestBankList> bankList = parseBankList(responseData);
        if (bankList.isNotEmpty) {
          allBankNamesList.assignAll(bankList);
        }
      }
      isLoading(false);
    } catch (e) {
      log('An error occurred while fetching banks: $e');
      isLoading(false); // Ensure loading is set to false on error as well
    }
  }

  Future<void> getSourcingList() async {
    try {
      isLoading(true);
      var body = {
        "telecaller_id": StaticStoredData.userId
      }; // You can define your request body as needed
      var response = await ApiService().postRequest(APIUrls.sourcingList, body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<SourceModel> sourceList =
            responseData.map((e) => SourceModel.fromJson(e)).toList();
        if (sourceList.isNotEmpty) {
          sourcingList.assignAll(sourceList);
        }
      }
      isLoading(false);
    } catch (e) {
      log('An error occurred while fetching source list: $e');
      isLoading(false); // Ensure loading is set to false on error as well
    }
  }

  Future<void> getStatusData() async {
    try {
      Map<String, dynamic> data = {};
      var response = await ApiService().postRequest(APIUrls.statuslist, data);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<statusData> data =
            responseData.map((e) => statusData.fromJson(e)).toList();
        if (data.isNotEmpty) {
          statuslist.assignAll(data);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
    }
  }

  @override
  void onClose() {
    filterController.clearFilters();
    super.onClose();
  }
//filter
  // void filterLoginRequests({String query = ''}) {
  //   if (query.isNotEmpty) {
  //     loginRequestList.value = allLoginRequestList;
  //     return;
  //   }

  //   query = filters[selectedFilter.value].toLowerCase();

  //   loginRequestList.value = allLoginRequestList.where((item) {
  //     return item.customerName.toLowerCase().contains(query) ||
  //         item.contactNumber.toLowerCase().contains(query);
  //   }).toList();
  // }

  // void filterLoginRequests() {
  //   final search = searchController.text.trim().toLowerCase();

  //   // selected chip text
  //   final selectedIndex = selectedFilter.value;
  //   final hasChipSelected = selectedIndex != 0;
  //   final chipText =
  //       hasChipSelected ? filters[selectedIndex].toLowerCase() : '';

  //   loginRequestList.value = allLoginRequestList.where((item) {
  //     final name = item.customerName.toLowerCase();
  //     final mobile = item.contactNumber.toLowerCase();
  //     final title = (item.title ?? '').toLowerCase();

  //     // 🔍 Search check
  //     final searchMatch = search.isEmpty ||
  //         name.contains(search) ||
  //         mobile.contains(search) ||
  //         title.contains(search);

  //     // 🟦 Chip check
  //     final chipMatch = !hasChipSelected || title == chipText;

  //     return searchMatch && chipMatch;
  //   }).toList();
  // }

  void filterLoginRequests() {
    final search = searchController.text.trim().toLowerCase();

    final selectedIndex = selectedFilter.value;
    final hasChipSelected = selectedIndex != 0;
    final chipText =
        hasChipSelected ? filters[selectedIndex].toLowerCase() : '';

    loginRequestList.value = allLoginRequestList.where((item) {
      final name = item.customerName.toLowerCase();
      final mobile = item.contactNumber.toLowerCase();
      final title = (item.title ?? '').toLowerCase();

      /// 🔍 Search check
      final searchMatch = search.isEmpty ||
          name.contains(search) ||
          mobile.contains(search) ||
          title.contains(search);

      /// 🟦 Chip check
      final chipMatch = !hasChipSelected || title == chipText;

      /// 📅 Date range check
      bool dateMatch = true;

      // if (isDateSelected && item.loginRequestDate != null) {
      //   try {
      //     final itemDate = DateTime.parse(item.loginRequestDate.toString());

      //     final normalizedItem =
      //         DateTime(itemDate.year, itemDate.month, itemDate.day);
      //     final normalizedFrom =
      //         DateTime(fromDate.year, fromDate.month, fromDate.day);
      //     final normalizedTo = DateTime(toDate.year, toDate.month, toDate.day);

      //     dateMatch = !normalizedItem.isBefore(normalizedFrom) &&
      //         !normalizedItem.isAfter(normalizedTo);
      //   } catch (_) {
      //     dateMatch = false;
      //   }
      // }

      return searchMatch && chipMatch && dateMatch;
    }).toList();
  }

  void selectFilter(int index) {
    selectedFilter.value = index;
  }

  void clearFilters() {
    selectedFilter.value = 0;
    searchController.clear();
  }

  void setFilters(List<String> names) {
    filters.value = ["All", ...names.toSet()];
    update();
  }

  void updateFilteredList({String query = ''}) {
    final names =
        allLoginRequestList.map((item) => item.title ?? 'Unknown').toList();

    setFilters(names);
  }
}
