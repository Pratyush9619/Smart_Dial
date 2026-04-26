import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/components/widgets/DailerScreenWidget/KeypadRowWidget.dart';
import 'package:smart_solutions/controllers/dailer_controller.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/views/followBackForm.dart';
import 'package:smart_solutions/widget/common_rows_card.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/header_title.dart';
import 'package:smart_solutions/widget/string.dart';
import 'package:smart_solutions/widget/text_style.dart';
import 'package:smart_solutions/theme/app_theme.dart' as themeColor;

class DialerScreen extends StatefulWidget {
  const DialerScreen({Key? key}) : super(key: key);

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  // final DialerController dialerController = Get.put(DialerController());

  final DialerController dialerController = Get.find<DialerController>();
  final FollowBackFormController _formController =
      Get.find<FollowBackFormController>();

  int callsToBeHeld = 5;
  final ThemeController themeController = Get.find<ThemeController>();

  // @override
  // void initState() {
  //   super.initState();
  //   _formController.loadData(false);
  // }

  @override
  void dispose() {
    dialerController.setPhoneNumberOnce('');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/user_plus.svg',
          ),
          onPressed: () {
            Get.to(() => const FollowBackForm(isgetData: false));
            // handle click
          },
        )
      ],
      title: 'Dialer',
      showBack: false,
      isDrawer: true,
      body: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                bool isActive = dialerController.isManual.value;
                return Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // mainAxisSize: MainAxisSize
                    //     .max, // Ensures the row only takes the necessary width
                    children: [
                      HeaderTitle(
                          title: dialerTitle, style: AppTextStyle.headerTitle),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isActive ? "Manual Mode" : "Auto Mode",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.h,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              activeColor: themeController.primaryColor.value,
                              inactiveTrackColor: Colors.grey.shade100,
                              value: isActive,
                              onChanged: dialerController.isCallOngoing.value
                                  ? null
                                  : (value) async {
                                      if (value) {
                                        dialerController.phoneNumber.value = '';
                                        _removeNumber();
                                      }
                                      dialerController.isManual.value = value;
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              Obx(
                () => dialerController.isCallOngoing.value
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.grey.shade300),
                          child: Text(
                            dialerController.formatElapsedTime(
                                dialerController.elapsedTimeInSeconds.value),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Obx(() => Container(
              //       alignment: AlignmentDirectional.topStart,
              //       padding: const EdgeInsets.symmetric(horizontal: 10),
              //       child: Text(
              //         dialerController.customerName.value,
              //         style: TextStyle(
              //           fontSize: 20.sp,
              //           color: AppColors.secondaryColor,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     )),

              // Obx(() => Container(
              //       alignment: AlignmentDirectional.topStart,
              //       padding: const EdgeInsets.symmetric(horizontal: 10),
              //       child: Text(
              //         dialerController
              //             .formatCurrency(dialerController.customerLoan.value),
              //         style: TextStyle(
              //           fontSize: 20.sp,
              //           color: AppColors.secondaryColor,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     )),

              SizedBox(height: 25.h),
              Obx(() {
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Center(
                        child: TextField(
                          textAlign: TextAlign.center,
                          readOnly: true,
                          maxLength: 10,
                          enableInteractiveSelection:
                              true, // ✅ enables copy/paste
                          showCursor: true, // optional (clean UI)

                          controller: TextEditingController(
                              text:
                                  // dialerController.phoneNumber.value.isEmpty
                                  //     ? 'Enter number'
                                  //     :
                                  dialerController.phoneNumber.value),
                          onChanged: (value) {
                            dialerController.phoneNumber.value = value;
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none, // looks like plain Text
                            counterText: '',
                            hintText: "Enter number",
                            hintStyle: TextStyle(
                              fontSize: 20.sp,
                              color: AppColors.secondaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          style: TextStyle(
                            fontSize: 20.sp,
                            color: AppColors.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (dialerController.customerName.value.isNotEmpty)
                      Container(
                        height: 40,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonRows().buildSingleRowNoExpand(
                              'assets/images/user_circle.svg',
                              dialerController.customerName.value,
                              themeController.primaryColor.value,
                            ),
                            Text(
                              CurrencyUtils.formatIndianCurrency(
                                ' ${dialerController.customerLoan.value}',
                              ),
                              style: AppTextStyle.headerTitle,
                            ),
                          ],
                        ),
                      ),

                    // dialerController.customerName.isNotEmpty
                    //     ? Obx(() {
                    //         if (dialerController.customerName.value.isEmpty) {
                    //           return const SizedBox.shrink();
                    //         }

                    //         return Container(
                    //           height: 40,
                    //           width: double.infinity,
                    //           // color: themeColor.AppColors.diallerContainerColor,
                    //           padding:
                    //               const EdgeInsets.symmetric(horizontal: 8),
                    //           child: Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               CommonRows().buildSingleRowNoExpand(
                    //                   'assets/images/user_circle.svg',
                    //                   dialerController.customerName.value),
                    //               Text(
                    //                   CurrencyUtils.formatIndianCurrency(
                    //                       dialerController.customerLoan.value),
                    //                   style: AppTextStyle.headerTitle),
                    //             ],
                    //           ),
                    //         );
                    //       })
                    //     : const SizedBox.shrink()

                    //  const Divider(color: AppColors.secondaryColor)
                  ],
                );

                // Container(
                //   height: 50.h,
                //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                //   decoration: BoxDecoration(
                //     color: AppColors.backgroundColor,
                //     borderRadius: BorderRadius.circular(12.r),
                //     border: Border.all(
                //         color: AppColors.primaryColor.withOpacity(0.2)),
                //   ),
                //   child: Center(
                //     child:
                //         // TextField(
                //         //   inputFormatters: [],
                //         //   maxLength: 10,
                //         //   readOnly: true,
                //         //   controller: TextEditingController()
                //         //     ..text = dialerController.phoneNumber.value,
                //         //   onChanged: (value) {
                //         //     // dialerController.phoneNumber.value = value;
                //         //     if (value.length <= 10) {
                //         //       dialerController.phoneNumber.value = value;
                //         //     }
                //         //   },
                //         //   style: TextStyle(
                //         //     fontSize: 20.sp,
                //         //     color: AppColors.secondaryColor,
                //         //     fontWeight: FontWeight.bold,
                //         //   ),
                //         //   decoration: InputDecoration(
                //         //     counterText: '',
                //         //     border: InputBorder.none,
                //         //     hintText: 'Enter number',
                //         //     hintStyle: TextStyle(
                //         //       fontSize: 20.sp,
                //         //       color: AppColors.secondaryColor,
                //         //       fontWeight: FontWeight.bold,
                //         //     ),
                //         //   ),
                //         // ),

                //         Text(
                //       dialerController.phoneNumber.value.isEmpty
                //           ? 'Enter number'
                //           : dialerController.phoneNumber.value,
                //       style: TextStyle(
                //         fontSize: 20.sp,
                //         color: AppColors.secondaryColor,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // );
              }),

              SizedBox(height: 10.h),

              // Keypad
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: AspectRatio(
                  aspectRatio: 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      KeypadRowWidget(
                        numbers: const ['1', '2', '3'],
                        subTexts: const ['', 'ABC', 'DEF'],
                        onDialButtonPressed: _addNumber,
                      ),
                      KeypadRowWidget(
                        numbers: const ['4', '5', '6'],
                        subTexts: const ['GHI', 'JKL', 'MNO'],
                        onDialButtonPressed: _addNumber,
                      ),
                      KeypadRowWidget(
                        numbers: const ['7', '8', '9'],
                        subTexts: const ['PQRS', 'TUV', 'WXYZ'],
                        onDialButtonPressed: _addNumber,
                      ),
                      KeypadRowWidget(
                        numbers: const ['*', '0', '#'],
                        subTexts: const [null, '+', null],
                        onDialButtonPressed: _addNumber,
                      ),
                    ],
                  ),
                ),
              ),

              // Call and delete buttons
              Container(
                margin:
                    EdgeInsets.symmetric(horizontal: 5.w), // Responsive margin
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Obx(() {
                        return dialerController.isManual.value
                            ? const SizedBox.shrink()
                            : _buildIconNextCallButton(
                                SvgPicture.asset(
                                  'assets/images/tellecaller.svg',
                                  color: themeController.primaryColor.value,
                                ),
                                dialerController.isManual.value
                                    ? null
                                    : dialerController.isLoading.value
                                        ? null
                                        : () async {
                                            dialerController.isCallOngoing.value
                                                ? Get.defaultDialog(
                                                    title: "End Call",
                                                    titleStyle: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            20), // Bold title for emphasis.
                                                    middleText:
                                                        "Want to end the call? End the call from the caller screen.", // Updated guiding message.
                                                    middleTextStyle:
                                                        const TextStyle(
                                                            color: Colors.black,
                                                            fontSize:
                                                                16), // Clear and readable middle text.
                                                    backgroundColor: Colors
                                                        .white, // Dialog background in white.
                                                    textConfirm:
                                                        "OK", // Single button labeled 'OK'.
                                                    confirmTextColor: Colors
                                                        .white, // Confirm button text in white.
                                                    buttonColor: Colors
                                                        .blue, // 'OK' button in blue for neutrality.
                                                    barrierDismissible:
                                                        false, // Prevent accidental dismiss by tapping outside.
                                                    onConfirm: () {
                                                      Get.back(); // Simply close the dialog.
                                                    },
                                                  )
                                                : await dialerController
                                                    .fetchNextPhoneNumber();
                                          },
                              );
                      }),
                    ),
                    SizedBox(width: 5.w), // spacing
                    Expanded(
                      child: Obx(() => _buildCallButton(
                            SvgPicture.asset(
                              'assets/images/call_icon.svg',
                            ),
                            dialerController.phoneNumber.isNotEmpty &&
                                    !dialerController.isCallOngoing.value
                                ? () {
                                    // if (dialerController.dialNumber.isEmpty) {
                                    //   dialerController.fetchNextPhoneNumber();
                                    // } else {
                                    //   dialerController
                                    //       .makePhoneCall(dialerController.dialNumber.value);
                                    // }
                                    dialerController.makePhoneCall(
                                        dialerController.phoneNumber.value);
                                    _formController.mobile.value =
                                        dialerController.phoneNumber.value;
                                  }
                                : null,
                          )),
                    ),
                    SizedBox(width: 5.w), // spacing
                    Expanded(
                      child: _buildIconButton(
                        "assets/images/dialer_back.svg",
                        AppColors.blackColor,
                        _removeNumber,
                      ),
                    ),
                  ],
                ),
              ),

              // Obx(() => dialerController.isManual.value
              //     ? const SizedBox.shrink()
              //     : Padding(
              //         padding:
              //             EdgeInsets.only(bottom: 0.h, left: 20.h, right: 20.h),
              //         child: SizedBox(
              //           width: double.infinity,
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor:
              //                   dialerController.isCallOngoing.value
              //                       ? AppColors.ongoindCallColor
              //                       : AppColors.primaryColor,
              //               foregroundColor: Colors.white,
              //               padding: EdgeInsets.symmetric(vertical: 16.h),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(12.r),
              //               ),
              //             ),
              //             onPressed: dialerController.isManual.value
              //                 ? null
              //                 : dialerController.isLoading.value
              //                     ? null
              //                     : () async {
              //                         dialerController.isCallOngoing.value
              //                             ? Get.defaultDialog(
              //                                 title: "End Call",
              //                                 titleStyle: const TextStyle(
              //                                     color: Colors.black,
              //                                     fontWeight: FontWeight.bold,
              //                                     fontSize:
              //                                         20), // Bold title for emphasis.
              //                                 middleText:
              //                                     "Want to end the call? End the call from the caller screen.", // Updated guiding message.
              //                                 middleTextStyle: const TextStyle(
              //                                     color: Colors.black,
              //                                     fontSize:
              //                                         16), // Clear and readable middle text.
              //                                 backgroundColor: Colors
              //                                     .white, // Dialog background in white.
              //                                 textConfirm:
              //                                     "OK", // Single button labeled 'OK'.
              //                                 confirmTextColor: Colors
              //                                     .white, // Confirm button text in white.
              //                                 buttonColor: Colors
              //                                     .blue, // 'OK' button in blue for neutrality.
              //                                 barrierDismissible:
              //                                     false, // Prevent accidental dismiss by tapping outside.
              //                                 onConfirm: () {
              //                                   Get.back(); // Simply close the dialog.
              //                                 },
              //                               )
              //                             : await dialerController
              //                                 .fetchNextPhoneNumber();
              //                       },

              //             child: dialerController.isLoading.value
              //                 ? const Text('Loading...')
              //                 : Text(
              //                     dialerController.isCallOngoing.value
              //                         ? "End Call"
              //                         : 'NEXT CALL',
              //                     style: TextStyle(
              //                         fontSize: 16.sp,
              //                         fontWeight: FontWeight.bold),
              //                   ),
              //           ),
              //         ),
              //       )),
            ]),
      ),
    );
  }

  Widget _buildIconButton(
      String svgPath, Color color, VoidCallback? onPressed) {
    return CircleAvatar(
      radius: 33,
      backgroundColor: AppColors.secondaryColor,
      child: Material(
        color: AppColors.greyColor,
        shape: const CircleBorder(),
        child: SizedBox(
          height: 64.h, // circle size
          width: 64,
          child: IconButton(
            onPressed: onPressed,
            icon: SvgPicture.asset(
              svgPath,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildIconNextCallButton(
  //     Widget icon, Color color, VoidCallback? onPressed) {
  //   return SizedBox(
  //     height: 82, // circle size
  //     width: 82,

  //     child: IconButton(
  //       icon: icon,
  //       iconSize: 30.r,
  //       onPressed: onPressed,
  //     ),
  //   );
  // }

  Widget _buildIconNextCallButton(Widget icon, VoidCallback? onPressed) {
    return Container(
      height: 70,
      width: 70,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: themeColor.AppColors.diallerBtnColor),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(41),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(Widget icon, VoidCallback? onPressed) {
    return SizedBox(
      height: 82, // circle size
      width: 82,
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }

  void _addNumber(String number) {
    if (dialerController.isManual.value) {
      // setState(() {
      // dialerController.phoneNumber.value = '';
      dialerController.phoneNumber.value += number;
      //  });
    }
  }

  void _removeNumber() {
    if (dialerController.dialNumber.isNotEmpty) {
      setState(() {
        dialerController.dialNumber.value = dialerController.dialNumber.value
            .substring(0, dialerController.dialNumber.value.length - 1);
      });
    } else {
      dialerController.customerLoan.value = '';
      dialerController.customerName.value = '';
    }

    if (dialerController.phoneNumber.isNotEmpty) {
      dialerController.phoneNumber.value = dialerController.phoneNumber.value
          .substring(0, dialerController.phoneNumber.value.length - 1);
    }
  }

  Future<bool?> _showDeactivationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Confirm Deactivation",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          content: Text(
            "Are you sure you want to deactivate manual dialing?",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.black87,
                ),
          ),
          actions: <Widget>[
            // Row containing the buttons
            Row(
              children: [
                // Cancel Button - Takes up 50% of the row
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(false); // Return false if user cancels
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10), // Reduced padding
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Reduced font size
                        overflow: TextOverflow
                            .ellipsis, // Prevent text from overflowing
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.h,
                ),
                // Deactivate Button - Takes up 50% of the row
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(true); // Return true if user confirms
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10), // Reduced padding
                    ),
                    child: const Text(
                      "Deactivate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Reduced font size
                        overflow: TextOverflow
                            .ellipsis, // Prevent text from overflowing
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
