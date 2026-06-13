import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/controllers/dailer_controller.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/controllers/login_request_controller.dart';
import 'package:smart_solutions/controllers/remark_status_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import 'package:smart_solutions/widget/text_style.dart';
import '../constants/services.dart';

// ignore: must_be_immutable
class FollowBackForm extends StatefulWidget {
  final bool isRefresh;
  final bool isgetData;
  const FollowBackForm(
      {Key? key, this.isRefresh = true, this.isgetData = false})
      : super(key: key);

  @override
  State<FollowBackForm> createState() => _FollowBackFormState();
}

class _FollowBackFormState extends State<FollowBackForm> {
  final FollowBackFormController _formController =
      Get.find<FollowBackFormController>();

  final RemarkStatusController _remarkController =
      Get.put(RemarkStatusController());

  final LoginRequestController _loginRequestController =
      Get.find<LoginRequestController>();

  final _formKey = GlobalKey<FormState>();

  var selectedDate = DateTime.now().obs;

  final ThemeController themeController = Get.find<ThemeController>();
  final DialerController _dialerController = Get.find<DialerController>();

  int backPressCounter = 0;

  bool canPop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
    });
  }

  Future<void> _initialLoad() async {
    await _dialerController.fetchLastCallInfoIfNeeded(widget.isgetData);
    await _formController.loadData(widget.isRefresh);
  }

  @override
  void dispose() {
    _formController.searchController.value;
    super.dispose();
  }

  bool get isPageLoading =>
      _formController.isBankAndStatusLoading.value ||
      _dialerController.isCallInfoLoading.value;

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: canPop,
        onPopInvoked: (didPop) {
          if (didPop) return;
          final NavigatorState navigator = Navigator.of(context);
          backPressCounter++;
          if (backPressCounter == 1) {
            Get.snackbar('Restricted', "Press back button once again to close",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.shade100);
            canPop = true;
            Future.delayed(const Duration(seconds: 2), () {
              backPressCounter = 0; // Reset counter after 2 seconds
              canPop = false;
            });
          } else {
            // ALWAYS clear data when going back
            _dialerController.salary.value = '';
            _formController.bankName.value = '';
            _formController.mobile.value = '';
            _dialerController.elapsedTimeInSeconds.value = 0;
            _dialerController.customerName.value = '';
            _dialerController.customerLoan.value = '';
            _dialerController.followup_id.value = '';

            // ADD THESE: Clear remark status and data type
            _formController.remarkStatus.value = '';
            _formController.dataType.value = '';
            _formController.remark.value = '';

            // Also clear controllers if they exist
            _formController.customerNumberController.clear();
            _dialerController.customerNameController.clear();

            // Clear callback status
            _remarkController.isCallback.value = false;
            _formController.contacted.value = 'No';

            navigator.pop();
          }
          logOutput("$canPop and $backPressCounter");
        },
        child: CommonScaffold(
          showBack: true,
          title: 'Follow Up Add',
          body: Stack(children: [
            Container(
              color: AppColors.whiteColor,
              child: RefreshIndicator(
                  onRefresh: () async {
                    // final Map<String, dynamic> preservedValues = {
                    //   'customerName': _dialerController.customerName.value,
                    //   'mobile': _formController.mobile.value,
                    //   'salary': _dialerController.salary.value,
                    //   'customerLoan': _dialerController.customerLoan.value,
                    //   'bankName': _formController.bankName.value,
                    //   'dataType': _formController.dataType.value,
                    //   'contacted': _formController.contacted.value,
                    //   'remarkStatus': _formController.remarkStatus.value,
                    //   'remark': _formController.remark.value,
                    //   'followupDate': _formController.followupDate.value,
                    // };
                    final preservedContactedStatus =
                        _formController.contacted.value;
                    final preservedRemarkStatus =
                        _formController.remarkStatus.value;
                    await Future.wait([
                      _formController.loadData(widget.isRefresh),
                      _loginRequestController.getSourcingList(),
                      _remarkController.fetchRemarkStatus(
                          preservedContactedStatus == 'Yes' ? '1' : '2'),
                    ]);

                    _dialerController.handleCallEnd();

                    if (preservedRemarkStatus.isNotEmpty) {
                      _formController.remarkStatus.value =
                          preservedRemarkStatus;

                      final selectedStatus = _remarkController.remarkStatusList
                          .firstWhereOrNull(
                              (status) => status.id == preservedRemarkStatus);

                      if (selectedStatus?.title
                              ?.toLowerCase()
                              .contains('callback') ==
                          true) {
                        _remarkController.isCallback.value = true;
                      } else {
                        _remarkController.isCallback.value = false;
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        key: const ValueKey(
                            'follow_up_form_list'), // Use ValueKey instead
                        children: [
                          // _buildDatePicker(context, false),
                          // SizedBox(height: 16.h),
                          // loan amount field
                          SizedBox(height: 10.h),
                          _buildTextField(
                            label: 'Customer Name',
                            prefixIcon: SvgPicture.asset(
                              'assets/images/user.svg',
                              height: 24,
                              width: 24,
                              color: themeController.primaryColor.value,
                            ),
                            controller:
                                _dialerController.customerNameController,
                            // onChanged: (value) =>
                            //     _dialerController.customerName.value = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter customer name';
                              }
                              // else if (_dialerController
                              //     .customerName.value.isNotEmpty) {
                              //   _dialerController.customerName.value =
                              //       _formController.customerName.value;
                              //   // _formController.customerName.value =
                              //   //     _dialerController.customerName.value;
                              // }
                              return null;
                            },
                          ),

                          SizedBox(height: 16.h),

                          _buildMobileField(
                            label: 'Enter Mobile Number',
                            controller:
                                _formController.customerNumberController,
                            inputType: TextInputType.number,
                            prefixIcon: SvgPicture.asset(
                              'assets/images/phone.svg',
                              height: 24,
                              width: 24,
                              color: themeController.primaryColor.value,
                            ),
                            onChanged: (value) {
                              _formController.mobile.value =
                                  value; // ✅ Proper update
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter mobile number';
                              } else if (value.length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 16.h),

                          // _buildTextField(
                          //     isRead: _dialerController.salary.value.isEmpty
                          //         ? false
                          //         : true,
                          //     inputType: TextInputType.number,
                          //     label: 'Salary',
                          //     prefixIcon: SvgPicture.asset(
                          //       'assets/images/rupees.svg',
                          //       height: 24,
                          //       width: 24,
                          //     ),
                          //     value: (_dialerController.salary.value.isEmpty ||
                          //             _dialerController.salary.value == "0")
                          //         ? ""
                          //         : CurrencyUtils.formatAmount(
                          //             _dialerController.salary.value),
                          //     onChanged: (value) =>
                          //         _dialerController.salary.value = value,
                          //     validator: null),

                          // SizedBox(height: 16.h),

                          // _buildTextField(
                          //     isRead: _dialerController.customerLoan.value.isEmpty
                          //         ? false
                          //         : true,
                          //     label: 'Loan Amount',
                          //     inputType: TextInputType.number,
                          //     prefixIcon: SvgPicture.asset(
                          //       'assets/images/rupees.svg',
                          //       height: 24,
                          //       width: 24,
                          //     ),
                          //     value: CurrencyUtils.formatIndianCurrency(
                          //         _dialerController.customerLoan.value),
                          //     onChanged: (value) =>
                          //         _dialerController.customerLoan.value = value,
                          //     validator: null),

                          Row(
                            children: [
                              // ------- Salary Field -------
                              Expanded(
                                child: _buildTextField(
                                  // isRead:
                                  //     _dialerController.salary.value.isNotEmpty,
                                  inputType: TextInputType.number,
                                  label: 'Salary',
                                  prefixIcon: SvgPicture.asset(
                                    'assets/images/rupees.svg',
                                    height: 24,
                                    width: 24,
                                    color: themeController.primaryColor.value,
                                  ),
                                  value: (_dialerController
                                              .salary.value.isEmpty ||
                                          _dialerController.salary.value == "0")
                                      ? ""
                                      : CurrencyUtils.formatAmount(
                                          _dialerController.salary.value),
                                  onChanged: (value) =>
                                      _dialerController.salary.value = value,
                                  validator: null,
                                ),
                              ),

                              const SizedBox(width: 12), // space between fields

                              // ------- Loan Amount Field -------
                              Expanded(
                                child: _buildTextField(
                                  // isRead: _dialerController
                                  //     .customerLoan.value.isNotEmpty,
                                  label: 'Loan Amount',
                                  inputType: TextInputType.number,
                                  prefixIcon: SvgPicture.asset(
                                      'assets/images/loan_amount.svg',
                                      height: 28,
                                      width: 28,
                                      color:
                                          themeController.primaryColor.value),
                                  value: (_dialerController
                                              .customerLoan.value.isEmpty ||
                                          _dialerController
                                                  .customerLoan.value ==
                                              "0")
                                      ? ""
                                      : CurrencyUtils.formatIndianCurrency(
                                          _dialerController.customerLoan.value),
                                  onChanged: (value) => _dialerController
                                      .customerLoan.value = value,
                                  validator: null,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Bank Name Field
                          _buildAllBankNamesDropdown(),
                          SizedBox(height: 16.h),

                          _buildDataSourcingDropdown(),

                          SizedBox(height: 16.h),

                          _buildContactStatusRadio(),

                          SizedBox(height: 16.h),

                          // Remark Status Dropdown
                          _buildRemarkStatusDropdown(),
                          SizedBox(height: 16.h),

                          Obx(() => _remarkController.isCallback.value
                              ? Column(
                                  children: [
                                    _buildDatePicker(context, true),
                                    SizedBox(height: 16.h),
                                  ],
                                )
                              : const SizedBox.shrink()),

                          // Remark Field
                          _buildTextField(
                              label: 'Remark',
                              value: _formController.remark.value,
                              maxLines: 3,
                              onChanged: (value) =>
                                  _formController.remark.value = value,
                              validator: null),
                          SizedBox(height: 16.h),

                          // Submit Button
                          Padding(
                            padding: EdgeInsetsGeometry.only(bottom: 20.h),
                            child: _buildSubmitButton(),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),

            /// 🔒 Block interaction + show loader
            Obx(() => isPageLoading
                ? Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: Colors.white.withOpacity(0.6),
                        child: const Center(child: LoadingPage()),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ]),
        ));
  }

  Widget _buildTextField({
    required String label,
    String? value,
    TextEditingController? controller,
    bool? isRead,
    ValueChanged<String>? onChanged,
    required String? Function(String?)? validator,
    Widget? prefixIcon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
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
          const SizedBox(width: 5),
          SizedBox(
            height: 50,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: themeController.primaryColor.value,
            ),
          ),
          const SizedBox(width: 5),
        ],
      );
    }

    return TextFormField(
      keyboardType: inputType,
      maxLines: maxLines,
      readOnly: isRead ?? false,
      controller: controller,
      // initialValue:
      //     controller == null && (value?.isNotEmpty ?? false) ? value : null,
      decoration: InputDecoration(
        hintText: label,
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        hintStyle: AppTextStyle.hintText,
        prefixIcon: decoratedPrefixIcon,
        labelStyle: AppTextStyle.textStyle,

        // 🔹 Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0.r),
        ),

        // 🔹 Enabled border (theme color)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0.r),
          borderSide: BorderSide(
            color: themeController.primaryColor.value,
            width: 1,
          ),
        ),

        // 🔹 Focused border (thicker)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0.r),
          borderSide: BorderSide(
            color: themeController.primaryColor.value,
            width: 2,
          ),
        ),

        filled: true,
        fillColor: AppColors.whiteColor,
      ),
      style: const TextStyle(
        color: Colors.black,
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildMobileField({
    String? value,
    required String label,
    TextEditingController? controller,
    required ValueChanged<String> onChanged,
    required String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
    Widget? prefixIcon,
    int maxLines = 1,
  }) {
    Widget? decoratedPrefixIcon;

    if (prefixIcon != null) {
      decoratedPrefixIcon = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 5.0),
            child: prefixIcon,
          ),
          // const SizedBox(width: 5),
          SizedBox(
            height: 50,
            child: Obx(() => VerticalDivider(
                  thickness: 1,
                  color: themeController.primaryColor.value,
                )),
          ),
        ],
      );
    }

    return Obx(() => TextFormField(
          initialValue:
              controller == null && (value?.isNotEmpty ?? false) ? value : null,
          keyboardType: inputType,
          controller: controller,
          maxLines: maxLines,
          maxLength: 10,
          readOnly: false,
          decoration: InputDecoration(
            counterText: '',
            hintText: label,
            hintStyle: AppTextStyle.hintText,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            prefixIcon: decoratedPrefixIcon,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(
                color: themeController.primaryColor.value,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(
                color: themeController.primaryColor.value,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.whiteColor,
          ),
          style: const TextStyle(
            color: Colors.black,
          ),
          onChanged: onChanged,
          validator: validator,
        ));
  }

  // Widget _buildDatePicker(BuildContext context, bool chooseDate) {
  Widget _buildDatePicker(BuildContext context, bool chooseDate) {
    // Initialize selectedDate as null
    final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

    return InkWell(
      onTap: () async {
        if (chooseDate) {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );

          if (picked != null) {
            selectedDate.value = picked;
            _formController.followupDate.value = picked;
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(10.0.r),
          color: AppColors.backgroundColor,
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 16.h),
            SvgPicture.asset(
              'assets/images/calendar.svg',
              height: 24,
              width: 24,
            ),
            SizedBox(width: 12.w),
            const SizedBox(
              width: 5,
              height: 50,
              child: VerticalDivider(
                width: 1,

                // width: 1,
                thickness: 1,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            chooseDate
                ? Obx(() => Text(
                      '${'Follow Up Date'}: ${selectedDate.value != null ? DateFormat('dd-MM-yyyy').format(selectedDate.value!) : '-'}',
                      style: const TextStyle(color: AppColors.primaryColor),
                    ))
                : Text(
                    '${'Date'}: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactStatusRadio() {
    return Obx(() {
      final bool isRestricted = _formController.isDurationAvailable.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacted Status',
            style: TextStyle(
              color: themeController.primaryColor.value,
              fontSize: 16.sp,
            ),
          ),
          Row(
            children: [
              Radio<String>(
                  value: 'Yes',
                  groupValue: _formController.contacted.value,
                  onChanged: isRestricted
                      ? (value) {
                          _formController.onContactedChanged(
                              value: value!,
                              remarkController: _remarkController);
                        }
                      : null,
                  activeColor: themeController.primaryColor.value),
              const Text(
                'Yes',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
              SizedBox(width: 20.w),
              Radio<String>(
                value: 'No',
                groupValue: _formController.contacted.value,
                onChanged: isRestricted
                    ? (value) {
                        _formController.onContactedChanged(
                          value: value!,
                          remarkController: _remarkController,
                        );
                      }
                    : null, // 🔒 disabled

                activeColor: themeController.primaryColor.value,
              ),
              const Text(
                'No',
                style: TextStyle(
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
            // )),
          )
        ],
      );
    });
  }

  Widget _buildRemarkStatusDropdown() {
    return Obx(() {
      // 🔹 Loading state (theme-aware)
      if (_remarkController.remarkStatusList.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: themeController.primaryColor.value,
            ),
            borderRadius: BorderRadius.circular(10.0.r),
          ),
          child: Center(
            child: Text(
              'Loading remark status...',
              style: TextStyle(
                color: themeController.primaryColor.value,
              ),
            ),
          ),
        );
      }

      // 🔹 Selected value logic (UNCHANGED)
      String? currentValue;
      if (_formController.remarkStatus.value.isNotEmpty) {
        final existsInList = _remarkController.remarkStatusList
            .any((status) => status.id == _formController.remarkStatus.value);

        if (existsInList) {
          currentValue = _formController.remarkStatus.value;
        }
      }

      return DropdownButtonFormField<String>(
        style: TextStyle(
          color: themeController.primaryColor.value,
        ),

        decoration: InputDecoration(
          hintText: 'Remark Status',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          hintStyle: AppTextStyle.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0.r),
            borderSide: BorderSide(
              color: themeController.primaryColor.value,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0.r),
            borderSide: BorderSide(
              color: themeController.primaryColor.value,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppColors.whiteColor,
        ),

        value: currentValue,

        items: [
          // 🔹 Placeholder (UNCHANGED)
          DropdownMenuItem<String>(
            value: '',
            enabled: false,
            child: Text(
              'Select remark status',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // 🔹 API list items
          ..._remarkController.remarkStatusList.map((status) {
            return DropdownMenuItem<String>(
              value: status.id,
              child: Text(
                status.title ?? 'Select remark status',
                style: const TextStyle(color: AppColors.blackColor),
              ),
            );
          }).toList(),
        ],

        // 🔹 onChanged logic (UNCHANGED)
        onChanged: (newValue) {
          if (newValue == null || newValue.isEmpty) return;

          _formController.remarkStatus.value = newValue;

          var selectedStatus = _remarkController.remarkStatusList
              .firstWhereOrNull((status) => status.id == newValue);

          if (selectedStatus?.title?.toLowerCase().contains('callback') ==
              true) {
            _remarkController.isCallback.value = true;
          } else {
            _remarkController.isCallback.value = false;
          }
        },

        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a remark status';
          }
          return null;
        },
      );
    });
  }

  Widget _buildAllBankNamesDropdown() {
    return Obx(
      () =>
          // _formController.isLoading.value
          //     ? const Center(child: LoadingPage())
          //     :
          SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          isDense: true,
          style: AppTextStyle.hintText,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 8),

            prefixIcon: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset('assets/images/bank.svg',
                        height: 24,
                        width: 24,
                        color: themeController.primaryColor.value),
                    VerticalDivider(
                        thickness: 1,
                        color: themeController.primaryColor.value),
                  ],
                ),
              ),
            ),
            hintText: "Select Bank",
            hintStyle: AppTextStyle.hintText,

            // labelStyle: AppTextStyle.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(color: themeController.primaryColor.value),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(
                  color: themeController.primaryColor.value, width: 2),
            ),
            filled: true,
            fillColor: AppColors.whiteColor,
          ),

          value:
              _getInitialBankValue(), // Use the method to get the initial value
          items: _formController.allBankNamesList.map((bank) {
            return DropdownMenuItem<String>(
              value: bank.bankName,
              child: Text(bank.bankName ?? 'Select bank',
                  style: const TextStyle(color: AppColors.blackColor)),
            );
          }).toList(),
          onChanged: (newValue) {
            logOutput("bank is $newValue");
            _formController.bankName.value = newValue ?? 'Select bank';
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

  Widget _buildDataSourcingDropdown() {
    return Obx(() {
      final selectedValue = _formController.dataType.value.isNotEmpty
          ? _formController.dataType.value
          : null;

      final selectedItemExists = selectedValue != null &&
          _loginRequestController.sourcingList
              .any((item) => item.id == selectedValue);

      final List<DropdownMenuItem<String>> dropdownItems = [];

      if (selectedValue != null && !selectedItemExists) {
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: selectedValue,
            child: Text(
              'Selected: $selectedValue',
              style: TextStyle(
                color: themeController.primaryColor.value,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      }

      dropdownItems.addAll(_loginRequestController.sourcingList.map((source) {
        return DropdownMenuItem<String>(
          value: source.id,
          child: Text(source.sourcingTitle ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.blackColor)),
        );
      }).toList());

      return SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          isDense: true,
          style: const TextStyle(
            color: AppColors.blackColor,
          ),
          padding: EdgeInsets.zero,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            prefixIcon: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/data_type.svg',
                      height: 24,
                      width: 24,
                      color: themeController.primaryColor.value,
                    ),
                    VerticalDivider(
                      thickness: 1,
                      color: themeController.primaryColor.value,
                    ),
                  ],
                ),
              ),
            ),
            hintText: "Select Source",
            hintStyle: AppTextStyle.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(
                color: themeController.primaryColor.value,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(
                color: themeController.primaryColor.value,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.whiteColor,
          ),
          value: selectedValue,
          items: dropdownItems,
          onChanged: (newValue) {
            _formController.dataType.value = newValue ?? '';
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a source';
            }
            return null;
          },
        ),
      );
    });
  }

  String? _getInitialBankValue() {
    // Check if the controller's bankName is in the available bank list
    if (_formController.bankName.value == 'Select bank') {
      return null; // Keep it null to show the placeholder
    }
    final existingBank = _formController.allBankNamesList.firstWhereOrNull(
        (bank) => bank.bankName == _formController.bankName.value);
    return existingBank?.bankName;
  }

  // Helper method to get the initial bank value
  String? _getInitialSourceValue() {
    // If formController has a dataType value, use it
    if (_formController.dataType.value.isNotEmpty) {
      // First check if this value exists in the current sourcing list
      final existsInList = _loginRequestController.sourcingList.any(
        (source) => source.id == _formController.dataType.value,
      );

      if (existsInList) {
        return _formController.dataType.value;
      }
      // If not found, keep the value anyway - it will show as selected
      // even if not in the list (better than losing it)
      return _formController.dataType.value;
    }

    // Otherwise, fall back to login controller's sourceId
    final existingSource =
        _loginRequestController.sourcingList.firstWhereOrNull(
      (source) =>
          source.sourcingTitle?.toLowerCase().trim() ==
          _loginRequestController.sourceId.value.toLowerCase().trim(),
    );

    return existingSource?.id;
  }

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton(
          onPressed: _formController.isFormSubmitted.value
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await _formController.submitFollowUp();

                    if (!mounted) return; // 🔥 important in StatefulWidget

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Follow up saved successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pop(context); // or Get.back()
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeController.primaryColor.value,
            padding: EdgeInsets.symmetric(vertical: 15.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0.r),
            ),
          ),
          child: _formController.isLoading.value
              ? const LoadingPage()
              : Text(
                  'Submit',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ));
  }

  // Helper method to build dropdown items
  List<DropdownMenuItem<String>> _buildSourceDropdownItems() {
    return _loginRequestController.sourcingList.map((source) {
      return DropdownMenuItem<String>(
          value: source.id,
          child: Text(
            source.sourcingTitle ?? '',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textStyle,
          ));
    }).toList();
  }
}

// Constants class for colors
class AppColors {
//  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColor = Color(0xFF356EFF);
  static const Color secondaryColor = Color(0xFF5E5E5E);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color ongoindCallColor = Color.fromARGB(255, 245, 43, 43);
  static const Color greyColor = Color(0xFFF1F1F1);
  static const Color greenColor = Color(0xFF00AB1A);
  static const Color blackColor = Color.fromARGB(255, 23, 23, 23);
  static const Color whiteColor = Colors.white;
}
