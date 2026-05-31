import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/models/banker_details_model.dart';
import 'package:smart_solutions/models/banker_name_model.dart';
import 'package:smart_solutions/models/customerData_mobileNumber.dart';
import 'package:smart_solutions/models/data_entery_model.dart';
import 'package:smart_solutions/models/data_entry_bank_list.dart';
import 'package:smart_solutions/models/dsa_bank_list.dart';
import 'package:smart_solutions/models/dsa_name_model.dart';
import 'package:smart_solutions/models/leads_status_group.dart';
import 'package:smart_solutions/models/move_to_login_model.dart';
import 'package:smart_solutions/models/product_type.dart';
import 'package:smart_solutions/models/source_model.dart';
import 'package:smart_solutions/models/status_list_model.dart';
import 'package:smart_solutions/models/team_leader_model.dart';
import 'package:smart_solutions/models/tellecaller_name_model.dart';
import 'package:smart_solutions/services/api_service.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import '../constants/services.dart';
import 'theme_controller.dart';

class DataController extends GetxController {
  final ApiService _apiService = ApiService();
  var dateRangeList = <DateTime?>[].obs;
  var isLoading = true.obs;
  var isDataEntryLoading = true.obs;
  var isloginRequestDataEntryLoading = true.obs;

  var iseditLoading = true.obs;
  var dataList = <Data>[].obs;
  var disbursementdata = <Data>[].obs;
  var errorMessage = ''.obs;
  RxBool isSaveLoading = false.obs;
  // TEAM LEADER FILTER
  var teamLeaderList = <TeamleaderData>[].obs;
  var selectedTeamLeaderIds = <String>[].obs;

  bool granted = false;

  var allBankNamesList = <DataEntryBankList>[].obs;

  var selectedBanktransactionType = ''.obs;

  var selectedDemandDraftStatus = ''.obs;

  var dsaName = ''.obs;
  RxString tellecallerId = ''.obs;
  RxString dataId = ''.obs;
  RxString dsaId = ''.obs;
  RxString id = ''.obs;
  RxString loginRequestId = ''.obs;
  RxList<CommentData> commentList = <CommentData>[].obs;
  RxList<MoveToLoginModel> moveToLoginList =
      <MoveToLoginModel>[].obs; // LOGIN REQUEST LIST>
  RxString newComment = ''.obs;

  RxString adminSubadminName = ''.obs;
  var dsaNameList = <DsaModel>[].obs;
  var filterLeadStatus = <GetLeadStatusGroup>[].obs;
  var dsaBankList = <DsaBank>[].obs;
  var producttypeList = <productData>[].obs;
  var sourcingList = <SourceModel>[].obs;
  var bankerNameList = <BankerNameData>[].obs;
  var telecallerlist = <TellecallerData>[].obs;
  var statuslist = <statusData>[].obs;
  var allstatuslist = <statusData>[].obs;
  // RxList filterLeadStatus = [].obs;
  var date = ''.obs;
  var contactNumber = ''.obs;
  var customerName = ''.obs;
  var customerId = ''.obs;
  var income = ''.obs;
  var companyName = ''.obs;

  var caseType = ['BT & Topup', 'Fresh', 'OD'].obs;
  RxString selectedCaseType = ''.obs; // the selected value
  var loanAmount = ''.obs;
  final loanAmountController = TextEditingController();
  var dob = ''.obs;
  var selectedDsaId = ''.obs;
  var selectedproductType = ''.obs;
  var selectedBankName = ''.obs;
  var selectedBankId = ''.obs;
  var selectedBankerName = ''.obs;
  var selectTelecallerName = ''.obs;
  var selectedStatus = ''.obs;
  var selectedStatusName = ''.obs;

