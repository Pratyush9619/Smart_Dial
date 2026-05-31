import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';

import 'package:smart_solutions/controllers/login_request_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/views/data_entry_form.dart';
import 'package:smart_solutions/views/login_request_form.dart';
import 'package:smart_solutions/views/spacing_constants.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/common_title_card.dart';
import 'package:smart_solutions/widget/flutter_chiplist.dart';
import 'package:smart_solutions/widget/header_title.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import 'package:smart_solutions/widget/searchbarwithclear.dart';
import '../controllers/data_entry_controller.dart';
import '../widget/text_style.dart';

class LoginRequestScreen extends StatelessWidget {
  final String title;
  final bool isShowBack;
  final bool isDrawer;

  LoginRequestScreen(
      {super.key,
      required this.title,
      required this.isShowBack,
      required this.isDrawer});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final LoginRequestController controller =
        Get.find<LoginRequestController>();

    final ThemeController themeController = Get.find<ThemeController>();

    final bool istelecaller = StaticStoredData.roleName == 'telecaller';

    final DataController dataController = Get.find<DataController>();

    return CommonScaffold(
        title: title,
        showBack: isShowBack,
        isDrawer: isDrawer,
        actions: [
          istelecaller
              ? IconButton(
                  icon: SvgPicture.asset('assets/images/user_plus.svg'),
                  onPressed: () {
                    controller.isEdit.value = true;
                    controller.isNew.value = true;
                    Get.to(() => const LoginRequestForm());
                  },
                )
              : const SizedBox.shrink()
        ],
        key: _scaffoldKey,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: AppColors.backgroundColor,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HeaderTitle(title: title, style: AppTextStyle.headerTitle),
              SearchBarWithClear(
                  controller: controller.searchController,
                  onChanged: (value) => controller.filterLoginRequests(),
                  showDatePickerIcon: false,
                  onClear: () {
                    controller.clearFilters();
                    controller.filterLoginRequests();
                  }),
              kVerticalSpace(10),
              Obx(() {
                final filterList = controller.filters;

                return FilterChipList(
                  filters: filterList,
                  selectedIndex: controller.selectedFilter.value,
                  onSelected: controller.selectFilter,
                );
              }),
              kVerticalSpace(10),
            ]),
          ),
          Expanded(child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: LoadingPage());
            }
            if (controller.loginRequestList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_sim, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No data entries available',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
                onRefresh: () => controller.getLoginRequestList(),
                child: Obx(() => controller.isLoading.value
                    ? const Center(child: LoadingPage())
                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(8), // Add padding to the list
                        itemCount: controller.loginRequestList.length,
                        itemBuilder: (context, index) {
                          final data = controller.loginRequestList[index];
                          return CommonTitleCard(
                            leading: Obx(
                              () => SvgPicture.asset(
                                'assets/images/phone_call.svg',
                                color: themeController.primaryColor.value,
                              ),
                            ),
                            onLeadingTap: () {},
                            title: data.customerName,
                            subtitle: data.bankName ?? '',
                            status: data.title ?? '',
                            date: DateFormat('dd-MM-yyyy').format(
                                DateTime.parse(
                                    data.loginRequestDate.toString())),
                            mobNo: maskFirst6Digits(data.contactNumber),
                            statusColor:
                                (data.title ?? '').toLowerCase() != 'not doable'
                                    ? Colors.green.shade400
                                    : Colors.redAccent.shade200,
                            amount: CurrencyUtils.formatIndianCurrency(
                                data.loanAmount),
                            showEdit:
                                StaticStoredData.roleName != 'telecaller' &&
                                    StaticStoredData.roleName != 'teamleader',
                            showMoveToLogin:
                                StaticStoredData.roleName != 'telecaller' &&
                                    StaticStoredData.roleName != 'teamleader',

                            onMoveToLogin: () async {
                              final success = await dataController
                                  .fetchmoveToLoginData(data.id.toString());

                              if (!success) {
                                Get.dialog(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 🔴 Icon with background circle
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.redAccent,
                                              size: 40,
                                            ),
                                          ),

                                          const SizedBox(height: 16),

                                          // Title
                                          const Text(
                                            "Oops!",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                          // Message
                                          const Text(
                                            "Customer name not found.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),

                                          const SizedBox(height: 20),

                                          // Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                              ),
                                              onPressed: () async {
                                                await safeNavigateBack();
                                              },
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );
                                return;
                              }

                              Get.to(() => DataEntryForm(
                                    id: data.id,
                                    tellecallerId: data.telecallerId,
                                    dsaId: data.sourcing.toString(),
                                    bankerId: data.bankId.toString(),
                                    isMovetoLogin: true,
                                  ));
                            },
                            // onMoveToLogin: () {
                            //   //      dataController.customer_id.value = data.customerId ?? '';
                            //   Get.to(() => DataEntryForm(
                            //         id: data.id,
                            //         tellecallerId: data.telecallerId,
                            //         dsaId: data.sourcing.toString(),
                            //         bankerId: data.bankId.toString(),
                            //         isMovetoLogin: true,
                            //       ));
                            // },
                            onEdit: () async {
                              controller.currentId.value = data.id;
                              controller.customerName.value = data.customerName;
                              controller.contactNumber.value =
                                  data.contactNumber;
                              controller.loanAmount.value = data.loanAmount;
                              controller.selectedLoanStatus.value =
                                  ((data.loanStatus == null ||
                                          data.loanStatus!.isEmpty)
                                      ? "NA"
                                      : data.loanStatus)!;
                              controller.bankId.value = data.bankName ?? "";
                              controller.sendingBankId.value =
                                  data.bankId ?? "";
                              controller.commonRemark.value = data.commonRemark;
                              controller.sourceId.value = data.sourcing ?? "";
                              controller.telecallerId.value = data.telecallerId;

                              controller.getRemarks();
                              await Get.to(() => const LoginRequestForm());

                              controller.getLoginRequestList();
                            },
                            children: [
                              _buildDoubleRow(
                                iconLeft: Icons.headphones_outlined,
                                valueLeft: data.tellecallerName ?? '',
                                iconRight: Icons.person_2_outlined,
                                valueRight: data.tlName ?? '',
                              ),
                              // _buildDoubleRow(
                              //     iconLeft: 'assets/images/call.svg',
                              //     valueLeft:
                              //         maskFirst6Digits(data.contactNumber),
                              //     iconRight: 'assets/images/calendar.svg',
                              //     valueRight: DateFormat('dd-MM-yyyy').format(
                              //         DateTime.parse(
                              //             data.loginRequestDate.toString()))),
                              _buildSingleRow(
                                  'assets/images/message_dots_circle.svg',
                                  data.remark.isEmpty
                                      ? 'No remark'
                                      : data.remark),
                            ],
                          );
                        })));
          }))
        ]));
  }

  //  RefreshIndicator(
  //     onRefresh: () => controller.getLoginRequestList(),
  //     child: Obx(() => controller.isLoading.value
  //         ? const Center(
  //             child: LoadingPage(),
  //           )
  //         : ListView.builder(
  //             padding: const EdgeInsets.all(8), // Add padding to the list
  //             itemCount: controller.loginRequestList.length,
  //             itemBuilder: (context, index) {
  //               final request = controller.loginRequestList[index];
  //               return Container(
  //                   margin: const EdgeInsets.symmetric(
  //                       vertical: 5, horizontal: 4),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(5),
  //                     border: const Border(
  //                       left: BorderSide(
  //                         color: Color(0xFF356EFF), // Blue line
  //                         width: 3,
  //                       ),
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.2),
  //                         offset: const Offset(0, 4), // Only downward
  //                         blurRadius: 8, // Softness
  //                         spreadRadius: 0, // No spread
  //                       ),
  //                     ],
  //                   ),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(4.0),
  //                     child: ExpansionTile(
  //                       tilePadding:
  //                           const EdgeInsets.symmetric(horizontal: 5.0),
  //                       showTrailingIcon: false,

  //                       childrenPadding: const EdgeInsets.symmetric(
  //                           horizontal: 5, vertical: 5),
  //                       expandedCrossAxisAlignment:
  //                           CrossAxisAlignment.start,
  //                       initiallyExpanded: false,
  //                       shape: const RoundedRectangleBorder(
  //                         side: BorderSide(
  //                             color: Colors.transparent, width: 0),
  //                       ),
  //                       title: Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () {},
  //                             child: SvgPicture.asset(
  //                                 'assets/images/person.svg'),
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Column(
  //                             crossAxisAlignment:
  //                                 CrossAxisAlignment.start,
  //                             children: [
  //                               SizedBox(
  //                                 width: 200.w,
  //                                 child: Text(
  //                                   softWrap: true,
  //                                   request.customerName.toString(),
  //                                   style: const TextStyle(
  //                                       overflow: TextOverflow.ellipsis),
  //                                 ),
  //                               ),
  //                               Text(
  //                                   softWrap: true,
  //                                   style: const TextStyle(fontSize: 11),
  //                                   request.bankName.toString()),
  //                             ],
  //                           ),
  //                           const Spacer(),
  //                           Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: 10, vertical: 5),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.end,
  //                               children: [
  //                                 GestureDetector(
  //                                     onTap: () async {
  //                                       controller.currentId.value =
  //                                           request.id;
  //                                       controller.customerName.value =
  //                                           request.customerName;
  //                                       controller.contactNumber.value =
  //                                           request.contactNumber;
  //                                       controller.loanAmount.value =
  //                                           request.loanAmount;
  //                                       controller.loanStatus.value =
  //                                           ((request.loanStatus ==
  //                                                       null ||
  //                                                   request.loanStatus!
  //                                                       .isEmpty)
  //                                               ? "NA"
  //                                               : request.loanStatus)!;
  //                                       controller.bankId.value =
  //                                           request.bankName ?? "";
  //                                       controller.commonRemark.value =
  //                                           request.commonRemark;
  //                                       controller.sourceId.value =
  //                                           request.sourcingTitle ?? "";

  //                                       controller.getRemarks();
  //                                       await Get.to(
  //                                           () => LoginRequestForm());

  //                                       controller.getLoginRequestList();
  //                                     },
  //                                     child: SvgPicture.asset(
  //                                         'assets/images/edit.svg')),
  //                                 StaticStoredData.roleName !=
  //                                             'telecaller' &&
  //                                         StaticStoredData.roleName !=
  //                                             'teamleader'
  //                                     ? GestureDetector(
  //                                         onTap: () async {
  //                                           // dataEntryController.customerName
  //                                           //     .value = request.customerName;

  //                                           dataEntryController
  //                                                   .contactNumber.value =
  //                                               request.contactNumber;

  //                                           dataEntryController
  //                                                   .loanAmount.value =
  //                                               request.loanAmount;

  //                                           dataEntryController.Id.value =
  //                                               request.id;

  //                                           dataEntryController
  //                                                   .selectedSource
  //                                                   .value =
  //                                               request.sourcing
  //                                                   .toString();

  //                                           dataEntryController
  //                                                   .selectTelecallerName
  //                                                   .value =
  //                                               request.telecallerId;

  //                                           await Get.to(DataEntryForm(
  //                                               id: '',
  //                                               tellecallerId:
  //                                                   request.telecallerId,
  //                                               dsaId: request.sourcing,
  //                                               bankerId: ''));
  //                                         },
  //                                         child: Row(
  //                                           children: [
  //                                             SizedBox(
  //                                               width: 15.w,
  //                                             ),
  //                                             const Icon(Icons.login,
  //                                                 color: AppColors
  //                                                     .primaryColor),
  //                                           ],
  //                                         ))
  //                                     : const SizedBox.shrink()
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       subtitle: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 5, vertical: 5),
  //                         child: SizedBox(
  //                           width: double.infinity,
  //                           child: Row(
  //                             children: [
  //                               Container(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 8),
  //                                 decoration: BoxDecoration(
  //                                   color: (request.title ?? '')
  //                                               .toLowerCase() ==
  //                                           'not doable'
  //                                       ? Colors.redAccent.shade200
  //                                       : Colors.green.shade400,
  //                                   borderRadius:
  //                                       BorderRadius.circular(5),
  //                                 ),
  //                                 child: Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                       horizontal: 5, vertical: 1),
  //                                   child: Text(
  //                                       request.title!.isNotEmpty
  //                                           ? request.title.toString()
  //                                           : 'No status',
  //                                       style: const TextStyle(
  //                                           color: Colors.white
  //                                           //  (request.title ?? '')
  //                                           //             .toLowerCase() ==
  //                                           //         'not doable'
  //                                           //     ? Colors.green.shade700
  //                                           //     : Colors.orange.shade700,
  //                                           )),
  //                                 ),
  //                               ),
  //                               const Spacer(),
  //                               Row(
  //                                 children: [
  //                                   Text(
  //                                       CurrencyUtils
  //                                           .formatIndianCurrency(
  //                                               request.loanAmount),
  //                                       style: const TextStyle(
  //                                           color: Colors.black)),
  //                                   const Icon(Icons.expand_more)
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       // trailing: SizedBox(
  //                       //   width: 80.w,
  //                       //   child: Column(
  //                       //     crossAxisAlignment: CrossAxisAlignment.end,
  //                       //     mainAxisAlignment:
  //                       //         MainAxisAlignment.spaceBetween,
  //                       //     children: [
  //                       //       Row(
  //                       //         mainAxisAlignment: MainAxisAlignment.end,
  //                       //         children: [
  //                       //           GestureDetector(
  //                       //               onTap: () async {
  //                       //                 controller.currentId.value =
  //                       //                     request.id;
  //                       //                 controller.customerName.value =
  //                       //                     request.customerName;
  //                       //                 controller.contactNumber.value =
  //                       //                     request.contactNumber;
  //                       //                 controller.loanAmount.value =
  //                       //                     request.loanAmount;
  //                       //                 controller.loanStatus.value =
  //                       //                     ((request.loanStatus == null ||
  //                       //                             request.loanStatus!
  //                       //                                 .isEmpty)
  //                       //                         ? "NA"
  //                       //                         : request.loanStatus)!;
  //                       //                 controller.bankId.value =
  //                       //                     request.bankName ?? "";
  //                       //                 controller.commonRemark.value =
  //                       //                     request.commonRemark;
  //                       //                 controller.sourceId.value =
  //                       //                     request.sourcingTitle ?? "";

  //                       //                 controller.getRemarks();
  //                       //                 await Get.to(
  //                       //                     () => LoginRequestForm());

  //                       //                 controller.getLoginRequestList();
  //                       //               },
  //                       //               child: SvgPicture.asset(
  //                       //                   'assets/images/edit.svg')),
  //                       //           SizedBox(
  //                       //             width: 5.w,
  //                       //           ),
  //                       //           StaticStoredData.roleName !=
  //                       //                       'telecaller' &&
  //                       //                   StaticStoredData.roleName !=
  //                       //                       'teamleader'
  //                       //               ? GestureDetector(
  //                       //                   onTap: () async {
  //                       //                     // dataEntryController.customerName
  //                       //                     //     .value = request.customerName;

  //                       //                     dataEntryController
  //                       //                             .contactNumber.value =
  //                       //                         request.contactNumber;

  //                       //                     dataEntryController.loanAmount
  //                       //                         .value = request.loanAmount;

  //                       //                     dataEntryController.Id.value =
  //                       //                         request.id;

  //                       //                     dataEntryController
  //                       //                             .selectedSource.value =
  //                       //                         request.sourcing.toString();

  //                       //                     dataEntryController
  //                       //                             .selectTelecallerName
  //                       //                             .value =
  //                       //                         request.telecallerId;

  //                       //                     await Get.to(DataEntryForm(
  //                       //                         id: '',
  //                       //                         tellecallerId:
  //                       //                             request.telecallerId,
  //                       //                         dsaId: request.sourcing,
  //                       //                         bankerId: ''));
  //                       //                   },
  //                       //                   child: Icon(Icons.login,
  //                       //                       color: Colors.grey[700]))
  //                       //               : const SizedBox.shrink()
  //                       //         ],
  //                       //       ),
  //                       //     ],
  //                       //   ),
  //                       // ),

  //                       children: [
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 5.0, vertical: 8.0),
  //                           child: Column(
  //                             crossAxisAlignment:
  //                                 CrossAxisAlignment.start,
  //                             children: [
  //                               // StaticStoredData.roleName != 'telecaller'
  //                               //     ? _buildDoubleRow(
  //                               //         iconLeft: SvgPicture.asset(
  //                               //         'assets/images/tellecaller_call.svg'),
  //                               //         valueLeft: request. ?? '',
  //                               //         iconRight: Icons.verified_user,
  //                               //         valueRight: data.tlName ?? '')
  //                               //     : const SizedBox.shrink(),
  //                               _buildDoubleRow(
  //                                   iconLeft: SvgPicture.asset(
  //                                       'assets/images/grey_call_icon.svg'),
  //                                   valueLeft: maskFirst6Digits(
  //                                       request.contactNumber.toString()),
  //                                   iconRight: SvgPicture.asset(
  //                                       'assets/images/date_icon.svg'),
  //                                   valueRight: DateFormat('dd-MM-yyyy')
  //                                       .format(DateTime.parse(request
  //                                           .loginRequestDate
  //                                           .toString()))),

  //                               // _buildSingleRow(
  //                               //     Icons.comment,
  //                               //     request.commonRemark.isNotEmpty
  //                               //         ? request.commonRemark
  //                               //         : ' No common Remark Available'
  //                               //         ),

  //                               Obx(() => _buildSingleRow(
  //                                   SvgPicture.asset(
  //                                       'assets/images/comment-detail.svg'),
  //                                   (index <
  //                                               controller
  //                                                   .remarksList.length &&
  //                                           controller
  //                                                   .remarksList[index] !=
  //                                               null)
  //                                       ? controller.remarksList[index]
  //                                       : 'No remark'))

  //                               // Row(
  //                               //   mainAxisAlignment:
  //                               //       MainAxisAlignment.spaceBetween,
  //                               //   children: [
  //                               //     Text(
  //                               //       'Contact: ${request.contactNumber}',
  //                               //       style: TextStyle(color: Colors.grey[600]),
  //                               //     ),
  //                               //     const SizedBox(width: 4),
  //                               //     Text(
  //                               //       'Loan Status: ${request.title}',
  //                               //       style: TextStyle(color: Colors.grey[600]),
  //                               //     ),
  //                               //   ],
  //                               // )

  //                               // ElevatedButton.icon(
  //                               //   onPressed: () async {
  //                               // controller.currentId.value = request.id;
  //                               // controller.customerName.value =
  //                               //     request.customerName;
  //                               // controller.contactNumber.value =
  //                               //     request.contactNumber;
  //                               // controller.loanAmount.value =
  //                               //     request.loanAmount.replaceAll(',', '');
  //                               // controller.loanStatus.value =
  //                               //     ((request.loanStatus == null ||
  //                               //             request.loanStatus!.isEmpty)
  //                               //         ? "NA"
  //                               //         : request.loanStatus)!;
  //                               // controller.bankId.value =
  //                               //     request.bankName ?? "";
  //                               // controller.commonRemark.value =
  //                               //     request.commonRemark;
  //                               // controller.sourceId.value =
  //                               //     request.sourcingTitle ?? "";

  //                               // controller.getRemarks();
  //                               // var result =
  //                               //     await Get.to(() => LoginRequestForm());

  //                               // controller.getLoginRequestList();
  //                               // },
  //                               // icon: const Icon(Icons.edit),
  //                               // label: const Text('Edit Request'),
  //                               // style: ElevatedButton.styleFrom(
  //                               //   backgroundColor: Colors.blue.shade600,
  //                               // ),
  //                               //  ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ));
  //             },
  //           ))));
}

