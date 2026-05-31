import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/controllers/data_entry_controller.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import '../constants/services.dart';
import '../controllers/login_request_controller.dart';
import '../controllers/theme_controller.dart';

class DataEntryForm extends StatefulWidget {
  final String? id;
  final String? tellecallerId;
  final String? dsaId;
  final String? bankerId;
  final bool isMovetoLogin;
  const DataEntryForm(
      {super.key,
      required this.id,
      required this.tellecallerId,
      required this.dsaId,
      required this.bankerId,
      this.isMovetoLogin = false});

  @override
  State<DataEntryForm> createState() => _DataEntryFormState();
}

class _DataEntryFormState extends State<DataEntryForm> {
  final DataController controller = Get.find<DataController>();
  final _formKey = GlobalKey<FormState>();

  final ThemeController themeController = Get.find<ThemeController>();
  final LoginRequestController _loginRequestController =
      Get.find<LoginRequestController>();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialLoad(); // ✅ SAFE
    });

    // controller.tellecallerId.value = widget.tellecallerId ?? '';
    // controller.dataId.value = widget.id ?? '';
    // controller.dsaId.value = widget.dsaId ?? '';

    // controller.fetchDataEntryListSpecificId();
    // controller.getSourcingList();
    // controller.getDsaBankList(widget.dsaId ?? '');
    // controller.getBankerNameByloginBank(
    //     widget.dsaId.toString(), controller.selectedBankName.toString());
    // // controller.getBankerDetailsName(widget.bankerId ?? '');
    // controller.getMobileByCustomerData(controller.contactNumber.value);
    // controller.getTeamLeadById(widget.tellecallerId.toString());
  }

  initialLoad() async {
    controller.isMovetoLogin.value = widget.isMovetoLogin ?? false;
    controller.isLoading.value = true;
    controller.tellecallerId.value = widget.tellecallerId ?? '';
    controller.dataId.value = widget.id ?? '';
    controller.dsaId.value = widget.dsaId ?? '';
    controller.loginRequestId.value = widget.id ?? '';
    if (widget.isMovetoLogin == true) {
      await controller.fetchmoveToLoginData(widget.id.toString());
    } else {
      await controller.fetchDataEntryListSpecificId();
    }
    controller.getSourcingList();

    if (!widget.isMovetoLogin) {
      controller.getDsaBankList(widget.dsaId ?? '');
    }
    if (!widget.isMovetoLogin) {
      controller.getBankerNameByloginBank(
          widget.dsaId.toString(), controller.selectedBankName.value);
    }
    if (widget.isMovetoLogin) {
      controller.getBankerDetailsName(widget.bankerId ?? '');
    }

    controller.getMobileByCustomerData(controller.contactNumber.value);
    controller.getTeamLeadById(widget.tellecallerId.toString());
  }

  List<DropdownMenuItem<String>> yesNoItems = const [
    DropdownMenuItem(value: 'Yes', child: Text('Yes')),
    DropdownMenuItem(value: 'No', child: Text('No')),
  ];

  List<DropdownMenuItem<String>> openorClose = const [
    DropdownMenuItem(value: 'Open', child: Text('Open')),
    DropdownMenuItem(value: 'Closed', child: Text('Closed')),
  ];

  final _scrollController = ScrollController();

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emailKey = GlobalKey();

  void _scrollToFirstError() {
    final fields = [_nameKey, _emailKey];

    for (final key in fields) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }

  void _clearForm(DataController controller) {
    controller.dsaName.value = '';
    controller.date.value = '';
    controller.contactNumber.value = '';
    controller.customerName.value = '';
    controller.income.value = '';
    controller.companyName.value = '';
    controller.loanAmountController.text = '';
    controller.dob.value = '';
    controller.selectedStatus.value = '';
    controller.selectedCaseType.value = '';
    controller.selectedproductType.value = '';
    controller.selectedBankerName.value = '';
    controller.bankName.value = '';
    controller.bankerMobile.value = '';
    controller.bankerEmail.value = '';
    controller.losNo.value = '';
    controller.telecaller.value = '';
    controller.status.value = '';
    controller.source.value = '';
    controller.caseStudy.value = '';
    controller.comments.value = '';
    controller.teamleader.value = '';
    controller.selectedBanktransactionType.value = '';
    controller.selectedDemandDraftStatus.value = '';
    controller.selectedDsaId.value = '';

    controller.commentList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // prevent automatic pop
        onPopInvoked: (didPop) async {
          if (didPop) return;

          final shouldPop = await showDialog<bool>(
            context: context, // ❗ use page context, NOT Get.context
            barrierDismissible: false, // ✅ IMPORTANT
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Are you sure you want to go back?'),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor:
                          themeController.primaryColor.value.withOpacity(0.1),
                    ),
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: themeController.primaryColor.value,
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogContext, true);

                      // await controller.fetchDataEntryListSpecificId();
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );

          if (shouldPop == true) {
            controller.fetchDataEntryList();

            _clearForm(controller);

            // ✅ MANUALLY POP THE PAGE
            Navigator.of(context).pop();
          }
        },

        //  PopScope(
        //     canPop: false, // ❗ Prevent auto pop
        //     onPopInvoked: (didPop) async {
        //       if (didPop) return;

        //       final shouldPop = await showDialog<bool>(
        //         context: Get.context!,
        //         builder: (context) {
        //           return AlertDialog(
        //             title: const Text('Confirm'),
        //             content: const Text('Are you sure you want to go back?'),
        //             actions: [
        //               TextButton(
        //                 onPressed: () => Navigator.pop(context, false),
        //                 child: const Text('Cancel'),
        //               ),
        //               ElevatedButton(
        //                 onPressed: () => Navigator.pop(context, true),
        //                 child: const Text('Yes'),
        //               ),
        //             ],
        //           );
        //         },
        //       );

        //       if (shouldPop == true) {
        //         controller.dsaName.value = '';
        //         controller.date.value = '';
        //         controller.contactNumber.value = '';
        //         controller.customerName.value = '';
        //         controller.income.value = '';
        //         controller.companyName.value = '';
        //         controller.loanAmountController.text = '';
        //         controller.dob.value = '';
        //         controller.selectedStatus.value = '';
        //         controller.selectedCaseType.value = '';
        //         controller.selectedproductType.value = '';
        //         controller.selectedBankerName.value = '';
        //         controller.bankName.value = '';
        //         controller.bankerMobile.value = '';
        //         controller.bankerEmail.value = '';
        //         controller.losNo.value = '';
        //         controller.telecaller.value = '';
        //         controller.status.value = '';
        //         controller.source.value = '';
        //         controller.caseStudy.value = '';
        //         controller.comments.value = '';
        //         controller.teamleader.value = '';
        //         controller.selectedBanktransactionType.value = '';
        //         controller.selectedDemandDraftStatus.value = '';
        //         controller.commentList.clear();

        //         /// ✅ GO BACK
        //         Navigator.pop(context);
        //       }
        //     },

        //  PopScope(
        //     onPopInvoked: (didPop) {
        //       if (didPop) {
        //         controller.dsaName.value = '';
        //         controller.date.value = '';
        //         controller.contactNumber.value = '';
        //         controller.customerName.value = '';

        //         // controller.date = ''.obs;
        //         // controller.telecallerId = StaticStoredData.userId.obs;
        //         controller.customerName.value = '';
        //         controller.income.value = '';
        //         controller.companyName.value = ''; // Default loan status
        //         //    controller.caseType.value = '';
        //         controller.loanAmountController.text = '';
        //         controller.dob.value = '';
        //         controller.selectedStatus.value = '';
        //         controller.selectedCaseType.value = '';
        //         controller.selectedproductType.value =
        //             ''; // To hold multiple remarks
        //         controller.bankName = ''.obs;
        //         controller.bankerMobile.value = '';
        //         controller.bankerEmail.value = '';
        //         controller.losNo.value = '';
        //         controller.telecaller.value = '';
        //         controller.status.value = '';
        //         controller.source.value = '';
        //         controller.caseStudy.value = '';
        //         controller.comments.value = '';
        //         controller.teamleader.value = '';
        //       }
        //     },
        child: CommonScaffold(
            title: 'Data Entry Form',
            actions: [
              Obx(() => controller.isNew.value
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: () {
                        controller.isEdit.value = !controller.isEdit.value;
                      },
                      icon: Icon(
                        Icons.edit,
                        color:
                            controller.isEdit.value ? Colors.red : Colors.white,
                      )))
            ],
            // appBar: AppBar(
            //   centerTitle: true,
            //   title:
            //       const Text('Data Entry Form', style: TextStyle(fontSize: 20)),
            //   actions: [
            //     Obx(() => controller.isNew.value
            //         ? const SizedBox.shrink()
            //         : IconButton(
            //             onPressed: () {
            //               controller.isEdit.value = !controller.isEdit.value;
            //             },
            //             icon: Icon(
            //               Icons.edit,
            //               color: controller.isEdit.value
            //                   ? Colors.red
            //                   : Colors.white,
            //             )))
            //   ],
            // ),
            body: Obx(() {
              if (controller.isDataEntryLoading.value &&
                  controller.isloginRequestDataEntryLoading.value) {
                return const LoadingPage();
              }
              return Container(
                color: const Color(0xffF5F7FB), // light modern background
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.h),
                          titileWithIcon(
                              title: 'Customer Information',
                              iconPath: 'assets/images/user.svg'),
                          SizedBox(height: 10.h),

                          _buildTextField(
                            controller: controller.mobileController,
                            label: 'Mobile Number',
                            readOnly: true,
                            prefixIcon: SvgPicture.asset(
                              'assets/images/phone.svg',
                              color: themeController.primaryColor.value,
                              height: 20,
                              width: 20,
                            ),
                            content: controller.contactNumber,
                            onChanged: (value) =>
                                controller.contactNumber.value = value,
                            inputType: TextInputType.phone,
                            validator: _validatePhone,
                          ),
                          Obx(
                            () => _buildTextField(
                              controller: controller.nameController,
                              label: 'Customer Name',
                              prefixIcon: SvgPicture.asset(
                                'assets/images/user.svg',
                                color: themeController.primaryColor.value,
                                height: 20,
                                width: 20,
                              ),
                              content: controller.customerName,
                              onChanged: (value) =>
                                  controller.customerName.value = value,
                              inputType: TextInputType.text,
                              validator: _validateNotEmpty,
                            ),
                          ),

                          Obx(
                            () => _buildTextField(
                              controller: controller.dobController,
                              content: controller.dob,
                              prefixIcon: SvgPicture.asset(
                                'assets/images/dob.svg',
                                color: themeController.primaryColor.value,
                                height: 20,
                                width: 20,
                              ),
                              label: 'DOB',
                              //   validator: (value) => _validateNotEmpty(value),
                              onChanged: (value) =>
                                  controller.dob.value = value,
                            ),
                          ),
                          _buildTextField(
                            controller: controller.companyController,
                            label: 'Company Name',
                            prefixIcon: SvgPicture.asset(
                              'assets/images/company_name.svg',
                              color: themeController.primaryColor.value,
                              height: 20,
                              width: 20,
                            ),
                            content: controller.companyName,
                            onChanged: (value) =>
                                controller.companyName.value = value,
                            inputType: TextInputType.text,
                            validator: _validateNotEmpty,
                          ),

                          _buildTextField(
                            label: 'Income',
                            controller: controller.incomeController,
                            prefixIcon: SvgPicture.asset(
                              'assets/images/data_type.svg',
                              height: 20,
                              width: 20,
                              color: themeController.primaryColor.value,
                            ),
                            content: controller.income,
                            onChanged: (value) =>
                                controller.income.value = value,
                            inputType: TextInputType.phone,
                            validator: _validateNotEmpty,
                          ),

                          titileWithIcon(
                              title: 'Sourcing Details',
                              iconPath: 'assets/images/data_type.svg'),

                          _buildDsaDropdown(),

                          _buildTextField(
                              controller: controller.dateController,
                              content: controller.date,
                              prefixIcon: SvgPicture.asset(
                                  'assets/images/calendar.svg',
                                  color: themeController.primaryColor.value,
                                  height: 20,
                                  width: 20),
                              label: 'Entry Date',
                              validator: (value) => _validatePhone(value),
                              onChanged: (value) =>
                                  controller.date.value = value),

                          _buildTeleCallerDropdown(),

                          _buildTextField(
                            controller: controller.teamleaderController,
                            label: 'Team Leader',
                            readOnly: true,
                            prefixIcon: SvgPicture.asset(
                              'assets/images/teamleader.svg',
                              height: 20,
                              width: 20,
                              color: themeController.primaryColor.value,
                            ),
                            content: controller.teamleader,
                            onChanged: (value) =>
                                controller.teamleader.value = value,
                            // validator: _validateNotEmpty,
                          ),

                          _buildSourcingDropdown(),

                          titileWithIcon(
                              title: 'Loan & Case Details',
                              iconPath: 'assets/images/rupees.svg'),

                          const SizedBox(height: 10),

                          _buildProductTypeDropdown(),

                          Obx(
                            () => buildCommonDropdown(
                              hint: 'Balance Transfer',
                              items: yesNoItems,
                              isEnabled: controller.isEdit.value,
                              iconPath: 'assets/images/teamleader.svg',
                              value: controller
                                      .selectedBanktransactionType.value.isEmpty
                                  ? null
                                  : controller
                                      .selectedBanktransactionType.value,
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  controller.selectedBanktransactionType.value =
                                      newValue;

                                  if (newValue == 'Yes') {
                                    controller.selectedDemandDraftStatus.value =
                                        'Open';
                                  } else if (newValue == 'No') {
                                    controller.selectedDemandDraftStatus.value =
                                        'Closed';
                                  }
                                }
                              },
                            ),
                          ),

                          Obx(
                            () => buildCommonDropdown(
                              hint: 'Demand Draft Status',
                              items: openorClose,
                              iconPath: 'assets/images/teamleader.svg',

                              value: controller
                                      .selectedDemandDraftStatus.value.isEmpty
                                  ? null
                                  : controller.selectedDemandDraftStatus.value,

                              // 🔥 Disable when Balance Transfer = NO
                              isEnabled: controller.isEdit.value &&
                                  controller
                                          .selectedBanktransactionType.value ==
                                      'Yes',

                              onChanged: (newValue) {
                                if (newValue != null) {
                                  controller.selectedDemandDraftStatus.value =
                                      newValue;
                                }
                              },
                            ),
                          ),

                          //   _buildCaseTypeDropdown(),

                          titileWithIcon(
                              title: 'Bank Information',
                              iconPath: 'assets/images/bank.svg'),

                          const SizedBox(height: 10),

                          _buildloginBankDropdown(),
                          const SizedBox(height: 10),

                          _buildBankerNameDropdown(),
                          const SizedBox(height: 10),

                          _buildTextField(
                            controller: controller.bankermobileController,
                            label: 'Banker Mobile',
                            prefixIcon: SvgPicture.asset(
                              'assets/images/phone.svg',
                              color: themeController.primaryColor.value,
                              height: 20,
                              width: 20,
                            ),
                            content: controller.bankerMobile,
                            onChanged: (value) =>
                                controller.bankerMobile.value = value,
                            // validator: _validateNotEmpty,
                          ),

                          _buildTextField(
                              controller: controller.bankeremailController,
                              label: 'Banker Email',
                              prefixIcon: SvgPicture.asset(
                                'assets/images/email.svg',
                                color: themeController.primaryColor.value,
                                height: 20,
                                width: 20,
                              ),
                              content: controller.bankerEmail,
                              onChanged: (value) =>
                                  controller.bankerEmail.value = value),

                          Obx(
                            () => buildLoanAmountField(
                              controller: controller.loanAmountController,
                              value: controller.loanAmount,
                              isEnabled: controller.isEdit.value,
                            ),
                          ),

                          // _buildTextField(
                          //   label: 'Loan Amount',
                          //   content: controller.loanAmount,
                          //   inputType: TextInputType.number,
                          //   formatAsCurrency: true,
                          //   prefixIcon: SvgPicture.asset(
                          //     'assets/images/rupees.svg',
                          //     height: 20,
                          //     width: 20,
                          //   ),
                          // ),

                          // _buildTextField(
                          //   label: 'Loan Amount',
                          //   prefixIcon: SvgPicture.asset(
                          //     'assets/images/rupees.svg',
                          //     color: themeController.primaryColor.value,
                          //     height: 20,
                          //     width: 20,
                          //   ),
                          //   content: controller.loanAmountController.text
                          //       .toString()
                          //       .obs,
                          //   formatAsCurrency: true,
                          //   // CurrencyUtils.formatIndianCurrency(
                          //   //     controller.loanAmount.value),
                          //   // onChanged: (value) {
                          //   //   // Remove commas to get the numeric value before formatting
                          //   //   String plainTextValue = value.replaceAll(',', '');
                          //   //   controller.loanAmount.value = plainTextValue;

                          //   //   // Format the numeric value back to the Indian format
                          //   //   String formattedValue = NumberFormat.currency(
                          //   //           locale: 'en_IN',
                          //   //           symbol: '',
                          //   //           decimalDigits: 0)
                          //   //       .format(int.tryParse(plainTextValue) ?? 0);

                          //   //   controller.loanAmount.value = formattedValue;
                          //   // },
                          //   inputType: TextInputType.number,
                          //   validator: _validateNumber,
                          // ),

                          _buildTextField(
                            controller: controller.losController,
                            label: 'LOS No.',
                            prefixIcon: SvgPicture.asset(
                              'assets/images/company_name.svg',
                              color: themeController.primaryColor.value,
                              height: 20,
                              width: 20,
                            ),
                            content: controller.losNo,
                            onChanged: (value) =>
                                controller.losNo.value = value,
                            // validator: _validateNotEmpty,
                          ),

                          const SizedBox(height: 10),

                          _buildStatusDropdown(),
                          const SizedBox(height: 10),

                          titileWithIcon(
                              title: 'Case Study & Comments',
                              iconPath: 'assets/images/comment-detail.svg'),

                          _buildTextField(
                            controller: controller.caseStudyController,
                            label: 'Case Study ',
                            content: controller.caseStudy,
                            onChanged: (value) =>
                                controller.caseStudy.value = value,
                            validator: _validateNotEmpty,
                          ),

                          Obx(
                            () => ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.commentList.length,
                              itemBuilder: (context, index) {
                                final comment = controller.commentList[index];

                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller: comment
                                                  .controller, // ✅ REQUIRED
                                              content:
                                                  (comment.comment ?? '').obs,
                                              label: 'Comment',
                                              focusNode: comment.focusNode,
                                              onChanged: (value) {
                                                comment.comment = value;
                                              },
                                            ),
                                          ),

                                          /// ✅ Show cross ONLY for new comments
                                          if (comment.isLocal)
                                            GestureDetector(
                                              onTap: () {
                                                controller.commentList
                                                    .removeAt(index);
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              'By ${comment.name ?? 'N/A'} '
                                              'on ${DateFormat('MMM dd, yyyy hh:mm:ss').format(DateTime.parse(comment.date ?? ''))}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    themeController.primaryColor.value,
                                minimumSize: const Size(120, 40),
                              ),
                              onPressed: controller.addComment,
                              child: const Text('Add Comment'),
                            ),
                          ),

                          // _buildTextField(
                          //   label: 'Comments ',
                          //   content: controller.comments,
                          //   onChanged: (value) =>
                          //       controller.comments.value = value,
                          //   // validator: _validateNotEmpty,
                          // ),
                          // const SizedBox(height: 5),
                          // Container(
                          //   alignment: Alignment.bottomRight,
                          //   child: Text(
                          //     textAlign: TextAlign.end,
                          //     'By ${controller.adminSubadminName.value.isNotEmpty ? controller.adminSubadminName.value : 'N/A'}  ',
                          //     //on ${DateFormat('dd-MM-yy HH:mm:ss').format(DateTime.parse(controller.date.toString()))}',
                          //     style: const TextStyle(
                          //         fontSize: 15, color: Colors.grey),
                          //   ),
                          // ),

                          const SizedBox(height: 20),

                          // // _buildLoanStatusDropdown(),
                          // // const SizedBox(height: 10),
                          // _buildAllBankNamesDropdown(),
                          // const SizedBox(height: 10),

                          // _buildSourcingDropdown(),
                          // const SizedBox(height: 10),

                          // _buildTextField(
                          //   label: 'Common remark',
                          //   content: controller.commonRemark.value,
                          //   onChanged: (value) => controller.commonRemark.value = value,
                          //   // validator: _validateNotEmpty,
                          // ),
                          // const SizedBox(height: 10),
                          // // Dynamic Remarks Section
                          // _buildRemarksSection(),
                          // const SizedBox(height: 20),

                          Center(
                            child: Obx(() => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        themeController.primaryColor.value,
                                    minimumSize: const Size(120, 45),
                                  ),
                                  onPressed: controller.isDataEntryLoading.value
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final success = await controller
                                                .saveDataEntryForm();

                                            if (!mounted) return;

                                            if (success) {
                                              _loginRequestController
                                                  .getLoginRequestList();

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Data Entry saved successfully!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              Navigator.pop(context);

                                              controller.fetchDataEntryList();
                                              // _loginRequestController
                                              //     .getLoginRequestList();
                                              // ScaffoldMessenger.of(context)
                                              //     .showSnackBar(
                                              //   const SnackBar(
                                              //     content: Text(
                                              //         'Data Entry saved successfully!'),
                                              //     backgroundColor: Colors.green,
                                              //   ),
                                              // );

                                              // Navigator.pop(context); // ✅ SAFE
                                              // controller.fetchDataEntryList();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Failed to save data'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } else {
                                            _scrollToFirstError();
                                          }
                                        },
                                  child: controller.isSaveLoading.value
                                      ? const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              "Submitting...",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                )),
                          )

                          // Center(
                          //   child: Obx(() => ElevatedButton(
                          //         onPressed: () {
                          //           if (_formKey.currentState!.validate()) {
                          //             controller
                          //                 .saveDataEntryForm(); // Call save method
                          //             //        controller.getLoginRequestList();
                          //           }
                          //         },
                          //         child: controller.isDataEntryLoading.value
                          //             ? const LoadingPage()
                          //             : const Padding(
                          //                 padding: EdgeInsets.symmetric(
                          //                     horizontal: 24.0),
                          //                 child: Text(
                          //                   'Submit',
                          //                   style:
                          //                       TextStyle(color: Colors.white),
                          //                 ),
                          //               ),
                          //       )),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })));
  }

  Widget _buildTextField({
    required TextEditingController controller, // ✅ MUST
    FocusNode? focusNode, // ✅ ADD THIS
    required RxString content,
    required String label,
    ValueChanged<String>? onChanged,
    Widget? prefixIcon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    bool formatAsCurrency = false,
    bool readOnly = false,
  }) {
    Widget? decoratedPrefixIcon;

    if (prefixIcon != null) {
      decoratedPrefixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 8.0),
            child: prefixIcon,
          ),
          const SizedBox(
            height: 50,
            width: 5,
            child: VerticalDivider(thickness: 1),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.secondayColor)),
          TextFormField(
            controller: controller,
            keyboardType: inputType,
            maxLines: null,
            readOnly: readOnly ? true : !this.controller.isEdit.value,
            focusNode: focusNode,
            decoration: InputDecoration(
              prefixIcon: decoratedPrefixIcon,
              hintText: "Enter $label",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),

            style: const TextStyle(color: AppColors.secondayColor),

            onChanged: (value) {
              content.value = value;
              if (onChanged != null) onChanged(value);
            },

            // ✅ Currency formatting without breaking typing
            onEditingComplete: () {
              if (formatAsCurrency) {
                final plain = controller.text.replaceAll(',', '');
                final number = int.tryParse(plain);

                if (number != null) {
                  final formatted =
                      CurrencyUtils.formatIndianCurrency(number.toString());

                  controller.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );

                  content.value = formatted;
                }
              }
            },

            validator: validator,
          ),
        ],
      ),
    );
  }

  // Widget _buildTextField({
  //   required RxString content,
  //   required String label,
  //   ValueChanged<String>? onChanged,
  //   Widget? prefixIcon,
  //   TextInputType inputType = TextInputType.text,
  //   String? Function(String?)? validator,
  //   bool formatAsCurrency = false,
  // }) {
  //   // ✅ Create controller ONCE using GetX
  //   final textController = TextEditingController();

  //   // ✅ Set initial value only once
  //   textController.text = content.value;

  //   Widget? decoratedPrefixIcon;

  //   if (prefixIcon != null) {
  //     decoratedPrefixIcon = Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.only(left: 10.0, right: 8.0),
  //           child: prefixIcon,
  //         ),
  //         SizedBox(
  //           height: 50,
  //           width: 5,
  //           child: VerticalDivider(
  //             thickness: 1,
  //             color: themeController.primaryColor.value,
  //           ),
  //         ),
  //       ],
  //     );
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(label, style: const TextStyle(color: AppColors.secondayColor)),
  //         TextFormField(
  //           controller: textController,
  //           keyboardType: inputType,
  //           maxLines: null,
  //           readOnly: !controller.isEdit.value,

  //           decoration: InputDecoration(
  //             prefixIcon: decoratedPrefixIcon,
  //             hintText: "Enter $label",
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10.0),
  //             ),
  //           ),

  //           style: const TextStyle(color: AppColors.secondayColor),

  //           // ✅ DO NOT format here
  //           onChanged: (value) {
  //             content.value = value;
  //             if (onChanged != null) onChanged(value);
  //           },

  //           // ✅ Format AFTER typing
  //           onFieldSubmitted: (value) {
  //             if (formatAsCurrency) {
  //               final plain = value.replaceAll(',', '');
  //               final number = int.tryParse(plain);

  //               if (number != null) {
  //                 final formatted =
  //                     CurrencyUtils.formatIndianCurrency(number.toString());

  //                 textController.value = TextEditingValue(
  //                   text: formatted,
  //                   selection: TextSelection.collapsed(
  //                     offset: formatted.length,
  //                   ),
  //                 );

  //                 content.value = formatted;
  //               }
  //             }
  //           },

  //           validator: validator,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildLoanAmountField({
    required TextEditingController controller,
    required RxString value,
    required isEnabled,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Loan Amount'),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            readOnly: !isEnabled,
            decoration: InputDecoration(
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 8.0),
                    child: SvgPicture.asset(
                      'assets/images/rupees.svg',
                      color: themeController.primaryColor.value,
                      height: 20,
                      width: 20,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 5,
                    child: VerticalDivider(
                      thickness: 1,
                      color: themeController.primaryColor.value,
                    ),
                  ),
                ],
              ),
              hintText: "Enter Loan Amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),

            // InputDecoration(
            //   prefixIcon: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       SvgPicture.asset(
            //         'assets/images/rupees.svg',
            //         height: 20,
            //         width: 20,
            //       ),
            //       SizedBox(
            //         height: 50,
            //         width: 5,
            //         child: VerticalDivider(
            //           thickness: 1,
            //           color: themeController.primaryColor.value,
            //         ),
            //       ),
            //     ],
            //   ),
            //   hintText: "Enter Loan Amount",
            //   border: OutlineInputBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            // ),

            // ✅ Store raw value
            onChanged: (text) {
              value.value = text.replaceAll(',', '');
            },

            // ✅ Format AFTER typing
            onFieldSubmitted: (text) {
              final plain = text.replaceAll(',', '');
              final number = int.tryParse(plain);

              if (number != null) {
                final formatted =
                    CurrencyUtils.formatIndianCurrency(number.toString());

                controller.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(
                    offset: formatted.length,
                  ),
                );

                value.value = formatted;
              }
            },

            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter Loan Amount";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  // Widget _buildTextField({
  //   required RxString content,
  //   required String label,
  //   ValueChanged<String>? onChanged,
  //   Widget? prefixIcon,
  //   TextInputType inputType = TextInputType.text,
  //   String? Function(String?)? validator,
  //   bool formatAsCurrency = false, // optional flag
  // }) {
  //   final textController = TextEditingController(text: content.value);

  //   // Keep the controller in sync with the content
  //   textController.selection = TextSelection.fromPosition(
  //     TextPosition(offset: textController.text.length),
  //   );

  //   Widget? decoratedPrefixIcon;

  //   if (prefixIcon != null) {
  //     decoratedPrefixIcon = Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Padding(
  //             padding: const EdgeInsets.only(left: 10.0, right: 8.0),
  //             child: prefixIcon),
  //         SizedBox(
  //           height: 50,
  //           width: 5,
  //           child: VerticalDivider(
  //               width: 1,
  //               thickness: 1,
  //               color: themeController.primaryColor.value),
  //         ),
  //       ],
  //     );
  //   }
  //   return Obx(() {
  //     final displayValue = formatAsCurrency
  //         ? CurrencyUtils.formatIndianCurrency(content.value)
  //         : content.value;

  //     if (textController.text != displayValue) {
  //       textController.text = displayValue;
  //       textController.selection = TextSelection.fromPosition(
  //         TextPosition(offset: textController.text.length),
  //       );
  //     }

  //     return Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(label,
  //                 style: const TextStyle(color: AppColors.secondayColor)),
  //             TextFormField(
  //               keyboardType: inputType,
  //               maxLines: null,
  //               readOnly: !controller.isEdit.value,
  //               controller: textController,
  //               //  initialValue: content.isNotEmpty ? content : null,
  //               decoration: InputDecoration(
  //                 prefixIcon: decoratedPrefixIcon,
  //                 hintText: "Enter $label",
  //                 labelStyle: const TextStyle(color: AppColors.secondayColor),
  //                 border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10.0)),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   borderSide:
  //                       BorderSide(color: themeController.primaryColor.value),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10.0),
  //                     borderSide: BorderSide(
  //                         color: themeController.primaryColor.value, width: 2)),
  //                 filled: true,
  //                 fillColor: AppColors.backgroundColor,
  //               ),
  //               style: const TextStyle(color: AppColors.secondayColor),
  //               onChanged: onChanged,
  //               validator: validator,
  //             ),
  //           ],
  //         ));
  //   });
  // }

  // Dynamic Remarks Section
  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    final numeric = value.replaceAll(RegExp(r'[^\d]'), '');
    if (double.tryParse(numeric) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Widget _buildAllBankNamesDropdown() {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: LoadingPage())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(color: AppColors.secondayColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: themeController.primaryColor.value,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: themeController.primaryColor.value,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                ),
                value: _getInitialBankValue(),
                hint: const Text(
                  'Select bank',
                  style: TextStyle(color: Colors.grey),
                ),
                // isExpanded: true, // Ensures the dropdown takes full width
                items: _buildBankDropdownItems(),
                onChanged: !controller.isEdit.value
                    ? null
                    : (newValue) {
                        logOutput("new value is $newValue");
                        if (newValue != null) {
                          controller.bankName.value = newValue;
                        }
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a bank';
                  }
                  return null;
                },
              ),
            ),
    );
  }