  var selectedSource = ''.obs;

//  var loginBank = ''.obs;
  var bankName = ''.obs;
  var bankId = ''.obs;
//  var bankerName = ''.obs;
  var bankerMobile = ''.obs;
  var bankerEmail = ''.obs;
  var losNo = ''.obs;
  var telecaller = ''.obs;
  var teamleader = ''.obs;
  var teamleaderId = ''.obs;
  var status = ''.obs;
  var source = ''.obs;
  var caseStudy = ''.obs;
  var comments = ''.obs;

  var isEdit = false.obs;
  var isNew = false.obs;

  // Default telecaller ID
  final String defaultTelecallerId = StaticStoredData.userId;

// search variables
  var showSearchField = false.obs; // 👈 observable toggle
  var searchText = "".obs;

  RxList<dynamic> todayCount = <dynamic>[].obs;
  RxList<dynamic> monthlyCount = <dynamic>[].obs;

  RxBool isMovetoLogin = false.obs;

  final CommonFilterController _commonFilterController =
      Get.find<CommonFilterController>();

  ThemeController themeController = Get.find<ThemeController>();

  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final incomeController = TextEditingController();
  final teamleaderController = TextEditingController();
  final tealleaderController = TextEditingController();
  final dobController = TextEditingController();
  final dateController = TextEditingController();
  final bankermobileController = TextEditingController();
  final bankeremailController = TextEditingController();
  final losController = TextEditingController();
  final caseStudyController = TextEditingController();
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    ever(selectedBankName, (value) {
      if (value != null && value.toString().isNotEmpty) {
        getBankerNameByloginBank(dsaId.value, value.toString());
      }
    });
    ever(selectedBankerName, (value) {
      if (value != null && value.toString().isNotEmpty) {
        getBankerDetailsName(value.toString());
      }
    });