Widget _buildDoubleRow({
  required dynamic iconLeft,
  required String valueLeft,
  required dynamic iconRight,
  required String valueRight,
  Color? textColorRight,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildIcon(iconLeft),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  valueLeft,
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(iconRight),
              //  Icon(iconRight, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text(
                valueRight,
                style: TextStyle(
                  fontSize: 12,
                  color: textColorRight ?? Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSingleRow(dynamic icon, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    child: Row(
      children: [
        _buildIcon(icon),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Widget _buildIcon(dynamic icon) {
  if (icon is String) {
    // SVG PATH
    return SvgPicture.asset(
      icon,
      width: 16,
      height: 16,
      color: Colors.grey[700],
    );
  } else if (icon is IconData) {
    // NORMAL ICON
    return Icon(icon, size: 16, color: Colors.grey[700]);
  } else {
    return const SizedBox();
  }
}

String maskFirst6Digits(String number) {
  if (number.length < 6) return number; // Handle edge case
  return 'xxxxxx${number.substring(6)}';
}

Future<void> safeNavigateBack() async {
  try {
    // 1️⃣ close snackbar safely
    if (Get.isSnackbarOpen) {
      await Future.delayed(const Duration(milliseconds: 100));
      Get.closeCurrentSnackbar();
    }
  } catch (e) {}

  try {
    // 2️⃣ close dialog if any
    if (Get.isDialogOpen ?? false) {
      Navigator.of(Get.context!, rootNavigator: true).pop();
    }
  } catch (e) {}

  // 3️⃣ final back
  await Future.delayed(const Duration(milliseconds: 100));

  if (Navigator.of(Get.context!).canPop()) {
    Get.back();
  }
}
