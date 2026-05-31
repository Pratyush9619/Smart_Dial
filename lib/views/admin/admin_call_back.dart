import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/views/spacing_constants.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/flutter_chiplist.dart';
import 'package:smart_solutions/widget/header_title.dart';
import 'package:smart_solutions/widget/searchbarwithclear.dart';
import 'package:smart_solutions/widget/summary_card.dart' show SummaryCard;
import 'package:smart_solutions/widget/summary_header_card.dart';
import 'package:smart_solutions/widget/text_style.dart';
import '../../constants/static_stored_data.dart';

class AdminCallBack extends StatefulWidget {
  final String title;
  const AdminCallBack({super.key, required this.title});

  @override
  State<AdminCallBack> createState() => _AdminCallBackState();
}

class _AdminCallBackState extends State<AdminCallBack> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController searchController = TextEditingController();

  //final _followBackController = Get.put(AdminCallBackController());
  final _followBackController = Get.find<FollowBackFormController>();

  @override
  void initState() {
    super.initState();
    _followBackController.getteamLeaderData();
    _followBackController.getCallBackData();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        isDrawer: false,
        showBack: true,
        title: widget.title,
        key: _scaffoldKey,
        body: Column(
          children: [
            Container(
                color: AppColors.appBarTextColor,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderTitle(
                          title: widget.title, style: AppTextStyle.headerTitle),
                      SearchBarWithClear(
                          controller: _followBackController.searchController,
                          showDatePickerIcon: false,
                          onClear: () {
                            _followBackController.clearFilters();
                            //    _followBackController.searchText.value = '';

                            _followBackController.filtercallBack(
                                searchQuery: '');
                          },
                          onChanged: (value) {
                            _followBackController.searchText.value = value;
                            _followBackController.filtercallBack(
                                searchQuery: value);
                          }),
                      kVerticalSpace(5),
                      Obx(() {
                        final filterList = _followBackController.filters;

                        final isAllowed =
                            StaticStoredData.roleName != 'telecaller' &&
                                StaticStoredData.roleName != 'teamleader';

                        return Visibility(
                          visible: isAllowed,
                          child: FilterChipList(
                            filters: filterList,
                            controller:
                                _followBackController.filterScrollController,
                            selectedIndex:
                                _followBackController.selectedFilter.value,
                            onSelected: _followBackController.selectFilter,
                          ),
                        );
                      }),
                      kVerticalSpace(10),

                      _buildTotalSummary(_followBackController),
                      // Obx(() {
                      //   final data =
                      //       _followBackController.callBackTotalData;

                      //   return SummaryHeaderCard(
                      //     title: 0,
                      //     duration: '',
                      //     rows: [
                      //       Container(
                      //           padding: const EdgeInsets.all(5),
                      //           decoration: BoxDecoration(
                      //               color: AppColors.appBarTextColor,
                      //               borderRadius:
                      //                   BorderRadius.circular(15)),
                      //           child: Row(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               // TODAY
                      //               RichText(
                      //                 text: TextSpan(
                      //                   children: [
                      //                     const TextSpan(
                      //                       text: 'Today - ',
                      //                       style: TextStyle(
                      //                         color: Colors.grey,
                      //                         fontSize: 14,
                      //                       ),
                      //                     ),
                      //                     TextSpan(
                      //                       text: data.first
                      //                           .todayCallbackTotal
                      //                           .toString(),
                      //                       style: const TextStyle(
                      //                         color: Colors.black,
                      //                         fontSize: 14,
                      //                         fontWeight:
                      //                             FontWeight.w600,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),

                      //               const SizedBox(
                      //                 height: 20,
                      //                 child: VerticalDivider(
                      //                   color: Colors.grey,
                      //                   thickness: 1,
                      //                 ),
                      //               ),

                      //               // MONTHLY
                      //               RichText(
                      //                 text: TextSpan(
                      //                   children: [
                      //                     const TextSpan(
                      //                       text: 'Monthly - ',
                      //                       style: TextStyle(
                      //                         color: Colors.grey,
                      //                         fontSize: 14,
                      //                       ),
                      //                     ),
                      //                     TextSpan(
                      //                       text: data.first
                      //                           .monthlyCallbackTotal
                      //                           .toString(),
                      //                       style: const TextStyle(
                      //                         color: Colors.black,
                      //                         fontSize: 14,
                      //                         fontWeight:
                      //                             FontWeight.w600,
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             ],
                      //           ))
                      //     ],
                      //   );
                      // }),
                    ])),
            Expanded(
              child: Obx(() {
                if (_followBackController.iscallBackLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = _followBackController.callBackData;

                if (list.isEmpty) {
                  return const Center(child: Text("No Data Found"));
                }
                return Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: ListView.builder(
                      itemCount: _followBackController.callBackData.length,
                      itemBuilder: (context, index) {
                        final data = _followBackController.callBackData[index];

                        if (_followBackController.iscallBackLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: SummaryCard(
                            imageUrl: data.profileImage.toString(),
                            title: data.name.toString(),
                            duration: '',
                            rows: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.appBarTextColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _statItem(
                                        icon: Icons.today_outlined,
                                        label: "Today",
                                        value: data.todayCallbackCount,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 14),
                                      Container(
                                          width: 1,
                                          height: 26,
                                          color: Colors.grey.shade300),
                                      const SizedBox(width: 14),
                                      _statItem(
                                        icon: Icons.calendar_month_outlined,
                                        label: "Monthly",
                                        value: data.monthlyCallbackCount,
                                        color: Colors.orange,
                                      ),
                                      // TODAY
                                      // RichText(
                                      //   text: TextSpan(
                                      //     children: [
                                      //       const TextSpan(
                                      //         text: 'Today - ',
                                      //         style: TextStyle(
                                      //           color: Colors.grey,
                                      //           fontSize: 12,
                                      //         ),
                                      //       ),
                                      //       TextSpan(
                                      //         text: data
                                      //             .todayCallbackCount,
                                      //         style: const TextStyle(
                                      //           color: Colors.black,
                                      //           fontSize: 12,
                                      //           fontWeight:
                                      //               FontWeight.w600,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

                                      // const SizedBox(
                                      //   height: 20,
                                      //   child: VerticalDivider(
                                      //     color: Colors.grey,
                                      //     thickness: 1,
                                      //   ),
                                      // ),

                                      // // MONTHLY
                                      // RichText(
                                      //   text: TextSpan(
                                      //     children: [
                                      //       const TextSpan(
                                      //         text: 'Monthly - ',
                                      //         style: TextStyle(
                                      //           color: Colors.grey,
                                      //           fontSize: 12,
                                      //         ),
                                      //       ),
                                      //       TextSpan(
                                      //         text: data
                                      //             .monthlyCallbackCount,
                                      //         style: const TextStyle(
                                      //           color: Colors.black,
                                      //           fontSize: 12,
                                      //           fontWeight:
                                      //               FontWeight.w600,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ))
                            ],
                          ),
                        );
                      }),
                );
              }),
            ),
          ],
        ));
  }

  String maskFirst6Digits(String number) {
    if (number.length < 6) return number; // Handle edge case
    return 'xxxxxx${number.substring(6)}';
  }

  Widget _buildTotalSummary(dynamic controller) {
    return Obx(() {
      final selectedId = controller.getSelectedTeamLeaderId();

      int today = 0;
      int monthly = 0;

      if (selectedId == null || selectedId.isEmpty) {
        // 🔥 ALL DATA TOTAL
        for (var e in controller.callBackData) {
          today += int.tryParse(e.todayCallbackCount ?? '0') ?? 0;
          monthly += int.tryParse(e.monthlyCallbackCount ?? '0') ?? 0;
        }
      } else {
        // 🔥 FILTERED DATA
        final filteredList = controller.callBackData
            .where((e) => e.teamleaderId == selectedId)
            .toList();

        for (var e in filteredList) {
          today += int.tryParse(e.todayCallbackCount ?? '0') ?? 0;
          monthly += int.tryParse(e.monthlyCallbackCount ?? '0') ?? 0;
        }
      }

      final total = today + monthly;

      return SummaryHeaderCard(
        title: 0,
        rows: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 3),
              _summaryStat(
                label: "Today",
                value: today.toString(),
                icon: Icons.today_outlined,
                color: Colors.blue,
              ),
              const SizedBox(width: 3),
              _summaryStat(
                label: "Monthly",
                value: monthly.toString(),
                icon: Icons.calendar_month_outlined,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _summaryStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _statItem({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    ],
  );
}