    /// 🔥 Bind all fields in ONE LINE each
    bindController(mobileController, contactNumber);
    bindController(nameController, customerName);
    bindController(companyController, companyName);
    bindController(incomeController, income);
    bindController(teamleaderController, teamleader);
    bindController(dobController, dob);
    bindController(dateController, date);
    bindController(bankermobileController, bankerMobile);
    bindController(bankeremailController, bankerEmail);
    bindController(losController, losNo);
    bindController(caseStudyController, caseStudy);
    bindController(loanAmountController, loanAmount);
    _loadAllData();
  }

  void bindController(TextEditingController controller, RxString rx) {
    ever(rx, (value) {
      if (controller.text != value) {
        controller.text = value;
      }
    });

    /// 🔁 Controller → Rx (User typing)
    controller.addListener(() {
      if (rx.value != controller.text) {
        rx.value = controller.text;
      }
    });
  }

  void toggleSearch() {
    showSearchField.value = !showSearchField.value;
    if (!showSearchField.value) {
      searchText.value = "";
      refreshData();
    }
  }

  void clearSearch() {
    searchText.value = "";
    showSearchField.value = false;
    refreshData(); // 👈 reload without filter
  }

  @override
  void onClose() {
    for (final comment in commentList) {
      comment.dispose();
    }
    super.onClose();
  }

  // void addComment() {
  //   final newItem = CommentData(
  //       comment: newComment.value,
  //       userId: StaticStoredData.userId,
  //       date: DateTime.now().toString(),
  //       isLocal: true);

  //   commentList.add(newItem);

  //   newComment.value = '';

  //   // ✅ Move focus to newly added comment
  //   Future.delayed(const Duration(milliseconds: 100), () {
  //     newItem.focusNode.requestFocus();
  //   });
  // }

  void addComment() {
    final text = newComment.value.trim();

    // 🛑 Prevent empty comments
    // if (text.isEmpty) return;

    final newItem = CommentData(
      comment: text,
      userId: StaticStoredData.userId,
      date: DateTime.now().toIso8601String(),
      isLocal: true,
    );

    // ✅ Add to list
    commentList.add(newItem);

    // ✅ Clear input
    newComment.value = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newItem.focusNode.canRequestFocus) {
        newItem.focusNode.requestFocus();
      }
    });
  }

  Future<void> _loadAllData() async {
    try {
      isLoading(true);
      await Future.wait([
        getLeadsFilterData(),
        fetchDataEntryList(),
      ]);
    } catch (e) {
      logOutput("Error loading data: $e");
      isLoading(false); // Ensure loading is stopped on error
    } finally {
      isLoading(false); // 👈 stop loading in all cases
    }
  }

  Future<void> editLoadData() async {
    try {
      iseditLoading(true);
      await Future.wait([
        getDsaNameList(),
        getProductTypeList(),
        getTelecallerData(),
        getStatusData(),
      ]);
    } catch (e) {
      logOutput("Error loading data: $e");
    } finally {
      iseditLoading(false); // 👈 stop loading in all cases
    }
  }

  var selectedStatuses = <String>[].obs;

  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
  }

  // Future<void> applyStatusFilter() async {
  //   try {
  //     isLoading(true);
  //     dataList.clear();
  //     await fetchDataEntryList();
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<void> fetchDataEntryList() async {
    isLoading(true);
    try {
      final Map<String, dynamic> formData = {
        'telecaller_id': defaultTelecallerId
      };

      final range = _commonFilterController.selectedRange.value;

      if (range != null) {
        formData['daterange'] =
            "${DateFormat('dd-MM-yyyy').format(range.start)},"
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

      final response =
          await _apiService.postRequest(APIUrls.dataEntryFeild, formData);

      dataList.clear();
      selectedStatuses.clear();
      disbursementdata.clear();
      todayCount.clear();
      monthlyCount.clear();
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final dataEntryModel = DataEntryModel.fromJson(responseData);
        if (dataEntryModel.data != null) {
          dataList.assignAll(dataEntryModel.data!);
          disbursementdata.value = dataList
              .where((e) => e.dataEntryStatus == 'DISBURSED')
              .toSet()
              .toList();

          DateTime today = DateTime.now();

          todayCount.value = dataList
              .where((e) {
                DateTime dt = DateTime.parse(
                    e.date.toString()); // parse string to DateTime
                return dt.year == today.year &&
                    dt.month == today.month &&
                    dt.day == today.day;
              })
              .map((e) => e.teleCallerId)
              .toList();

          monthlyCount.value = dataList
              .where((e) {
                DateTime dt = DateTime.parse(e.date.toString());
                return dt.year == today.year && dt.month == today.month;
              })
              .map((e) => e.teleCallerId)
              .toList();
        }
      } else if (response.statusCode == 204) {
        logOutput('Data Entry Not Available');
      } else {
        throw Exception('Failed to load data entries');
      }
    } catch (e) {
      errorMessage.value = 'Error fetching data: ${e.toString()}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      isDataEntryLoading(false);
    }
  }

  Future<void> getLoginRequestTeamLeader() async {
    try {
      final response =
          await _apiService.getRequest(APIUrls.loginRequestTeamLeader);

      if (response.statusCode == 200) {
        final model = TealLeaderModel.fromJson(json.decode(response.body));

        if (model.data.isNotEmpty) {
          teamLeaderList.assignAll(model.data);
        }
      }
    } catch (e) {
      logOutput("Team leader api error: $e");
    }
  }

  Future<void> refreshData() async {
    try {
      selectedStatuses.clear();
      dataList.clear();
      await fetchDataEntryList();
    } catch (e) {
      logOutput("Error: $e");
    } finally {}
  }

  // Search functionality
  void searchData(String query) {
    if (query.isEmpty) {
      fetchDataEntryList();
      return;
    }

    final filteredList = dataList
        .where((data) =>
            (data.customerName?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (data.mobileNo?.contains(query) ?? false) ||
            (data.bankName?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    dataList.assignAll(filteredList);
  }

  Future<void> getLeadsFilterData() async {
    try {
      var response = await ApiService().getRequest(APIUrls.getAllStatusGroup);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final statusList = GetLeadStatusGroup.fromJson(responseData);
        if (statusList.data.isNotEmpty) {
          filterLeadStatus.add(statusList);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  String? _getStatusNameFromId() {
    final existing = statuslist.firstWhereOrNull(
      (e) => e.id == status.value,
    );
    return existing?.dataEntryStatus;
  }

  // Save login request
  Future<bool> saveDataEntryForm() async {
    isSaveLoading(true);

    //  final statusName = _getStatusNameFromId();

    // final productTypeName = _getProductNameFromId();

    // final sourceName = _getSourceNameFromId();

    try {
      // Prepare the fields map
      var fields = {
        'dsaName': selectedDsaId.value,
        'date': DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateFormat('dd-MM-yy HH:mm:ss').parse(date.value)),
        'mobile_no': contactNumber.value,
        "customer_name": customerName.value,
        // 'customer_id': id.value,
        'income': income.value,
        'company_name': companyName.value,
        // 'caseType': selectedCaseType.value,
        'case_study': caseStudy.value,
        'dob': dob.value,
        'loanAmount': loanAmount.value,
        'loginBank': selectedBankName.value,
        'bankerid': bankId.value,
        'bankerName': selectedBankerName.value,
        'bankerMobile': bankerMobile.value,
        'bankerEmail': bankerEmail.value,
        'losNo': losNo.value,
        'teleCallerid': tellecallerId.value,
        'teamLeader': teamleaderId.value,
        'product_type': selectedproductType.value,
        'sourcing': selectedSource.value,
        'status': selectedStatusName.value,
        'balancetransfer':
            selectedBanktransactionType.value == 'Yes' ? "1" : "2",
        'demand_draft_status':
            selectedDemandDraftStatus.value == 'Open' ? "1" : "2",
        'demand_draft_remark': '',
        'telecaller_id': StaticStoredData.userId,
        'customer_id': customerId.value
      };

      if (!isMovetoLogin.value) {
        fields['id'] = id.value;
      }

      if (isMovetoLogin.value) {
        fields['login_req_id'] = loginRequestId.value;
      }

      for (int i = 0; i < commentList.length; i++) {
        fields.addAll({
          'comment_status[$i]': commentList[i].commentStatus ?? '',
          'user_id[$i]': commentList[i].userId ?? '',
          'comments[$i]': commentList[i].comment ?? '',
          'comment_id[$i]': commentList[i].id ?? '',
          'comment_date[$i]': commentList[i].date ?? ''
        });
      }
      logOutput('Request fields: $fields');
      logOutput('Request fields: ${json.encode(fields)}');

      // Make the API request
      final response =
          await ApiService().postRequest(APIUrls.dataentrySave, fields);

      if (response.statusCode == 200) {
        // getLoginRequestList();
        // currentId.value = '';

        // loginRequestDate = DateTime.now().obs;
        // telecallerId = StaticStoredData.userId.obs;
        // customerName.value = '';
        // contactNumber.value = '';
        // loanStatus.value = '1'; // Default loan status
        // bankId.value = '';
        // loanAmount.value = '';
        // commonRemark.value = '';
        // remarksList.value = []; // To hold multiple remarks
        // id = ''.obs;
        // sourceId.value = '';

        return true;
      } else {
        return false;
        // ScaffoldMessenger.of(Get.context!).showSnackBar(
        //   const SnackBar(
        //     content: Text('Failed to save Data Entry!'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } catch (e) {
      logOutput("An error occurred while saving the login request: $e");
      isSaveLoading(false);
      return false;
    } finally {
      isSaveLoading(false);
    }
  }

  Future<void> getDsaNameList() async {
    try {
      var response = await ApiService().getRequest(APIUrls.dsaNameList);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];

        final List<DsaModel> sourceList =
            responseData.map((e) => DsaModel.fromJson(e)).toList();
        if (sourceList.isNotEmpty) {
          dsaNameList.assignAll(sourceList);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  Future<void> getProductTypeList() async {
    try {
      var response = await ApiService().postRequest(
          APIUrls.productTypeList, {'telecaller_id': StaticStoredData.userId});

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<productData> productlist =
            responseData.map((e) => productData.fromJson(e)).toList();
        if (productlist.isNotEmpty) {
          producttypeList.assignAll(productlist);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  Future<void> getDsaBankList(String dsaId) async {
    try {
      var body = {
        "dsa_id": dsaId
      }; // You can define your request body as needed
      var response = await ApiService().postRequest(APIUrls.dsaBanklist, body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<DsaBank> sourceList =
            responseData.map((e) => DsaBank.fromJson(e)).toList();
        if (sourceList.isNotEmpty) {
          dsaBankList.assignAll(sourceList);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  Future<void> getSourcingList() async {
    try {
      var body = {
        "telecaller_id": tellecallerId.value
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
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  Future<void> getBankerDetailsName(String id) async {
    try {
      var body = {
        "id": id,
        //     "bankName": bankName,
      };
      var response =
          await ApiService().postRequest(APIUrls.bankerNamelist, body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<BankerDetailsData> bankername =
            responseData.map((e) => BankerDetailsData.fromJson(e)).toList();
        // if (bankername.isNotEmpty) {
        //   //     selectedBankerName.value = bankername.first.bankerName.toString();
        bankerMobile.value = bankername.first.mobile.toString();
        bankerEmail.value = bankername.first.email.toString();
        //bankerNameList.assignAll(bankername);
        // }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  Future<void> getBankerNameByloginBank(String dsaId, String bankName) async {
    try {
      var body = {
        "dsa_id": dsaId,
        'bankName': bankName
        //     "bankName": bankName,
      };
      var response =
          await ApiService().postRequest(APIUrls.bankerNamedata, body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<BankerNameData> bankername =
            responseData.map((e) => BankerNameData.fromJson(e)).toList();
        if (bankername.isNotEmpty) {
          // selectedBankerName.value = bankername.first.bankerName.toString();
          // contactNumber.value = bankername.first.mobile.toString();
          bankerNameList.assignAll(bankername);
          // getBankerDetailsName(bankername.first.id);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
      // Ensure loading is set to false on error as well
    }
  }

  Future<void> getTelecallerData() async {
    try {
      var response = await ApiService().getRequest(APIUrls.telecallerlist);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        final List<TellecallerData> tellecallerData =
            responseData.map((e) => TellecallerData.fromJson(e)).toList();
        if (tellecallerData.isNotEmpty) {
          telecallerlist.assignAll(tellecallerData);
        }
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
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

  // Future<void> fetchmoveToLoginData(String id) async {
  //   DataController dataController = Get.find<DataController>();
  //   dataController.editLoadData();
  //   isloginRequestDataEntryLoading(true);

  //   try {
  //     Map<String, dynamic> data = {"login_id": id};
  //     var response =
  //         await ApiService().postRequest(APIUrls.getMoveToLoginData, data);

  //     if (response.statusCode == 200) {
  //       final moveToLoginModel = moveToLoginModelFromJson(response.body);
  //       final data = moveToLoginModel.data;

  //       if (data.customerLoginModel.customerName == null ||
  //           data.customerLoginModel.customerName.isEmpty) {
  //         Get.dialog(
  //           barrierDismissible: false,
  //           AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             title: const Row(
  //               children: [
  //                 Icon(Icons.error_outline, color: Colors.redAccent),
  //                 SizedBox(width: 10),
  //                 Text('Error'),
  //               ],
  //             ),
  //             content: const Text('Customer name not found.'),
  //             actions: [
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: themeController.primaryColor.value,
  //                   ),
  //                   onPressed: () async {
  //                     Get.back();
  //                     // 2️⃣ Close dialog
  //                     Get.back();
  //                   },
  //                   child: const Text(
  //                     'OK',
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //         // Get.dialog(
  //         //   WillPopScope(
  //         //     onWillPop: () =>
  //         //         Future.value(false), // Prevent back button dismissal
  //         //     child: AlertDialog(
  //         //       shape: RoundedRectangleBorder(
  //         //         borderRadius: BorderRadius.circular(16),
  //         //       ),
  //         //       titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
  //         //       contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
  //         //       actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
  //         //       title: const Row(
  //         //         children: [
  //         //           Icon(
  //         //             Icons.error_outline,
  //         //             color: Colors.redAccent,
  //         //             size: 28,
  //         //           ),
  //         //           SizedBox(width: 10),
  //         //           Text(
  //         //             'Error',
  //         //             style: TextStyle(
  //         //               fontWeight: FontWeight.bold,
  //         //             ),
  //         //           ),
  //         //         ],
  //         //       ),
  //         //       content: const Text(
  //         //         'Customer name not found.',
  //         //         style: TextStyle(
  //         //           fontSize: 14,
  //         //           color: Colors.black87,
  //         //         ),
  //         //       ),
  //         //       actions: [
  //         //         SizedBox(
  //         //           width: double.infinity,
  //         //           child: ElevatedButton(
  //         //             style: ElevatedButton.styleFrom(
  //         //               backgroundColor: themeController.primaryColor.value,
  //         //               shape: RoundedRectangleBorder(
  //         //                 borderRadius: BorderRadius.circular(10),
  //         //               ),
  //         //             ),
  //         //             onPressed: () async {
  //         //               if (Get.isSnackbarOpen) {
  //         //                 Get.closeCurrentSnackbar();
  //         //               }

  //         //               Get.back();
  //         //             },
  //         //             child: const Text(
  //         //               'OK',
  //         //               style: TextStyle(
  //         //                 fontWeight: FontWeight.bold,
  //         //                 color: Colors.white,
  //         //               ),
  //         //             ),
  //         //           ),
  //         //         ),
  //         //       ],
  //         //     ),
  //         //   ),
  //         //   barrierDismissible: false,
  //         // );

  //         return;
  //       }

  //       contactNumber.value = data.contactNumber;
  //       selectedSource.value = data.sourcing;
  //       loanAmountController.text = data.loanAmount;
  //       selectTelecallerName.value = data.telecallerId;
  //       loginRequestId.value = data.loginRequestId;

  //       selectedBankName.value = data.bankname;
  //       customerName.value = data.customerLoginModel.customerName;
  //       customerId.value = data.customerLoginModel.customerId;
  //       dob.value = DateFormat('dd-MM-yyyy')
  //           .format(DateTime.parse(data.customerLoginModel.dob));
  //       companyName.value = data.customerLoginModel.companyName;
  //       income.value = data.customerLoginModel.netIncome;

  //       if (data.telecallerId != null && data.telecallerId.isNotEmpty) {
  //         await getTeamLeadById(data.telecallerId);
  //       }
  //     }
  //   } catch (e) {
  //     logOutput('An error occurred while fetching source list: $e');
  //   } finally {
  //     isloginRequestDataEntryLoading(false);
  //   }
  // }
  Future<bool> fetchmoveToLoginData(String id) async {
    try {
      final response = await ApiService()
          .postRequest(APIUrls.getMoveToLoginData, {"login_id": id});

      if (response.statusCode == 200) {
        final model = moveToLoginModelFromJson(response.body);

        final data = model.data;

        if (data.customerLoginModel.customerName == null ||
            data.customerLoginModel.customerName.isEmpty) {
          return false;
        }

        // assign values only
        contactNumber.value = data.contactNumber;

        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      isloginRequestDataEntryLoading(false);
    }
  }

  Future<void> fetchDataEntryListSpecificId() async {
    isDataEntryLoading(true);
    try {
      Map<String, dynamic> body = {"telecaller_id": tellecallerId.value};
      var response =
          await ApiService().postRequest(APIUrls.dataEntryFeild, body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final dataEntryModel = DataEntryModel.fromJson(responseData);
        if (dataEntryModel.data != null) {
          final entry = dataEntryModel.data!
              .firstWhere((entry) => entry.id == dataId.toString());

          final amount = double.tryParse(entry.loanAmount.toString());

          // Assigning values to observables
          selectedDsaId.value = entry.dsaName.toString();
          selectedStatusName.value = entry.status.toString();
          id.value = entry.id.toString();
          dsaName.value = entry.dsaName.toString();
          contactNumber.value = entry.mobileNo.toString();
          customerName.value = entry.customerName ?? '';
          income.value = entry.income ?? '';
          companyName.value = entry.companyName ?? '';
          selectedCaseType.value = entry.caseType.toString();
          loanAmount.value = amount == null
              ? ''
              : (amount % 1 == 0
                  ? amount.toInt().toString()
                  : amount.toString());
          date.value = DateFormat('dd-MM-yyyy HH:mm:ss')
              .format(DateTime.parse(entry.date.toString()));
          // date.value =
          //     formatDate(entry.date?.toString(), 'dd-MM-yyyy HH:mm:ss');
          dob.value = formatDate(entry.dob, 'dd-MM-yyyy');
          selectedproductType.value = entry.productType ?? '';
          selectedBankerName.value = entry.bankerName ?? '';
          //    selectedBankId.value = entry.bankerId ?? '';

          selectedBankName.value = entry.loginBank ?? '';
          selectedBankerName.value = entry.bankerName ?? '';
          selectedStatus.value = entry.status ?? '';
          selectedSource.value = entry.sourcing ?? '';
          commentList.assignAll(entry.commentData ?? []);
          adminSubadminName.value = entry.adminSubAdminName ?? '';

          //      loginBank.value = entry.loginBank ?? '';
          bankName.value = entry.loginBank ?? '';
          bankId.value = entry.bankerId ?? '';
          //   bankerName.value = entry.bankerName ?? '';
          bankerMobile.value = entry.bankerMobile ?? '';
          bankerEmail.value = entry.bankerEmail ?? '';
          losNo.value = entry.losNo ?? '';
          selectTelecallerName.value = entry.teleCallerId ?? '';
          //    telecaller.value = entry.teleCallerName ?? '';
          teamleader.value = entry.tlName ?? '';
          teamleaderId.value = entry.teamLeader ?? '';
          selectedBanktransactionType.value =
              entry.balanceTransfer == "1" ? 'Yes' : 'No';
          selectedDemandDraftStatus.value =
              entry.demandDraftstatus == "1" ? 'Open' : 'Closed';
          //     status.value = entry.status ?? '';
          //    source.value = entry.sourcing ?? '';
          caseStudy.value = entry.caseStudy ?? '';
          comments.value = entry.comments ?? '';
        }
      }
    } catch (e) {
      isDataEntryLoading(false);
      logOutput('An error occurred while fetching source list: $e');
    } finally {
      isDataEntryLoading(false);
    }
  }

  Future<void> getMobileByCustomerData(String number) async {
    try {
      var body = {"mobile": number};
      var response =
          await ApiService().postRequest(APIUrls.mobileByCustomeData, body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body)['data'];
        CustomerData data = CustomerData.fromJson(responseData);

        income.value = data.netIncome.toString();
        companyName.value = data.companyName.toString();
        customerName.value = data.name.toString();
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
    }
  }

  Future<void> getTeamLeadById(String id) async {
    try {
      var body = {"telecaller_id": id};
      var response =
          await ApiService().postRequest(APIUrls.teamLeadByTeamId, body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // final List<dynamic> dataList = responseData['data'];

        // final Map<String, dynamic> firstItem = dataList[0];
        teamleaderId.value = responseData['data']['team_leader'].toString();
        teamleader.value = responseData['data']['name'];
        //     date.value = DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.now());
      }
    } catch (e) {
      logOutput('An error occurred while fetching source list: $e');
    }
  }
}

String formatDate(String? date, String format) {
  if (date == null || date.isEmpty) return '';

  try {
    final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
    return DateFormat(format).format(parsedDate);
  } catch (e) {
    return '';
  }
}
