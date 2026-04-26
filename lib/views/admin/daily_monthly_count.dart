import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/controllers/admin/call_back_controller.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/views/spacing_constants.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/flutter_chiplist.dart';
import 'package:smart_solutions/widget/header_title.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import 'package:smart_solutions/widget/searchbarwithclear.dart';
import 'package:smart_solutions/widget/summary_card.dart';
import 'package:smart_solutions/widget/summary_header_card.dart';
import 'package:smart_solutions/widget/text_style.dart';
import '../../constants/static_stored_data.dart';
import '../../controllers/theme_controller.dart';

class DailyMonthlyCount extends StatefulWidget {
  final String title;
  const DailyMonthlyCount({super.key, required this.title});

  @override
  State<DailyMonthlyCount> createState() => _DailyMonthlyCountState();
}

class _DailyMonthlyCountState extends State<DailyMonthlyCount> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final AdminCallBackController _adminCallBackController =
      Get.find<AdminCallBackController>();

  final ThemeController themeController = Get.find<ThemeController>();
  final bool isTeamLeader = StaticStoredData.roleName == 'teamleader';

  @override
  void initState() {
    super.initState();
    _adminCallBackController.setPageType(widget.title);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        isDrawer: false,
        showBack: true,
        title: widget.title,
        key: _scaffoldKey,
        body: Obx(() {
          final isLoading = widget.title == 'Login Request'
              ? !_adminCallBackController.loginRequestLoaded.value
              : !_adminCallBackController.loginFilesLoaded.value;

          if (isLoading) return const LoadingPage();

          return widget.title == 'Login Request'
              ? _buildLoginRequestScreen(_adminCallBackController)
              : _buildDataEntryScreen();
        }));
  }

  Widget _buildLoginRequestScreen(dynamic controller) {
    return Column(
      children: [
        Container(
          color: AppColors.appBarTextColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderTitle(title: widget.title, style: AppTextStyle.headerTitle),
              SearchBarWithClear(
                  controller: controller.searchController,
                  onClear: controller.clearFilters,
                  showDatePickerIcon: false,
                  onChanged: (value) {
                    controller.searchLoginRequests(value.trim().toString());
                  }),

              kVerticalSpace(5),

              // FILTER CHIPS
              if (!isTeamLeader) _buildFilterChips(),

              kVerticalSpace(10),

              // TOTAL SUMMARY
              _buildLoginRequestTotalSummary(_adminCallBackController),
            ],
          ),
        ),

        // LIST SECTION
        Expanded(child: Obx(() {
          if (!_adminCallBackController.loginRequestLoaded.value) {
            return const LoadingPage();
          }

          if (_adminCallBackController.filteredLoginRequestData.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          return _buildLoginRequestList();
        })),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final filterList = _adminCallBackController.filters;

      if (filterList.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: const Center(
            child: Text(
              'Loading filters...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 50.h,
        child: FilterChipList(
          filters: filterList,
          controller: _adminCallBackController.filterScrollController,
          selectedIndex: _adminCallBackController.selectedFilter.value,
          onSelected: _adminCallBackController.selectFilter,
        ),
      );
    });
  }

  // Widget _buildLoginRequestTotalSummary() {
  //   return Obx(() {
  //     final totals = _adminCallBackController.getLoginRequestTotals();

  //     return SummaryHeaderCard(
  //       title: 'Total',
  //       duration: '',
  //       rows: [
  //         Container(
  //           padding: const EdgeInsets.all(5),
  //           decoration: BoxDecoration(
  //             color: AppColors.appBarTextColor,
  //             borderRadius: BorderRadius.circular(15),
  //           ),
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
  //                       text: totals['today'].toString(),
  //                       style: const TextStyle(
  //                         color: Colors.black,
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
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
  //                       text: totals['monthly'].toString(),
  //                       style: const TextStyle(
  //                         color: Colors.black,
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );
  //   });
  // }

  Widget _buildLoginRequestTotalSummary(dynamic controller) {
    return Obx(() {
      final today = _adminCallBackController.todayTotal.value;
      final monthly = _adminCallBackController.monthlyTotal.value;
      final total = today + monthly;

      return SummaryHeaderCard(
        title: 0,
        duration: '',
        rows: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 8),
              _summaryStat(
                label: "Today",
                value: today.toString(),
                icon: Icons.today_outlined,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
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

  Widget _buildLoginRequestList() {
    return Obx(() {
      final data = _adminCallBackController.filteredLoginRequestData;

      if (data.isEmpty) {
        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'No Telecallers Available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
          ]),
        );
      }

      return Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SummaryCard(
                imageUrl: item.profileImage?.isNotEmpty == true
                    ? item.profileImage!
                    : '',
                title: item.name,
                duration: '',
                rows: [
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 14, vertical: 10),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(14),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(.05),
                  //         blurRadius: 8,
                  //         offset: const Offset(0, 3),
                  //       ),
                  //     ],
                  //   ),
                  //   child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _statItem(
                        icon: Icons.today_outlined,
                        label: "Today",
                        value: item.todaycount ?? '0',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 14),
                      Container(
                          width: 1, height: 26, color: Colors.grey.shade300),
                      const SizedBox(width: 14),
                      _statItem(
                        icon: Icons.calendar_month_outlined,
                        label: "Monthly",
                        value: item.monthlycount ?? '0',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  //     ),
                ],
              ),
            );

            //  Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //   child: SummaryCard(
            //     title: item['name'] ?? 'Unknown',
            //     duration: '',
            //     rows: [
            //       Container(
            //         decoration: BoxDecoration(
            //           color: AppColors.appBarTextColor,
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             // TODAY
            //             RichText(
            //               text: TextSpan(
            //                 children: [
            //                   const TextSpan(
            //                     text: 'Today - ',
            //                     style: TextStyle(
            //                       color: Colors.grey,
            //                       fontSize: 12,
            //                     ),
            //                   ),
            //                   TextSpan(
            //                     text: item['todaycount'] ?? '0',
            //                     style: const TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             const SizedBox(
            //               height: 20,
            //               child: VerticalDivider(
            //                 color: Colors.grey,
            //                 thickness: 1,
            //               ),
            //             ),
            //             // MONTHLY
            //             RichText(
            //               text: TextSpan(
            //                 children: [
            //                   const TextSpan(
            //                     text: 'Monthly - ',
            //                     style: TextStyle(
            //                       color: Colors.grey,
            //                       fontSize: 12,
            //                     ),
            //                   ),
            //                   TextSpan(
            //                     text: item['monthlycount'] ?? '0',
            //                     style: const TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // );
          },
        ),
      );
    });
  }

  Widget _buildDataEntryScreen() {
    return Column(
      children: [
        Container(
          color: AppColors.appBarTextColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderTitle(
                title: widget.title,
                style: AppTextStyle.headerTitle,
              ),

              SearchBarWithClear(
                controller: _adminCallBackController.searchController,
                onClear: _adminCallBackController.clearFilters,
                showDatePickerIcon: false,
                onChanged: (value) {
                  _adminCallBackController
                      .searchLoginFileData(value.trim().toString());
                },
              ),

              kVerticalSpace(5),

              // FILTER CHIPS
              if (!isTeamLeader)
                Obx(() {
                  final filterList = _adminCallBackController.filters;

                  if (filterList.isEmpty) {
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: const Center(
                        child: Text(
                          'Loading filters...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 50.h,
                    child: FilterChipList(
                      filters: filterList,
                      controller:
                          _adminCallBackController.filterScrollController,
                      selectedIndex:
                          _adminCallBackController.selectedFilter.value,
                      onSelected: _adminCallBackController.selectFilter,
                    ),
                  );
                }),

              kVerticalSpace(10),

              // TOTAL SUMMARY
              _buildLoginFileTotalSummary(),
            ],
          ),
        ),

        // LIST SECTION
        Expanded(child: Obx(() {
          if (!_adminCallBackController.loginFilesLoaded.value) {
            return const LoadingPage();
          }

          if (_adminCallBackController.filteredLoginFilesData.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          return _buildDataEntryList();
        })),
      ],
    );
  }

  Widget _buildLoginFileTotalSummary() {
    return Obx(() {
      final today = _adminCallBackController.logintodayTotal.value;
      final monthly = _adminCallBackController.loginmonthlyTotal.value;
      // final total = today + monthly;
      return SummaryHeaderCard(
        title: 0,
        duration: '',
        rows: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _summaryStat(
                label: "Today",
                value: today.toString(),
                icon: Icons.today_outlined,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _summaryStat(
                label: "Monthly",
                value: monthly.toString(),
                icon: Icons.calendar_month_outlined,
                color: Colors.deepPurple,
              ),
            ],
          ),
        ],
      );
    });
  }

  // Widget _summaryBox({
  //   required String label,
  //   required String value,
  //   required IconData icon,
  //   required Color color,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(.08),
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: color.withOpacity(.25)),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(icon, size: 20, color: color),
  //         const SizedBox(width: 8),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: const TextStyle(
  //                 fontSize: 12,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             Text(
  //               value,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDataEntryList() {
    return Obx(() {
      final data = _adminCallBackController.filteredLoginFilesData;

      if (data.isEmpty) {
        return Center(
            child: Text('No data available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.sp,
                )));
      }

      return Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: SummaryCard(
                imageUrl: item.profileImage ?? '',
                title: item.name,
                duration: '',
                rows: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _statItem(
                        icon: Icons.today_outlined,
                        label: "Today",
                        value: item.todaycount,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 14),
                      Container(
                          width: 1, height: 26, color: Colors.grey.shade300),
                      const SizedBox(width: 14),
                      _statItem(
                        icon: Icons.calendar_month_outlined,
                        label: "Monthly",
                        value: item.monthlycount,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            );
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //   child: SummaryCard(
            //     title: item.name.toString(),
            //     duration: '',
            //     rows: [
            //       Container(
            //         decoration: BoxDecoration(
            //           color: AppColors.appBarTextColor,
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             // TODAY
            //             RichText(
            //               text: TextSpan(
            //                 children: [
            //                   const TextSpan(
            //                     text: 'Today - ',
            //                     style: TextStyle(
            //                       color: Colors.grey,
            //                       fontSize: 12,
            //                     ),
            //                   ),
            //                   TextSpan(
            //                     text: todayCount,
            //                     style: const TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //             const SizedBox(
            //               height: 20,
            //               child: VerticalDivider(
            //                 color: Colors.grey,
            //                 thickness: 1,
            //               ),
            //             ),
            //             // MONTHLY
            //             RichText(
            //               text: TextSpan(
            //                 children: [
            //                   const TextSpan(
            //                     text: 'Monthly - ',
            //                     style: TextStyle(
            //                       color: Colors.grey,
            //                       fontSize: 12,
            //                     ),
            //                   ),
            //                   TextSpan(
            //                     text: monthlyCount,
            //                     style: const TextStyle(
            //                       color: Colors.black,
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // );
          },
        ),
      );
    });
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }
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
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          "$label : ",
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

// Widget buildTotalSummary({
//   required String title,
//   required String today,
//   required String monthly,
// }) {
//   return SummaryHeaderCard(
//     title: title,
//     duration: '',
//     rows: [
//       Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _summaryStat(
//             label: "Today",
//             value: today,
//             icon: Icons.today_outlined,
//             color: Colors.blue,
//           ),
//           const SizedBox(width: 10),
//           _summaryStat(
//             label: "Monthly",
//             value: monthly,
//             icon: Icons.calendar_month_outlined,
//             color: Colors.deepPurple,
//           ),
//         ],
//       ),
//     ],
//   );
// }
