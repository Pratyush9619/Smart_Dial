import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/controllers/remark_status_controller.dart';
import 'package:smart_solutions/models/FollowUpSubmittedList.dart';
import 'package:smart_solutions/models/callBack_model.dart';
import 'package:smart_solutions/models/call_log_model.dart';
import 'package:smart_solutions/models/disbursement_model.dart';
import 'package:smart_solutions/models/team_leader_model.dart';
import 'package:smart_solutions/utils/scroll_utils.dart';
import '../constants/services.dart';
import '../models/login_request_bank_list_model';
import '../services/api_service.dart';
import '../constants/api_urls.dart';

import 'dailer_controller.dart';

class FollowBackFormController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final DialerController _dialerController = Get.put(DialerController());

  var allBankNamesList = <LoginRequestBankList>[].obs;
  var followBackList = <Data>[].obs;

  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();

  var monthlybackData = <Data>[].obs;
  var dailycallbackData = <Data>[].obs;
  var callLogData = <Datum>[].obs;

  var callBackData = <CallBackData>[].obs;
  var allCallBackData = <CallBackData>[].obs;
  var callBackTotalData = <Totals>[].obs;

  var dailyfollowBackList = <Data>[].obs;
  var monthlyfollowBackList = <Data>[].obs;
  var filteredFollowBackList = <Data>[].obs;

  var filterCallBackData = [].obs;

  var disbursementList = <DisbursementData>[].obs;
  var disbursementTotal = <disbursementTotals>[].obs;

  var teamleaderList = <TeamleaderData>[].obs;
  var tellecallerList = <TeamleaderData>[].obs;

  RxString selectedTeamLeaders = ''.obs;
  late RxList selectedtellecaller = [].obs;
  late RxList selectedtellecallerName = [].obs;
  var allCustomerName = <Data>[].obs;
  var dateRangeList = <DateTime?>[].obs;
  // late TabController callController;
  var selectedIndex = 0.obs;

  //dialog var
  var selectedTeamLeaderId = ''.obs;

// search variables
  var showSearchField = false.obs;
  var searchText = "".obs;
  var searchCallBackText = "".obs;
  double itemHeight = 45.h;
  double tellececalleritemHeight = 55.h;
  final customerNumberController = TextEditingController();
  final customerNameController = TextEditingController();

  // Pagination variables
  RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int limit = 20;