// Helper method to get the initial bank value
  String? _getInitialBankValue() {
    //   log('controller.bankId.value: ${controller.bankName.value}');
    // Check if the controller's bankId is in the available bank list
    final existingBank = controller.allBankNamesList
        .firstWhereOrNull((bank) => bank.bankName == controller.bankName.value);
    return existingBank
        ?.bankName; // If found, return it; otherwise, return null
  }

// Helper method to build dropdown items
  List<DropdownMenuItem<String>> _buildBankDropdownItems() {
    return controller.allBankNamesList.map((bank) {
      return DropdownMenuItem<String>(
        value: bank.dsaId,
        child: Text(
          bank.bankName ?? '',
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  //
  Widget _buildSourcingDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Source',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Select Source',
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/images/data_type.svg',
                            color: themeController.primaryColor.value,
                            height: 20,
                            width: 20),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialSourceValue(),
              hint: const Text(
                'Select Source',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildSourceDropdownItems(),
              onChanged: controller.isEdit.value
                  ? (newValue) {
                      if (newValue != null) {
                        controller.source.value = newValue;
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Source';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDsaDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DSA Name',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'DSA Name',
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/bank.svg',
                          color: themeController.primaryColor.value,
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialDsaValue(),
              hint: const Text(
                'Select DSA Name',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildDsaDropdownItems(),
              onChanged: controller.isEdit.value
                  ? (newValue) {
                      if (newValue != null) {
                        controller.dsaName.value = newValue;
                        controller.selectedDsaId.value = newValue;
                        controller.caseType.clear();
                        //  controller.producttypeList.clear();
                        controller.selectedBankName.value = '';
                        controller.dsaName.value = '';
                        controller.bankerNameList.clear();
                        controller.bankerMobile.value = '';
                        controller.bankerEmail.value = '';
                        //  controller.telecaller.value = '';
                        // controller.teamleader.value = '';
                        //  controller.status.value = '';
                        controller.getDsaBankList(newValue);
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Source';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseTypeDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Case Type',
            prefixIcon: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/case_type.svg',
                      height: 24,
                      width: 24,
                      color: themeController.primaryColor.value,
                    ),
                    SizedBox(width: 5.w),
                    VerticalDivider(
                      thickness: 1,
                      color: themeController.primaryColor.value,
                    ),
                  ],
                ),
              ),
            ),
            labelStyle: const TextStyle(color: AppColors.secondayColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: themeController.primaryColor.value,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: themeController.primaryColor.value,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.backgroundColor,
          ),
          value: _getInitialCaseTypeValue(),
          hint: const Text(
            'Select Case Type',
            style: TextStyle(color: Colors.grey),
          ),
          items: _buildCaseTypeDropdownItems(),
          onChanged: controller.isEdit.value
              ? (newValue) {
                  if (newValue != null) {
                    //  controller.caseType.value = newValue;
                  }
                }
              : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a Source';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildProductTypeDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Type',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Product Type',
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/loan_amount.svg',
                          color: themeController.primaryColor.value,
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialProductTypeValue(),
              hint: const Text(
                'Select Product Type',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildProductTypeDropdownItems(),
              onChanged: controller.isEdit.value
                  ? (newValue) {
                      if (newValue != null) {
                        controller.selectedproductType.value = newValue;
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Product type';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildloginBankDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Login Bank',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/images/bank.svg',
                            color: themeController.primaryColor.value,
                            height: 24,
                            width: 24),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                hintText: 'Login Bank',
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: themeController.primaryColor.value,
                    )),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialloginBankValue(),
              hint: const Text(
                'Select Bank Name ',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildDsaBankloginNameDropdownItems(),
              onChanged: controller.isEdit.value
                  ? (newValue) {
                      if (newValue != null) {
                        controller.selectedBankName.value = newValue;
                        // ✅ Find bankId using bankName
                        // final selectedBank = controller.dsaBankList.firstWhere(
                        //   (e) => e.bankName == newValue,
                        // );
                        controller.getBankerNameByloginBank(
                            controller.selectedDsaId.toString(),
                            controller.selectedBankName.value);
                        //  selectedBank.bankId.toString());
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Source';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankerNameDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Banker Name',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Banker Name',
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/user.svg',
                          height: 20,
                          width: 20,
                          color: themeController.primaryColor.value,
                        ),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: themeController.primaryColor.value,
                    )),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: themeController.primaryColor.value, width: 2),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialBankerValue(),
              hint: const Text(
                'Select Banker Name ',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildBankerNameDropdownItems(),
              onChanged: controller.isEdit.value
                  ? (newValue) {
                      if (newValue != null) {
                        controller.selectedBankerName.value = controller
                            .bankerNameList
                            .firstWhere((e) => e.id.toString() == newValue)
                            .bankerName;

                        controller.bankName.value = newValue;
                        controller.getBankerDetailsName(newValue.toString());
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Banker Name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCommonDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?)? onChanged,
    required String iconPath,
    String? Function(String?)? validator,
    bool isEnabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hint, style: const TextStyle(color: AppColors.secondayColor)),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: value,
            items: items,
            onChanged: isEnabled ? onChanged : null,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,

              /// SAME PREFIX DESIGN ✅
              prefixIcon: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        iconPath,
                        color: themeController.primaryColor.value,
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 6),
                      VerticalDivider(
                        thickness: 1,
                        color: themeController.primaryColor.value,
                      ),
                    ],
                  ),
                ),
              ),

              labelStyle: const TextStyle(color: AppColors.secondayColor),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                  )),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: themeController.primaryColor.value,
                  width: 2,
                ),
              ),

              filled: true,
              fillColor: AppColors.backgroundColor,
            ),
            hint: Text(
              hint,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeleCallerDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TeleCaller',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'TeleCaller',
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/telecaller_call.svg',
                          height: 24,
                          width: 24,
                          color: themeController.primaryColor.value,
                        ),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: themeController.primaryColor.value,
                    )),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialTellecallerValue(),
              hint: const Text(
                'Select TeleCaller',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildTellecallerNameDropdownItems(),
              onChanged: null,
              //  controller.isEdit.value
              //     ? (newValue) {
              //         if (newValue != null) {
              //           controller.tellecallerId.value = newValue;
              //           controller.getTeamLeadById(controller.telecaller.value);
              //         }
              //       }
              //     : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Tellecaller';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status',
                style: TextStyle(color: AppColors.secondayColor)),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Status',
                prefixIcon: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/images/status.svg',
                          height: 24,
                          width: 24,
                          color: themeController.primaryColor.value,
                        ),
                        SizedBox(width: 5.w),
                        VerticalDivider(
                          thickness: 1,
                          color: themeController.primaryColor.value,
                        ),
                      ],
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.secondayColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: themeController.primaryColor.value,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.backgroundColor,
              ),
              value: _getInitialStatusValue(),
              hint: const Text(
                'Select Status',
                style: TextStyle(color: Colors.grey),
              ),
              items: _buildStatusDropdownItems(),
              onChanged: controller.isEdit.value
                  ? (newValue) {
                      if (newValue != null) {
                        final selected = controller.statuslist
                            .firstWhere((e) => e.id == newValue);

                        controller.selectedStatusName.value =
                            selected.dataEntryStatus;
                      }
                    }
                  : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Source';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // // Helper method to build dropdown items
  List<DropdownMenuItem<String>> _buildDsaDropdownItems() {
    for (final item in controller.dsaNameList) {
      print('ID: ${item.id}, Name: ${item.dsaName}');
    }
    return controller.dsaNameList.map((dsa) {
      return DropdownMenuItem<String>(
        value: dsa.id,
        child: Text(
          dsa.dsaName ?? '',
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildProductTypeDropdownItems() {
    return controller.producttypeList.map((product) {
      return DropdownMenuItem<String>(
        value: product.id,
        child: Text(
          product.name,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildDsaBankloginNameDropdownItems() {
    return controller.dsaBankList.map((dsaBank) {
      return DropdownMenuItem<String>(
        value: dsaBank.bankName,
        child: Text(
          dsaBank.bankName,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildCaseTypeDropdownItems() {
    return controller.caseType.map((type) {
      return DropdownMenuItem<String>(
        value: type,
        child: Text(
          type,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildBankerNameDropdownItems() {
    return controller.bankerNameList.map((bank) {
      return DropdownMenuItem<String>(
        value: bank.id,
        child: Text(
          bank.bankerName,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildTellecallerNameDropdownItems() {
    return controller.telecallerlist.map((tellecaller) {
      return DropdownMenuItem<String>(
        value: tellecaller.id,
        child: Text(
          tellecaller.name,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildStatusDropdownItems() {
    return controller.statuslist.map((status) {
      return DropdownMenuItem<String>(
        value: status.id,
        child: Text(
          status.dataEntryStatus,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  String? _getInitialProductTypeValue() {
    final existingSource = controller.producttypeList.firstWhereOrNull(
      (product) =>
          product.id.toLowerCase().trim() ==
          controller.selectedproductType.value.toLowerCase().trim(),
    );

    return existingSource?.id;
  }

  // Helper method to build dropdown items
  List<DropdownMenuItem<String>> _buildSourceDropdownItems() {
    return controller.sourcingList.map((source) {
      return DropdownMenuItem<String>(
        value: source.id,
        child: Text(
          source.sourcingTitle ?? '',
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();
  }

  String? _getInitialloginBankValue() {
    final existing = controller.dsaBankList.firstWhereOrNull((e) =>
        (e.bankName).toLowerCase().trim() ==
        controller.selectedBankName.value.toLowerCase().trim());
    return existing?.bankName;
  }

  String? _getInitialBankerValue() {
    final existing = controller.bankerNameList.firstWhereOrNull((e) =>
        e.bankerName.toLowerCase().trim() ==
        controller.selectedBankerName.value.toLowerCase().trim());
    return existing?.id;
  }

  String? _getInitialTellecallerValue() {
    final existing = controller.telecallerlist.firstWhereOrNull((e) =>
        (e.id).toLowerCase().trim() ==
        controller.selectTelecallerName.value.toLowerCase().trim());
    return existing?.id;
  }

  String? _getInitialStatusValue() {
    final existing = controller.statuslist.firstWhereOrNull((e) =>
        (e.dataEntryStatus).toLowerCase().trim() ==
        controller.selectedStatus.value.toLowerCase().trim());
    return existing?.id;
  }

  String? _getInitialSourceValue() {
    final existing = controller.sourcingList.firstWhereOrNull((e) =>
        (e.id)?.toLowerCase().trim() ==
        controller.selectedSource.value.toLowerCase().trim());
    return existing?.id;
  }

  String? _getInitialDsaValue() {
    final existing = controller.dsaNameList.firstWhereOrNull((e) =>
        (e.id ?? '').toLowerCase().trim() ==
        controller.dsaName.value.toLowerCase().trim());
    return existing?.id;
  }

  String? _getInitialCaseTypeValue() {
    final existing = controller.caseType.firstWhereOrNull(
      (e) =>
          e.toLowerCase().trim() ==
          controller.selectedCaseType.value.toLowerCase().trim(),
    );
    return existing;
  }

  Widget titileWithIcon({
    required String title,
    required String iconPath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: themeController.primaryColor.value,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// Icon Box
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.appBarTextColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              iconPath,
              height: 18,
              width: 18,
              color: themeController.primaryColor.value,
            ),
          ),

          SizedBox(width: 10.w),

          /// Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appBarTextColor),
            ),
          ),

          /// Optional small divider line (modern touch)
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              color: themeController.primaryColor.value,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