// scroll chiplist
  final ScrollController filterScrollController = ScrollController();

  final RxBool isInitialLoading = true.obs;
  final RxBool isCallBackLoading = true.obs;
  final RxBool isMoreLoading = true.obs;

  final TextEditingController searchController = TextEditingController();

  final CommonFilterController filterController =
      Get.find<CommonFilterController>();

  Worker? _worker;

  @override
  void onInit() async {
    getCallBackData();
    // _startWorker();
    //   ever(followBackList, (_) => updateFilteredList());
    ever(selectedFilter, (_) => filtercallBack());

    ever(followBackList, (_) => updateFilteredList());

    ever(filterController.isDateRangeSelected, (_) => fetchFollowBackList());

    // await fetchFollowBackList();
    customerNumberController.addListener(() {
      mobile.value = customerNumberController.text;
    });

    ever<String>(mobile, (number) {
      if (customerNumberController.text != number) {
        customerNumberController.text = number;
        customerNumberController.selection = TextSelection.fromPosition(
          TextPosition(offset: number.length),
        );
      }
    });

    // debounce(
    //   searchText,
    //   (_) {
    //     currentPage.value = 1;
    //     followBackList.clear();
    //     filtercallBack(searchQuery: searchText.value);
    //   },
    //   time: const Duration(milliseconds: 500),
    // );

    // callController = TabController(length: 4, vsync: this);
    // callController.addListener(() {
    //   if (!callController.indexIsChanging) {
    //     selectedIndex.value = callController.index;
    //   }
    //  });

    //  loadData();

    super.onInit();
  }

  void resetDurationState() {
    isDurationAvailable.value = true;
    contacted.value = 'No';
  }

  void startWorker() {
    _worker = ever(filterController.selectedRange, (_) {
      fetchFollowBackList();
    });
  }

  void stopWorker() {
    _worker?.dispose();
    _worker = null;
  }

  void restartWorker() {
    stopWorker();
    startWorker();
  }

  @override
  void onClose() {
    stopWorker();
    super.onClose();

    searchController.dispose();
    customerNumberController.dispose(); // Use dispose, not clear

    filterScrollController.dispose();
  }

  // void _handleDateChange() {
  //   final from = filterController.fromDate.value;
  //   final to = filterController.toDate.value;

  //   if (from != null && to != null) {
  //     fetchFollowBackList();
  //   } else if (from == null && to == null) {
  //     // Date cleared → reload full list
  //     fetchFollowBackList();
  //   }
  // }

  Future<void> loadData(bool isRefresh) async {
    isBankAndStatusLoading(true);
    try {
      if (isRefresh) {
        // Save current form values BEFORE refresh
        final savedCustomerName = _dialerController.customerName.value;
        final savedMobile = mobile.value;
        final savedSalary = _dialerController.salary.value;
        final savedLoanAmount = _dialerController.customerLoan.value;
        final savedBankName = bankName.value;
        final savedDataType = dataType.value; // ✅ Save dataType
        final savedContacted = contacted.value;
        final savedRemark = remark.value;
        final savedRemarkStatus = remarkStatus.value;

        // Reload essential data
        await getAllBanks();
        await getDisbursementData();

        // RESTORE form values AFTER refresh
        _dialerController.customerName.value = savedCustomerName;
        mobile.value = savedMobile;
        _dialerController.salary.value = savedSalary;
        _dialerController.customerLoan.value = savedLoanAmount;
        bankName.value = savedBankName;
        dataType.value = savedDataType; // ✅ Restore dataType
        contacted.value = savedContacted;
        remark.value = savedRemark;
        remarkStatus.value = savedRemarkStatus;

        // Also update controllers if needed
        if (savedCustomerName.isNotEmpty) {
          _dialerController.customerNameController.text = savedCustomerName;
        }
        if (savedMobile.isNotEmpty) {
          customerNumberController.text = savedMobile;
        }
      } else {
        // For initial load (not refresh)
        await getAllBanks();
        await getDisbursementData();
      }
    } catch (e) {
      print("Error while loading data: $e");
    } finally {
      isBankAndStatusLoading(false);
    }
  }

  void toggleSearch() {
    showSearchField.value = !showSearchField.value;
  }

  var selectedStatuses = <String>[].obs;

  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
  }

  Future<void> applyStatusFilter() async {
    try {
      isLoading(true);
      followBackList.clear();
      await fetchFollowBackList();
    } finally {
      isLoading(false);
    }
  }

  //search controller

  var filters = <String>[].obs;
  var selectedFilter = 0.obs;

  // Form fields
  var loanAmount = ''.obs;
  var customerName = ''.obs;
  var mobile = ''.obs;
  var bankName = ''.obs;
  var dataType = ''.obs;
  var contacted = 'No'.obs;
  final RxBool isDurationAvailable = true.obs;

  var remarkStatus = ''.obs;
  var remark = ''.obs;
  var telecallerId = StaticStoredData.userId.obs;

  // var followupDate = DateTime.now().obs;
  // Change followupDate to accept null
  var followupDate = Rx<DateTime?>(null);
  // var fromDate = Rx<DateTime?>(null);
  // var toDate = Rx<DateTime?>(null);

  // final fromDateController = TextEditingController(text: "");
  // final toDateController = TextEditingController(text: "");

  var isLoading = false.obs;
  var isFormSubmitted = false.obs;
  var isBankAndStatusLoading = false.obs;
  var iscallBackLoading = false.obs;
  var iscallLogLoading = false.obs;
  var iscallDisbursedLoading = false.obs;

  var isdailyCallLoading = false.obs;
  var isMonthlyCallLoading = false.obs;

  // Convert contacted status to API format
  String get contactStatus => contacted.value == 'Yes' ? '1' : '2';

  void clearDateRange() {
    dateRangeList.clear();
    selectedStatuses.clear();
  }

  Future<void> fetchFollowBackList({bool loadMore = false}) async {
    if (loadMore) {
      isMoreLoading.value = true;
    } else {
      isInitialLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
      followBackList.clear();
      allCustomerName.clear();
    }

    final Map<String, dynamic> formData = {
      "telecaller_id": StaticStoredData.userId,
      // "daterange": dateRage,
      // "page": currentPage.value.toString(),
      // "secure_type": secureType.toString(),
    };

    final range = filterController.selectedRange.value;

    if (range != null) {
      formData['daterange'] = "${DateFormat('dd-MM-yyyy').format(range.start)},"
          "${DateFormat('dd-MM-yyyy').format(range.end)}";
    }

    if (searchText.value.isNotEmpty) {
      formData['search'] = searchText.value.trim();
    }

    if (selectedStatuses.isNotEmpty) {
      for (var i = 0; i < selectedStatuses.length; i++) {
        formData["status[$i]"] = selectedStatuses[i];
      }
    }

    try {
      var response =
          await _apiService.postRequest(APIUrls.updatedcalllog, formData);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var model = FollowUpSubmitedList.fromJson(data);
        var newItems = model.data ?? [];

        if (loadMore) {
          followBackList.addAll(newItems);
        } else {
          followBackList.assignAll(newItems);
        }

        Map<String, Data> uniqueMap = {};

        for (var item in followBackList) {
          if (item.contactNumber != null) {
            uniqueMap[item.contactNumber!] = item;
          }
        }

        allCustomerName.assignAll(uniqueMap.values.toList());

        hasMore.value = newItems.length >= limit;
        if (newItems.isNotEmpty) currentPage++;
      } else {
        hasMore.value = false;
      }
    } catch (_) {
      hasMore.value = false;
    }

    isInitialLoading.value = false;
    isMoreLoading.value = false;
  }

  // Method to load more data

  Future<void> getDailyMonthlyCallbackData(String dateRange) async {
    // isLoading.value = true;
    isdailyCallLoading.value = true;
    isMonthlyCallLoading.value = true;

    try {
      // final String dateRage = dateRangeList.isNotEmpty &&
      //         dateRangeList.first != null &&
      //         dateRangeList.last != null
      //     ? "${dateRangeList.first},${dateRangeList.last}"
      //     : "";

      bool hasValidTelecaller = false;
      final formdata = {"daterange": dateRange};

      //Add telecaller IDs dynamically if the list is not empty
      if (selectedtellecaller.isNotEmpty) {
        for (var i = 0; i < selectedtellecaller.length; i++) {
          final telecallerId = selectedtellecaller[i];

          formdata["telecaller_ids[$i]"] = telecallerId;
          hasValidTelecaller = true;
        }
      }

      // If no valid telecaller IDs were added, fallback to current user
      if (!hasValidTelecaller) {
        formdata['telecaller_id'] = StaticStoredData.userId;
      }

      final response =
          await _apiService.postRequest(APIUrls.callBackdData, formdata);

      debugPrint(
          "FollowUp callback Response => ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final followBackData = FollowUpSubmitedList.fromJson(responseData);

        // Assign to observable list
        if (dateRange == "1") {
          dailycallbackData.assignAll(followBackData.data ?? []);
        } else {
          monthlybackData.assignAll(followBackData.data ?? []);
        }
      } else if (response.statusCode == 204) {
        monthlybackData.clear(); // No data
      } else {
        logOutput("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      logOutput("Exception while fetching follow-back list: $e");
    } finally {
      isdailyCallLoading.value = false;
      isMonthlyCallLoading.value = false;
    }
  }

  Future<void> getCallBackData() async {
    iscallBackLoading.value = true;

    final String dateRage = dateRangeList.isNotEmpty &&
            dateRangeList.first != null &&
            dateRangeList.last != null
        ? "${dateRangeList.first},${dateRangeList.last}"
        : "";

    bool hasValidTelecaller = false;
    final formdata = {
      "daterange": dateRage,
    };

    //Add telecaller IDs dynamically if the list is not empty
    if (selectedtellecaller.isNotEmpty) {
      for (var i = 0; i < selectedtellecaller.length; i++) {
        final telecallerId = selectedtellecaller[i];

        formdata["telecaller_ids[$i]"] = telecallerId;
        hasValidTelecaller = true;
      }
    }

    // If no valid telecaller IDs were added, fallback to current user
    if (!hasValidTelecaller) {
      formdata['telecaller_id'] = StaticStoredData.userId;
    }

    try {
      final response =
          await _apiService.postRequest(APIUrls.callBacklist, formdata);

      debugPrint(
          "callback Response => ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = CallBackModel.fromJson(responseData);
        final totaldata = Totals.fromJson(responseData['totals']);

        callBackData.assignAll(data.data);
        allCallBackData.assignAll(data.data);
        callBackTotalData.assign(totaldata);
      } else if (response.statusCode == 204) {
        monthlybackData.clear(); // No data
      } else {
        logOutput("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      logOutput("Exception while fetching follow-back list: $e");
    } finally {
      iscallBackLoading.value = false;
    }
  }

  // void applyLocalFilter() {
  //   // If nothing selected → show all data
  //   if (selectedtellecaller.isEmpty) {
  //     callBackData.assignAll(allCallBackData);
  //     return;
  //   }

  //   final filteredList = allCallBackData.where((item) {
  //     return selectedtellecaller.contains(item.id);
  //   }).toList();

  //   callBackData.assignAll(filteredList);
  // }
  Future<void> getCallLogData() async {
    iscallLogLoading.value = true;

    final String dateRage = dateRangeList.isNotEmpty &&
            dateRangeList.first != null &&
            dateRangeList.last != null
        ? "${dateRangeList.first},${dateRangeList.last}"
        : "";

    bool hasValidTelecaller = false;
    final formdata = {
      "daterange": dateRage,
    };

    //Add telecaller IDs dynamically if the list is not empty
    if (selectedtellecaller.isNotEmpty) {
      for (var i = 0; i < selectedtellecaller.length; i++) {
        final telecallerId = selectedtellecaller[i];

        formdata["telecaller_ids[$i]"] = telecallerId;
        hasValidTelecaller = true;
      }
    }

    // If no valid telecaller IDs were added, fallback to current user
    if (!hasValidTelecaller) {
      formdata['telecaller_id'] = StaticStoredData.userId;
    }
    try {
      final response =
          await _apiService.postRequest(APIUrls.callLoglist, formdata);

      debugPrint(
          "FollowUp calllog Response => ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        print(response.body);
        final responseData = jsonDecode(response.body);
        final followBackData = CallLogModel.fromJson(responseData);

        callLogData.assignAll(followBackData.data);
      } else if (response.statusCode == 204) {
        monthlybackData.clear(); // No data
      } else {
        logOutput("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      logOutput("Exception while fetching follow-back list: $e");
    } finally {
      iscallLogLoading.value = false;
    }
  }

  Future<void> getDisbursementData() async {
    iscallDisbursedLoading.value = true;
    final String dateRage = dateRangeList.isNotEmpty &&
            dateRangeList.first != null &&
            dateRangeList.last != null
        ? "${dateRangeList.first},${dateRangeList.last}"
        : "";

    bool hasValidTelecaller = false;
    final formdata = {
      "daterange": dateRage,
    };

    //Add telecaller IDs dynamically if the list is not empty
    if (selectedtellecaller.isNotEmpty) {
      for (var i = 0; i < selectedtellecaller.length; i++) {
        final telecallerId = selectedtellecaller[i];

        formdata["telecaller_ids[$i]"] = telecallerId;
        hasValidTelecaller = true;
      }
    }

    // If no valid telecaller IDs were added, fallback to current user
    if (!hasValidTelecaller) {
      formdata['telecaller_id'] = StaticStoredData.userId;
    }

    try {
      final response =
          await _apiService.postRequest(APIUrls.disbursmentlist, formdata);

      debugPrint(
          "FollowUp callback Response => ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final disbursement = DisbursementModel.fromJson(responseData);
        final total = disbursementTotals.fromJson(responseData['totals']);

        disbursementList.assignAll(disbursement.data);
        disbursementTotal.assign(total);
      } else {
        logOutput("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      logOutput("Exception while fetching follow-back list: $e");
    } finally {
      iscallDisbursedLoading.value = false;
    }
  }

  String? getSelectedTeamLeaderId() {
    if (selectedFilter.value == 0) return null; // "All" selected

    if (selectedFilter.value < filters.length) {
      final selectedName = filters[selectedFilter.value];
      final tl =
          tellecallerList.firstWhereOrNull((e) => e.name == selectedName);
      return tl?.id;
    }
    return null;
  }

  Future<void> getteamLeaderData([String? teamleaderId]) async {
    isLoading.value = true;

    try {
      final response = await _apiService.postRequest(
        APIUrls.teamleaderlist,
        {
          "teamleader_id": teamleaderId ?? '',
        },
      );

      debugPrint(
          "FollowUp callback Response => ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final teamleader = TealLeaderModel.fromJson(responseData);

        if (teamleader != null) {
          tellecallerList.assignAll(teamleader.data);
          setFilters(
            tellecallerList.map((e) => e.name).toList(),
          );
        }
      } else {
        logOutput("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      logOutput("Exception while fetching follow-back list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> submitFollowUp() async {
  //   try {
  //     isFormSubmitted(true);

  //     final Map<String, dynamic> formData = {
  //       'mobile': mobile.value,
  //       'name': _dialerController.customerName.value,
  //       'data_type': dataType.value,
  //       'bank_name':
  //           bankName.value.isEmpty ? allBankNamesList.first.id : bankName.value,
  //       // 'followup_date':
  //       //     '${followupDate.value.year}-${followupDate.value.month}-${followupDate.value.day}',

  //       'followup_date': followupDate.value != null
  //           ? '${followupDate.value!.year}-${followupDate.value!.month}-${followupDate.value!.day}'
  //           : '-',

  //       'contact_status': contactStatus,
  //       'remark_status': remarkStatus.value,
  //       'remark': remark.value,
  //       'telecaller_id': telecallerId.value,
  //       'call_duration': _dialerController
  //           .formatElapsedTime(_dialerController.elapsedTimeInSeconds.value),
  //       'salary': _dialerController.salary.value,
  //       'loan_amount': _dialerController.customerLoan.value,
  //       'data_sourcing': dataType.value,
  //       'excel_id': _dialerController.excel_id.value,
  //       'followup_id': _dialerController.followup_id.value,
  //     };
  //     logOutput("$formData");
  //     final response =
  //         await _apiService.postRequest(APIUrls.followListData, formData);

  //     _dialerController.elapsedTimeInSeconds.value = 0;
  //     logOutput(response.body);
  //     if (response.statusCode == 200) {
  //       // fetchFollowBackList()
  //       clearForm();

  //       Future.delayed(const Duration(milliseconds: 200), () {
  //         final context = Get.overlayContext;

  //         if (context != null) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: const Text("Follow up saved successfully"),
  //               backgroundColor: Colors.green.shade400,
  //             ),
  //           );

  //           /// ⭐ Close overlay if any
  //           if (Get.isOverlaysOpen) {
  //             Get.back();
  //           }

  //           /// ⭐ Then close screen
  //           if (Get.key.currentState!.canPop()) {
  //             Get.back();
  //           }
  //         }
  //       });
  //     }

  //     return true;
  //   } catch (e) {
  //     logOutput('Error submitting form: $e');
  //     return false;
  //     //  Get.snackbar('Error', 'Failed to submit follow up form');
  //   } finally {
  //     isFormSubmitted(false);
  //   }
  // }

  Future<bool> submitFollowUp() async {
    try {
      isFormSubmitted(true);

      final Map<String, dynamic> formData = {
        'mobile': mobile.value,
        'name': _dialerController.customerNameController.text.trim(),
        'data_type': dataType.value,
        'bank_name':
            bankName.value.isEmpty ? allBankNamesList.first.id : bankName.value,
        'followup_date': followupDate.value != null
            ? '${followupDate.value!.year}-${followupDate.value!.month}-${followupDate.value!.day}'
            : '-',
        'contact_status': contactStatus,
        'remark_status': remarkStatus.value,
        'remark': remark.value,
        'telecaller_id': telecallerId.value,
        'call_duration': _dialerController
            .formatElapsedTime(_dialerController.elapsedTimeInSeconds.value),
        'salary': _dialerController.salary.value,
        'loan_amount': _dialerController.customerLoan.value,
        'data_sourcing': dataType.value,
        'excel_id': _dialerController.excel_id.value,
        'followup_id': _dialerController.followup_id.value,
      };

      final response =
          await _apiService.postRequest(APIUrls.followListData, formData);

      _dialerController.elapsedTimeInSeconds.value = 0;

      if (response.statusCode == 200) {
        clearForm();
        return true; // ✅ SUCCESS
      }

      return false;
    } catch (e) {
      logOutput('Error submitting form: $e');
      return false;
    } finally {
      isFormSubmitted(false);
    }
  }

  // void updateFilteredFollowBackList(String query) {
  //   if (query.isEmpty) {
  //     filteredFollowBackList.assignAll(followBackList);
  //   } else {
  //     filteredFollowBackList.assignAll(
  //       followBackList.where((item) {
  //         final name = item.customerName?.toLowerCase() ?? '';

  //         final mobile = item.contactNumber?.toLowerCase() ?? '';
  //         final bank = item.bankName?.toLowerCase() ?? '';
  //         final searchQuery = query.toLowerCase();
  //         return name.contains(searchQuery) ||
  //             mobile.contains(searchQuery) ||
  //             bank.contains(searchQuery);
  //       }).toList(),
  //     );
  //   }
  // }

  // Future<void> getAllBanks() async {
  //   try {
  //     var body = {'': ''};
  //     var response = await ApiService().postRequest(APIUrls.allBankNames, body);

  //     if (response.statusCode == 200) {
  //       final remarkStatus = AllBankNames.fromJson(json.decode(response.body));
  //       if (remarkStatus.data != null) {
  //         allBankNamesList.assignAll(remarkStatus.data!);
  //       }
  //     }
  //   } catch (e) {
  //     log('an error occured while fetching banks $e');
  //   } finally {}
  // }

  Future<void> getAllBanks() async {
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

  // void clearForm() {
  //   // This should only be called on successful form submit
  //   customerName.value = '';
  //   mobile.value = '';
  //   bankName.value = '';
  //   dataType.value = '';
  //   contacted.value = 'No';
  //   remarkStatus.value = '';
  //   remark.value = '';
  //   followupDate.value = null;

  //   customerNumberController.clear();

  //   // Clear dialer data
  //   _dialerController.customerNameController.text = '';
  //   _dialerController.datatype.value = '';
  //   _dialerController.elapsedTimeInSeconds.value = 0;
  //   _dialerController.followup_id.value = '';
  // }

  void clearForm() {
    /// ---------- FORM RX VALUES ----------
    customerName.value = '';
    mobile.value = '';
    bankName.value = '';
    dataType.value = '';
    contacted.value = 'No';
    remarkStatus.value = '';
    remark.value = '';
    followupDate.value = null;

    /// ---------- TEXT CONTROLLERS ----------
    customerNumberController.clear();
    remark.value = '';

    /// ---------- DIALER CONTROLLER RESET ----------
    _dialerController.customerName.value = '';
    _dialerController.salary.value = '';
    _dialerController.customerLoan.value = '';
    _dialerController.phoneNumber.value = '';
    _dialerController.customerNameController.clear();

    /// ---------- CALLBACK VISIBILITY RESET ----------
    // _remarkController.isCallback.value = false;

    /// ---------- EXTRA STATE RESET ----------
    _dialerController.datatype.value = '';
    _dialerController.elapsedTimeInSeconds.value = 0;
    _dialerController.followup_id.value = '';

    /// ---------- FORCE UI UPDATE (Important) ----------
    update(); // if using GetBuilder anywhere
  }

  // void setFromDate(DateTime date) {
  //   fromDate.value = date;
  //   fromDateController.text =
  //       DateFormat("yyyy-MM-dd").format(date); // Update TextField
  //   update();
  // }

  // // Function to set To Date
  // void setToDate(DateTime date) {
  //   toDate.value = date;
  //   toDateController.text =
  //       DateFormat("yyyy-MM-dd").format(date); // Update TextField
  //   update();
  // }

  void getDataOnMonth(String toDate, String fromDate) async {
    isLoading.value = true;

    try {
      if (toDate.isNotEmpty && fromDate.isNotEmpty) {
        debugPrint(" date range --> $toDate,$fromDate");

        var response = await _apiService.postRequest(
          APIUrls.followUpSubmitedData,
          {
            "telecaller_id": StaticStoredData.userId,
            "daterange": "$fromDate,$toDate"
          },
        );

        debugPrint(
            " data in filter -->  ${response.statusCode} ${response.body}");

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);

          var followBackData = FollowUpSubmitedList.fromJson(responseData);
          followBackList.value = followBackData.data ?? [];
        } else if (response.statusCode == 204) {
          followBackList.clear();
        } else {
          logOutput("Error: ${response.statusCode} - ${response.reasonPhrase}");
        }
      }
    } catch (e) {
      logOutput("Exception fetching follow-back list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Create a method to handle these calls
  Future<void> getAllDashboardData({
    required var dashboardController,
  }) async {
    await Future.microtask(() async {
      // Dashboard related API calls
      await dashboardController.getTimeGraph();
      await dashboardController.getActiveData(status: 1);
      await dashboardController.getActiveData(status: 2);

      // Follow back form related API calls
      await getCallBackData();
      // await getCallLogData();
      // await getDisbursementData();
    });
  }

  void updateFilteredList({String query = ''}) {
    try {
      /// 1️⃣ Build chip filters from API list
      final names = followBackList
          .map((e) => e.remarkStatus ?? '')
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();

      setFilters(names);

      final searchText = query.toLowerCase();
      final selected = selectedFilter.value;

      /// 2️⃣ Filter list
      final result = followBackList.where((item) {
        final name = item.customerName?.toLowerCase() ?? '';
        final mobile = item.contactNumber?.toLowerCase() ?? '';
        final remark = item.remarkStatus?.toLowerCase() ?? '';

        /// Search filter
        final searchMatch = searchText.isEmpty ||
            name.contains(searchText) ||
            mobile.contains(searchText);

        /// Chip filter (safe index check)
        bool chipMatch = true;
        if (selected > 0 && selected <= names.length) {
          chipMatch = remark == names[selected - 1].toLowerCase();
        }

        return searchMatch && chipMatch;
      }).toList();

      /// 3️⃣ Update reactive list
      filteredFollowBackList.assignAll(result);
    } catch (e) {
      filteredFollowBackList.clear();
    }
  }

  // void updateFilteredList({String query = ''}) {
  //   // 1️⃣ Build filter names for chips
  //   final names = followBackList
  //       .map((e) => e.remarkStatus ?? '')
  //       .where((e) => e.isNotEmpty)
  //       .toSet()
  //       .toList();
  //   setFilters(names);

  //   // 2️⃣ Filter by chip + search
  //   final search = query.toLowerCase();
  //   final selected = selectedFilter.value;

  //   // 🔥 Clear old list before filtering
  //   filteredFollowBackList.clear();

  //   filteredFollowBackList.assignAll(followBackList.where((item) {
  //     final name = item.customerName?.toLowerCase() ?? '';
  //     final mobile = item.contactNumber?.toLowerCase() ?? '';
  //     //  final bank = item.bankName?.toLowerCase() ?? '';
  //     final remark = item.remarkStatus?.toLowerCase() ?? '';

  //     // Search filter
  //     final searchMatch =
  //         search.isEmpty || name.contains(search) || mobile.contains(search);
  //     //|| bank.contains(search);

  //     // Chip filter
  //     final chipMatch =
  //         selected == 0 ? true : remark == names[selected - 1].toLowerCase();

  //     return searchMatch && chipMatch;
  //     //&& dateMatch;
  //   }).toList());
  //   print(filteredFollowBackList.length);
  // }

  // Method to refresh data (pull to refresh)

  Future<void> loadMore() async {
    if (!isLoading.value && hasMore.value) {
      await fetchFollowBackList(loadMore: true);
    }
  }

  // Call this when search or filters change
  Future<void> onSearchOrFilterChanged() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchFollowBackList(loadMore: false);
  }

  void selectFilter(int index) {
    FollowBackFormController followBackFormController = Get.find();
    selectedFilter.value = index;
    //  followBackFormController.updateFilteredList();
    String? teamleader = getSelectedTeamLeaderId();

    filtercallBack(teamLeaderId: teamleader);
  }

  void filtercallBack({
    String? teamLeaderId,
    String? searchQuery,
  }) {
    List<CallBackData> filteredList = allCallBackData;

    // Filter by team leader
    if (teamLeaderId != null && teamLeaderId.isNotEmpty) {
      filteredList =
          filteredList.where((e) => e.teamleaderId == teamLeaderId).toList();
    }

    // Filter by search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredList = filteredList.where((e) {
        return e.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    callBackData.assignAll(filteredList);
  }

  void clearFilters() {
    selectedFilter.value = 0;

    ScrollUtils.scrollToStart(filterScrollController);
    searchController.clear();
  }

  void setFilters(List<String> names) {
    filters.value = ["All", ...names.toSet()];
    update();
  }

  void onContactedChanged({
    required String value,
    required RemarkStatusController remarkController,
  }) {
    contacted.value = value;

    // 🔥 RESET dropdown selection
    remarkStatus.value = '';

    // 🔥 Load correct remark list
    if (value == 'Yes') {
      remarkController.fetchRemarkStatus('1');
    } else {
      remarkController.fetchRemarkStatus('2');
    }
  }
}
