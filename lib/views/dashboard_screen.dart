import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/constants/api_urls.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/all_disbursement_controller.dart';
import 'package:smart_solutions/controllers/chartCard_controller.dart';
import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/controllers/dashboard_controller.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/controllers/notification_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/feature/views/callback/today_callback.dart';
import 'package:smart_solutions/models/dashBoardToday_model.dart';
import 'package:smart_solutions/models/incentive_model.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/views/active_files.dart';
import 'package:smart_solutions/views/admin/admin_call_back.dart';
import 'package:smart_solutions/views/admin/admin_call_log.dart';
import 'package:smart_solutions/views/admin/admin_disbursement.dart';
import 'package:smart_solutions/views/admin/daily_monthly_count.dart';
import 'package:smart_solutions/views/chart_card_toggle.dart';
import 'package:smart_solutions/views/notification_screen.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/file_status_card.dart';
import 'package:smart_solutions/widget/image_helper.dart';
import 'package:smart_solutions/widget/incentive_card.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import 'package:smart_solutions/widget/string.dart';
import 'package:smart_solutions/widget/text_style.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../binding/active_file_binding.dart';
import '../models/getGroupStatus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FollowBackFormController? followBackFormController;

  final DisbursementDetailsController _disbursementDetailsController =
      Get.find<DisbursementDetailsController>();

  final CommonFilterController commonFilterController =
      Get.find<CommonFilterController>();

  final DashboardController controller = Get.find<DashboardController>();

  final ChartCardsController chartCardsController =
      Get.find<ChartCardsController>();

  final ThemeController themeController = Get.find<ThemeController>();

  final bool isNotTelecaller = StaticStoredData.roleName != 'telecaller';

  @override
  void initState() {
    // if (StaticStoredData.roleName == 'telecaller') {
    followBackFormController = Get.find<FollowBackFormController>();
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      themeController.loadSavedTheme();
    });
    controller.onInit();
    super.initState();
  }

  // @override
  // void dispose() {
  //   //   controller.tabController.dispose();
  //   // followBackFormController.callController.dispose();
  //   super.dispose();
  // }

  DateTime today = DateTime.now();
  List todayUsers = [];

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController =
        Get.put(NotificationController());

    //  String role = StaticStoredData.roleName; // example role

    // final List<String> labels = role == "telecaller" ? [] : ["Select Date"];
    // // : ["Select Date", "Filter"];

    // final String tellecallerLabels = role == "telecaller"
    //     ? "Call Back & Incentive"
    //     : "Tellecaller Performance";

    // //   final List<String> labels = ["Select Date", "Filter"];

    // final callBackTabFortellecaller = [
    //   const Tab(text: "Today"),

    //   const Tab(text: "Monthly"),
    //   //     const Tab(text: "Incentive"),
    // ];

    // final callBackTabForAdmin = [
    //   const Tab(text: "Call Back"),
    //   const Tab(text: "Call Log"),
    //   const Tab(text: "Disbursement"),
    //   //  const Tab(text: "Incentive"),
    // ];

    // final callBackTabBarFortellecaller = [
    //   dailyCallBack(),
    //   monthlyCallBack()
    //   //     callDisbursement(Icons.person)
    // ];

    // final callBackTabBarForAdmin = [
    //   callback(Icons.person),
    //   callLog(Icons.person),
    //   callDisbursement(Icons.person),
    // ];

    // final List<VoidCallback> callbacks = [
    //   () => showDatePicker(),
    //   () => showDialog(
    //       context: context,
    //       builder: (context) {
    //         return Obx(
    //           () => TellecallerFilterChipDialog(
    //             title1: 'Teamleader',
    //             title2: 'Tellecaller',
    //             teamleader: followBackFormController.teamleaderList.toList(),
    //             tellecaller: followBackFormController.tellecallerList.toList(),
    //             onApply: (teamleader, tellecaller) {},
    //           ),
    //         );
    //       })
    // ];

    // String today = "${DateTime.now().day.toString().padLeft(2, '0')} "
    //     "${DateFormat('MMM').format(DateTime.now()).toUpperCase()} "
    //     "${DateTime.now().year}";

    return CommonScaffold(
      title: "Dashboard",
      isDrawer: true,
      showBack: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
            onPressed: () async {
              Get.to(() => const NotificationSCreen());
              //     controller.onInit();
              //    refreshDashboard();
              // await controller
              //     .fetchDashboardData(true); // Refresh monthly data
              // await controller.fetchDashboardData(false);
            },
            icon: Obx(
              () => Stack(
                children: [
                  SvgPicture.asset('assets/images/notification.svg'),
                  notificationController.unreadCount.value != 0
                      ? Positioned(
                          right: 0,
                          top: 0,
                          bottom: 25,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 12,
                            ),
                            child: Text(
                              notificationController.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ))
                      : const SizedBox(),
                ],
              ),
            ),
            // const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
      key: _scaffoldKey,
      body: Obx(
        () => RefreshIndicator(
          color: themeController.primaryColor.value,
          onRefresh: () async {
            controller.onInit();
            _disbursementDetailsController.fetchDisbursementDetails();
          },
          child: Obx(
            () => controller.isLoading.value
                ? const Positioned.fill(
                    child: Center(child: LoadingPage()),
                  )
                : SingleChildScrollView(
                    controller: controller.scrollController,
                    child: Obx(() {
                      // final List<Map<String, dynamic>> dashboardItems = [
                      //   {
                      //     "icon": "assets/images/dashboard_attempted.svg",
                      //     "value": (controller.callTimeModel.callTimeModel
                      //                 ?.totalAttempt ??
                      //             0)
                      //         .toString(),
                      //     "label": "Attempted",
                      //     "textColor": AppColors.blueColor
                      //     // 'duration': (controller.totalDuration).toString()
                      //   },
                      //   {
                      //     "icon": "assets/images/dashboard_connected.svg",
                      //     "value": controller.totalPicked.value.toString(),
                      //     "label": "Connected",
                      //     //'duration': (controller.totalDuration).toString()
                      //     "textColor": AppColors.greenCOlor
                      //   },
                      //   {
                      //     "icon": "assets/images/dashboard_not_connected.svg",
                      //     "value": controller.totalNotPicked.value.toString(),
                      //     "label": "Not Connected",
                      //     "textColor": AppColors.redColor
                      //     //'duration': '00:00:00'
                      //   },
                      // ];

                      final callData = controller.callTimeModel.callTimeModel;

                      final List<Map<String, dynamic>> dashboardItems = [
                        {
                          "icon": "assets/images/dashboard_attempted.svg",
                          "value": (callData?.totalAttempt ?? 0).toString(),
                          "label": "Attempted",
                          "textColor": AppColors.blueColor
                        },
                        {
                          "icon": "assets/images/dashboard_connected.svg",
                          "value": controller.totalPicked.value.toString(),
                          "label": "Connected",
                          "textColor": AppColors.greenCOlor
                        },
                        {
                          "icon": "assets/images/dashboard_not_connected.svg",
                          "value": controller.totalNotPicked.value.toString(),
                          "label": "Not Connected",
                          "textColor": AppColors.redColor
                        },
                      ];
                      return Column(children: [
                        Container(
                          color: AppColors.appBarTextColor,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headerTitle(
                                      dashboardTitle, AppTextStyle.headerTitle),
                                  ChartCardsToggle(
                                    data: const ['Card', 'Chart'],
                                  )
                                ],
                              ),
                              // StaticStoredData.roleName != 'telecaller'
                              //     ? SizedBox(
                              //         height: 32,
                              //         child: Row(
                              //           children: [
                              //             if (controller
                              //                 .dateRangeList.isNotEmpty) ...[
                              //               const SizedBox(width: 10),

                              //               // Simple Selected Date Text
                              //               Container(
                              //                 padding: const EdgeInsets.symmetric(
                              //                     horizontal: 12, vertical: 4),
                              //                 decoration: BoxDecoration(
                              //                   color: AppColors.greyColor
                              //                       .withOpacity(0.1),
                              //                   borderRadius:
                              //                       BorderRadius.circular(8),
                              //                   border: Border.all(
                              //                     color: AppColors
                              //                         .diallerContainerColor,
                              //                     width: 1,
                              //                   ),
                              //                 ),
                              //                 child: Row(
                              //                   children: [
                              //                     const Icon(Icons.calendar_month,
                              //                         size: 16,
                              //                         color: Colors.grey),
                              //                     const SizedBox(width: 6),
                              //                     Text(
                              //                       controller
                              //                           .formattedDate.value,
                              //                       style: const TextStyle(
                              //                         fontSize: 14,
                              //                         color: Colors.black,
                              //                         fontWeight: FontWeight.w500,
                              //                       ),
                              //                     ),
                              //                     const SizedBox(width: 6),

                              //                     // Simple Close Icon
                              //                     InkWell(
                              //                       onTap: () {
                              //                         controller.dateRangeList
                              //                             .clear();
                              //                         controller.totalContact
                              //                             .clear();
                              //                         controller.totalNoContact
                              //                             .clear();
                              //                         controller.totalAttempt
                              //                             .clear();
                              //                         controller.activeCallMap
                              //                             .clear();
                              //                         controller.activeNoCallMap
                              //                             .clear();
                              //                         controller.activeAttemptMap
                              //                             .clear();
                              //                         controller
                              //                             .finalActiveNoCallList
                              //                             .clear();
                              //                         controller
                              //                             .finalActiveCallList
                              //                             .clear();
                              //                         controller
                              //                             .finalTotalAttemptCallList
                              //                             .clear();

                              //                         DateTime now =
                              //                             DateTime.now();
                              //                         controller.dateRange.value =
                              //                             "${now.day}-${now.month}-${now.year},${now.day}-${now.month}-${now.year}";
                              //                         controller.getTimeGraph();
                              //                       },
                              //                       child: const Icon(
                              //                         Icons.close,
                              //                         size: 16,
                              //                         color: Colors.black54,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ] else ...[
                              //               // --- NO DATE SELECTED PLACEHOLDER ---
                              //               const SizedBox(width: 10),

                              //               Container(
                              //                 padding: const EdgeInsets.symmetric(
                              //                     horizontal: 12, vertical: 4),
                              //                 decoration: BoxDecoration(
                              //                   borderRadius:
                              //                       BorderRadius.circular(8),
                              //                   border: Border.all(
                              //                     color: Colors.grey.shade400,
                              //                     width: 1,
                              //                   ),
                              //                 ),
                              //                 child: Row(
                              //                   children: [
                              //                     const Icon(Icons.calendar_month,
                              //                         size: 16,
                              //                         color: Colors.grey),
                              //                     const SizedBox(width: 6),
                              //                     Text(
                              //                       today,
                              //                       style: const TextStyle(
                              //                         fontSize: 14,
                              //                         fontWeight: FontWeight.w500,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ],

                              //             const SizedBox(width: 10),

                              //             // Tabs (Simple Boxes with Icon)
                              //             Expanded(
                              //               child: ListView.builder(
                              //                 scrollDirection: Axis.horizontal,
                              //                 itemCount: labels.length,
                              //                 reverse: true,
                              //                 itemBuilder: (context, index) {
                              //                   return Obx(() {
                              //                     final isSelected = controller
                              //                             .selectedTab.value ==
                              //                         index;

                              //                     return GestureDetector(
                              //                       onTap: () {
                              //                         controller.selectedTab
                              //                             .value = index;
                              //                         callbacks[index]();
                              //                       },
                              //                       child: Container(
                              //                         margin: const EdgeInsets
                              //                             .symmetric(
                              //                             horizontal: 20),
                              //                         padding: const EdgeInsets
                              //                             .symmetric(
                              //                             horizontal: 10,
                              //                             vertical: 5),
                              //                         decoration: BoxDecoration(
                              //                           color: isSelected
                              //                               ? AppColors.greyColor
                              //                                   .withOpacity(0.15)
                              //                               : Colors.white,
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                   8),
                              //                           border: Border.all(
                              //                             color: isSelected
                              //                                 ? AppColors
                              //                                     .greyColor
                              //                                 : Colors
                              //                                     .grey.shade400,
                              //                             width: 1,
                              //                           ),
                              //                         ),
                              //                         child: Icon(
                              //                           Icons.calendar_month,
                              //                           size: 18,
                              //                           color: isSelected
                              //                               ? AppColors
                              //                                   .primaryColor
                              //                               : Colors
                              //                                   .grey.shade600,
                              //                         ),
                              //                       ),
                              //                     );
                              //                   });
                              //                 },
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       )
                              //     : const SizedBox.shrink(),

                              Visibility(
                                visible:
                                    (chartCardsController.selectedIndex == 0)
                                        ? true
                                        : false,
                                child: GridView.builder(
                                  itemCount: dashboardItems.length,
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 1.2,
                                          crossAxisCount:
                                              dashboardItems.length),
                                  itemBuilder: (context, index) {
                                    var item = dashboardItems[index];
                                    return Stack(children: [
                                      dashboardStatCard(
                                          iconPath: item['icon'],
                                          value: item['value'],
                                          label: item['label'],
                                          textColor: item['textColor']),
                                      if (index != dashboardItems.length - 1)
                                        Positioned(
                                          right: 0,
                                          top: 17,
                                          bottom: 17,
                                          child: Container(
                                            width: 1,
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                    ]);
                                  },
                                ),
                              ),
                              if (followBackFormController
                                      ?.selectedtellecaller.isNotEmpty ??
                                  false)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Spacer(),
                                    SizedBox(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width -
                                          35.w,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: followBackFormController!
                                            .selectedtellecaller.length,
                                        itemBuilder: (context, index) {
                                          final name = followBackFormController!
                                              .selectedtellecallerName[index];
                                          final id = followBackFormController!
                                              .selectedtellecaller[index];

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  GestureDetector(
                                                    onTap: () {
                                                      // Remove name and id from controller
                                                      followBackFormController!
                                                          .selectedtellecaller
                                                          .remove(id);
                                                      followBackFormController!
                                                          .selectedtellecallerName
                                                          .remove(name);

                                                      followBackFormController!
                                                          .getAllDashboardData(
                                                        dashboardController:
                                                            controller,
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.end,
                              //   children: [
                              //     if (controller.dateRangeList.isNotEmpty) ...[
                              //       const Spacer(),
                              //       Text(
                              //         controller.formattedDate.value,
                              //         style: const TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w500,
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //       const SizedBox(
                              //         width: 10,
                              //       ),
                              //       InkWell(
                              //         onTap: () {
                              //           controller.dateRangeList.clear();
                              //           controller.totalContact.clear();
                              //           controller.totalNoContact.clear();
                              //           controller.totalAttempt.clear();
                              //           controller.activeCallMap.clear();
                              //           controller.activeNoCallMap.clear();
                              //           controller.activeAttemptMap.clear();
                              //           controller.finalActiveNoCallList.clear();
                              //           controller.finalActiveCallList.clear();
                              //           controller.finalTotalAttemptCallList
                              //               .clear();
                              //           DateTime now = DateTime.now();
                              //           controller.dateRange.value =
                              //               "${now.day}-${now.month}-${now.year},${now.day}-${now.month}-${now.year}";
                              //           controller.getTimeGraph();
                              //         },
                              //         child: Container(
                              //           padding: EdgeInsets.all(5.0.w),
                              //           decoration: BoxDecoration(
                              //             color: AppColors.grid1.withOpacity(0.3),
                              //             borderRadius: BorderRadius.circular(25),
                              //           ),
                              //           child: Icon(
                              //             Icons.close,
                              //             size: 20.sp,
                              //           ),
                              //         ),
                              //       ),
                              //     ]
                              //   ],
                              // ),
                              Visibility(
                                visible:
                                    (chartCardsController.selectedIndex == 1)
                                        ? true
                                        : false,
                                child: SizedBox(
                                  height: 300,
                                  child: SfCartesianChart(
                                    // Add margin to prevent bars from being cut off
                                    margin: const EdgeInsets.all(10),
                                    plotAreaBorderWidth: 0,

                                    primaryXAxis: const CategoryAxis(
                                      labelPlacement: LabelPlacement.onTicks,
                                      labelRotation: 0,
                                      labelIntersectAction:
                                          AxisLabelIntersectAction.rotate45,
                                      autoScrollingDelta: 0,
                                      majorGridLines: MajorGridLines(width: 0),
                                      edgeLabelPlacement:
                                          EdgeLabelPlacement.shift,
                                      // Add axis line
                                      axisLine: AxisLine(
                                          width: 1, color: Colors.grey),
                                      // Add padding to ensure first and last bars are visible
                                      plotOffset:
                                          15, // This creates space at edges
                                    ),

                                    primaryYAxis: const NumericAxis(
                                        labelFormat: '{value}',
                                        majorGridLines:
                                            MajorGridLines(width: 0),
                                        axisLine: AxisLine(
                                            width: 1, color: Colors.grey),
                                        // Add padding to Y axis as well
                                        plotOffset: 10),
                                    tooltipBehavior:
                                        TooltipBehavior(enable: true),
                                    legend: const Legend(
                                      isVisible: true,
                                      position: LegendPosition.bottom,
                                      overflowMode:
                                          LegendItemOverflowMode.scroll,
                                    ),

                                    series: <CartesianSeries<CallGraphModel,
                                        String>>[
                                      StackedColumnSeries<CallGraphModel,
                                          String>(
                                        width:
                                            0.6, // Reduce width slightly for better fit
                                        borderColor: Colors.white,
                                        borderWidth: 1,
                                        spacing: 0.15, // Reduce spacing
                                        color: AppColors.appBarColor,
                                        dataSource: controller
                                            .finalTotalAttemptCallList,
                                        xValueMapper:
                                            (CallGraphModel data, _) =>
                                                data.time,
                                        yValueMapper:
                                            (CallGraphModel data, _) =>
                                                data.data ?? 0,
                                        name: 'Attempted',
                                        legendIconType: LegendIconType.circle,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                          isVisible: true,
                                          textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      StackedColumnSeries<CallGraphModel,
                                          String>(
                                        width: 0.6, // Consistent width
                                        color: Colors.green,
                                        borderColor: Colors.white,
                                        borderWidth: 1,
                                        spacing: 0.15,
                                        dataSource:
                                            controller.finalActiveCallList,
                                        xValueMapper:
                                            (CallGraphModel data, _) =>
                                                data.time,
                                        yValueMapper:
                                            (CallGraphModel data, _) =>
                                                data.data ?? 0,
                                        legendIconType: LegendIconType.circle,
                                        name: 'Connected',
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                          isVisible: true,
                                          textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      StackedColumnSeries<CallGraphModel,
                                          String>(
                                        width: 0.6, // Consistent width
                                        color: Colors.red,
                                        borderColor: Colors.white,
                                        borderWidth: 1,
                                        spacing: 0.15,
                                        dataSource:
                                            controller.finalActiveNoCallList,
                                        xValueMapper:
                                            (CallGraphModel data, _) =>
                                                data.time,
                                        yValueMapper:
                                            (CallGraphModel data, _) =>
                                                data.data ?? 0,
                                        name: 'Not Connected',
                                        legendIconType: LegendIconType.circle,
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                          isVisible: true,
                                          textStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  subHeaderTitle(durationTitle),
                                  headerTitles(
                                      controller.totalDuration.toString(),
                                      AppTextStyle.blueHeaderTitletStyle),
                                ],
                              ),
                              // Container(
                              //   height: 30,
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       if (controller.dateRangeList.isNotEmpty) ...[
                              //         const SizedBox(width: 15),
                              //         Text(
                              //           controller.formattedDate.value,
                              //           style: const TextStyle(
                              //             fontSize: 16,
                              //             fontWeight: FontWeight.w500,
                              //             color: Colors.black,
                              //           ),
                              //         ),
                              //         const SizedBox(
                              //           width: 10,
                              //         ),
                              //         InkWell(
                              //           onTap: () {
                              //             controller.dateRangeList.clear();
                              //             controller.totalContact.clear();
                              //             controller.totalNoContact.clear();
                              //             controller.totalAttempt.clear();
                              //             controller.activeCallMap.clear();
                              //             controller.activeNoCallMap.clear();
                              //             controller.activeAttemptMap.clear();
                              //             controller.finalActiveNoCallList
                              //                 .clear();
                              //             controller.finalActiveCallList.clear();
                              //             controller.finalTotalAttemptCallList
                              //                 .clear();
                              //             DateTime now = DateTime.now();
                              //             controller.dateRange.value =
                              //                 "${now.day}-${now.month}-${now.year},${now.day}-${now.month}-${now.year}";
                              //             controller.getTimeGraph();
                              //           },
                              //           child: Container(
                              //             padding: EdgeInsets.all(5.0.w),
                              //             decoration: BoxDecoration(
                              //               color:
                              //                   AppColors.grid1.withOpacity(0.3),
                              //               borderRadius:
                              //                   BorderRadius.circular(25),
                              //             ),
                              //             child: Icon(
                              //               Icons.close,
                              //               size: 20.sp,
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //       Expanded(
                              //         child: ListView.builder(
                              //           scrollDirection: Axis.horizontal,
                              //           itemCount: labels.length,
                              //           reverse:
                              //               true, // ← Moves items to the RIGHT
                              //           itemBuilder: (context, index) {
                              //             return Obx(() {
                              //               final isSelected =
                              //                   controller.selectedTab.value ==
                              //                       index;
                              //               return GestureDetector(
                              //                 onTap: () async {
                              //                   controller.selectedTab.value =
                              //                       index;
                              //                   // await followBackFormController
                              //                   //     .getteamLeaderData();
                              //                   callbacks[index]();
                              //                 },
                              //                 child: Padding(
                              //                   padding:
                              //                       const EdgeInsets.symmetric(
                              //                           horizontal: 15),
                              //                   child: Container(
                              //                     padding:
                              //                         const EdgeInsets.symmetric(
                              //                             horizontal: 5),
                              //                     decoration: BoxDecoration(
                              //                         color: isSelected
                              //                             ? AppColors.primaryColor
                              //                             : AppColors
                              //                                 .backgroundColor,
                              //                         borderRadius:
                              //                             BorderRadius.circular(
                              //                                 10),
                              //                         border: Border.all(
                              //                             color: AppColors
                              //                                 .primaryColor)),
                              //                     child: Icon(
                              //                       Icons.calendar_month,
                              //                       size: 18,
                              //                       color: isSelected
                              //                           ? AppColors
                              //                               .backgroundColor
                              //                           : AppColors.primaryColor,
                              //                     ),

                              //                     // Text(
                              //                     //   textAlign:
                              //                     //       TextAlign.center,
                              //                     //   labels[index],
                              //                     //   style: TextStyle(
                              //                     //       fontSize: 15,
                              //                     //       color: isSelected
                              //                     //           ? AppColors
                              //                     //               .backgroundColor
                              //                     //           : AppColors
                              //                     //               .primaryColor),
                              //                     // ),
                              //                   ),
                              //                 ),
                              //               );
                              //             });
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        verticalSpace(15.h),
                        headerTitleWithContainer('Disbursement'),
                        verticalSpace(15.h),

                        ...[
                          if (_disbursementDetailsController
                              .disbursementList.isNotEmpty)
                            SizedBox(
                              height: 80.h,
                              child: ListView.builder(
                                itemCount: _disbursementDetailsController
                                    .disbursementList.length,
                                scrollDirection: Axis.horizontal,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  final data = _disbursementDetailsController
                                      .disbursementList[index];

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.w),
                                    child: disbursementCard(
                                      '${data.monthName} ${data.year}',
                                      data.amount.toString(),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            SizedBox(
                              height: 80.h,
                              child: Center(
                                child: Text(
                                  "No Data Available",
                                  style: TextStyle(
                                      fontSize: 14.sp, color: Colors.grey),
                                ),
                              ),
                            ),
                        ],
                        // ...[
                        //   if (_disbursementDetailsController
                        //       .disbursementList.isNotEmpty)
                        //     SizedBox(
                        //       height: 80.h,
                        //       child: ListView.builder(
                        //         itemCount: _disbursementDetailsController
                        //             .disbursementList.length,
                        //         scrollDirection: Axis.horizontal, //
                        //         reverse: true,
                        //         itemBuilder: (context, index) {
                        //           final data = _disbursementDetailsController
                        //               .disbursementList[index];
                        //           return Padding(
                        //               padding:
                        //                   EdgeInsets.symmetric(horizontal: 5.w),
                        //               child: disbursementCard(
                        //                   '${data.monthName} ${data.year}',
                        //                   data.amount.toString()));
                        //         },
                        //       ),
                        //     ),

                        // ],
                        verticalSpace(15.h),
                        customContainer(20.h),
                        verticalSpace(15.h),
                        Obx(() {
                          // if (controller.topDisburserUser.isEmpty) {
                          //   return Center(
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Icon(
                          //           Icons.people_outline,
                          //           size: 90,
                          //           color: Colors.grey.shade400,
                          //         ),
                          //         const SizedBox(height: 16),
                          //         Text(
                          //           "No Top Disbursers Yet",
                          //           style: TextStyle(
                          //             fontSize: 18,
                          //             fontWeight: FontWeight.w600,
                          //             color: Colors.grey.shade700,
                          //           ),
                          //         ),
                          //         const SizedBox(height: 8),
                          //         Text(
                          //           "Once users start disbursing,\n they will appear here.",
                          //           textAlign: TextAlign.center,
                          //           style: TextStyle(
                          //             fontSize: 14,
                          //             color: Colors.grey.shade500,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   );
                          // }

                          // if (controller.topDisburserUser.isEmpty) {
                          //   return const LoadingPage();
                          // }
                          return Container(
                            decoration: BoxDecoration(
                                color: AppColors.appBarTextColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.appBarTextColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                headerTitle(topPerformerTitle,
                                    AppTextStyle.headerTitle),
                                controller.topDisburserUser.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people_outline,
                                              size: 90,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              "No Top Performer Yet",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Once users start disbursing,\n they will appear here.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          performer(
                                              'assets/images/mtd_performer.png',
                                              controller.topDisburserUser.first
                                                  .monthly.profileImage
                                                  .toString(),
                                              'MTD Performer',
                                              controller.topDisburserUser.first
                                                  .monthly.name,
                                              controller.topDisburserUser.first
                                                  .monthly.amount),
                                          performer(
                                              'assets/images/ytd_performer.png',
                                              controller.topDisburserUser.first
                                                  .yearly.profileImage
                                                  .toString(),
                                              'YTD Performer',
                                              controller.topDisburserUser.first
                                                  .yearly.name,
                                              controller.topDisburserUser.first
                                                  .yearly.amount),
                                        ],
                                      ),
                              ],
                            ),
                          );
                        }),
                        verticalSpace(15.h),
                        // if (controller.isActiveLoaded.value) ...[
                        headerTitleWithContainer('Login File Status'),
                        verticalSpace(15.h),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Obx(() {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8.w),
                                    child: FileStatusCard(
                                      title: "Active Files",
                                      fileCount: controller.loginFileStatusCount
                                              .first.activefilecount.isNotEmpty
                                          ? controller.loginFileStatusCount
                                              .first.activefilecount
                                              .toString()
                                          : '0',
                                      amount: controller.loginFileStatusCount
                                              .first.activeloanamount.isNotEmpty
                                          ? controller.loginFileStatusCount
                                              .first.activeloanamount
                                              .toString()
                                          : '0',
                                      statusColor: Colors.green,
                                      onPress: () {
                                        Get.to(
                                            const ActiveFiles(
                                              title: 'Active Files',
                                              status: 1,
                                              isShowBack: true,
                                              isDrawer: false,
                                            ),
                                            binding: ActiveFileBinding());
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 8.w),
                                    child: FileStatusCard(
                                      title: "Inactive Files",
                                      fileCount: controller
                                              .loginFileStatusCount
                                              .first
                                              .inactivefilecount
                                              .isNotEmpty
                                          ? controller.loginFileStatusCount
                                              .first.inactivefilecount
                                              .toString()
                                          : '0',
                                      amount: controller
                                              .loginFileStatusCount
                                              .first
                                              .inactiveloanamount
                                              .isNotEmpty
                                          ? controller.loginFileStatusCount
                                              .first.inactiveloanamount
                                              .toString()
                                          : '0',
                                      statusColor: Colors.red,
                                      onPress: () {
                                        Get.to(
                                            const ActiveFiles(
                                              title: 'InActive Files',
                                              status: 2,
                                              isShowBack: true,
                                              isDrawer: false,
                                            ),
                                            binding: ActiveFileBinding());
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        verticalSpace(15.h),
                        customContainer(20.h),
                        verticalSpace(15.h),
                        // StaticStoredData.roleName == 'telecaller'
                        //     ? headerTitleWithContainer('Call Back & Incentives')
                        //     : headerTitleWithContainer('Performance Insights'),

                        headerTitleWithContainer(
                          isNotTelecaller
                              ? 'Performance Insight'
                              : 'Call Back & Incentives',
                        ),
                        verticalSpace(15.h),

                        verticalSpace(15.h),
                        isNotTelecaller
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(children: [
                                  IncentiveCard(
                                    title: 'Call Back',
                                    duration: '',
                                    isNextPage: true,
                                    onTap: () => Get.to(const AdminCallBack(
                                        title: 'Call Back')),
                                    items: [
                                      IncentiveItem(
                                        "Today",
                                        followBackFormController!
                                                .callBackTotalData.isNotEmpty
                                            ? followBackFormController!
                                                .callBackTotalData
                                                .first
                                                .todayCallbackTotal
                                                .toString()
                                            : '0',
                                      ),
                                      IncentiveItem(
                                        "Monthly",
                                        followBackFormController!
                                                .callBackTotalData.isNotEmpty
                                            ? followBackFormController!
                                                .callBackTotalData
                                                .first
                                                .monthlyCallbackTotal
                                                .toString()
                                            : '0',
                                      )
                                    ],
                                    statusColor: AppColors.greenCOlor,
                                  ),

                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     SizedBox(
                                  //       width:
                                  //           (MediaQuery.of(context).size.width -
                                  //                   32) /
                                  //               2,
                                  //       child: FileStatusCard(
                                  //         title: "Today Callback",
                                  //         fileCount: controller
                                  //                 .callBackCount.isNotEmpty
                                  //             ? controller.callBackCount.first
                                  //                 .todayCallback
                                  //                 .toString()
                                  //             : '0',
                                  //         statusColor: Colors.green,
                                  //         onPress: () {
                                  //           Get.to(AdminCallBack(
                                  //             title: 'Today',
                                  //             //   headerTitle: 'Today',
                                  //             // controller:
                                  //             //     followBackFormController,
                                  //             // getDataList: () =>
                                  //             //     followBackFormController!
                                  //             //         .dailycallbackData
                                  //           ));
                                  //         },
                                  //       ),
                                  //     ),
                                  //     // Monthly card
                                  //     SizedBox(
                                  //       width:
                                  //           (MediaQuery.of(context).size.width -
                                  //                   32) /
                                  //               2, // Half width minus padding
                                  //       child: FileStatusCard(
                                  //         title: "Monthly ",
                                  //         fileCount: controller
                                  //                 .callBackCount.isNotEmpty
                                  //             ? controller.callBackCount.first
                                  //                 .monthlyCallback
                                  //                 .toString()
                                  //             : '0',
                                  //         statusColor: Colors.blue,
                                  //         onPress: () {
                                  //           Get.to(CallBackData(
                                  //               title: 'Monthly Callback',
                                  //               headerTitle: 'Monthly',
                                  //               controller:
                                  //                   followBackFormController,
                                  //               getDataList: () =>
                                  //                   followBackFormController!
                                  //                       .monthlybackData));
                                  //         },
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),

                                  SizedBox(height: 10.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Login Request
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    32) /
                                                2,
                                        child: IncentiveCard(
                                            title: 'Login Request',
                                            isNextPage: true,
                                            onTap: () => Get.to(
                                                const DailyMonthlyCount(
                                                    title: 'Login Request')),
                                            items: [
                                              IncentiveItem(
                                                  "Today",
                                                  controller
                                                          .loginFileRequestCount
                                                          .first
                                                          .todaycount ??
                                                      '0'),
                                              IncentiveItem(
                                                  "Monthly",
                                                  controller
                                                          .loginFileRequestCount
                                                          .first
                                                          .monthlycount ??
                                                      '0'),
                                            ],
                                            statusColor: AppColors.greenCOlor),
                                      ),
                                      // Login Files
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    32) /
                                                2,
                                        child: IncentiveCard(
                                            title: 'Login Files',
                                            isNextPage: true,
                                            onTap: () => Get.to(
                                                const DailyMonthlyCount(
                                                    title: 'Login Files')),
                                            items: [
                                              IncentiveItem(
                                                  "Today",
                                                  controller.loginFileCount
                                                          .first.todaycount ??
                                                      '0'),
                                              IncentiveItem(
                                                  "Monthly",
                                                  controller.loginFileCount
                                                          .first.monthlycount ??
                                                      '0'),
                                            ],
                                            statusColor: AppColors.greenCOlor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  if (StaticStoredData.roleName !=
                                          'telecaller' &&
                                      controller.callLogCount.isNotEmpty) ...[
                                    IncentiveCard(
                                      title: 'Call Log',
                                      duration: controller
                                          .callLogCount.first.totalCallTime,
                                      isNextPage: true,
                                      onTap: () => Get.to(const AdminCallLog(
                                          title: 'Call Log')),
                                      items: [
                                        IncentiveItem(
                                          "Attempted",
                                          controller
                                              .callLogCount.first.callAttempt
                                              .toString(),
                                        ),
                                        IncentiveItem(
                                            "Connected",
                                            controller.callLogCount.first
                                                .callContacted
                                                .toString()),
                                        IncentiveItem(
                                            "Not Connected",
                                            controller.callLogCount.first
                                                .callNotcontact
                                                .toString()),
                                      ],
                                      statusColor: AppColors.greenCOlor,
                                    ),
                                  ],
                                  verticalSpace(30.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      FileStatusCard(
                                        title: "Disbursement",
                                        fileCount: (controller
                                                .loginFileStatusCount
                                                .first
                                                .disbursedfilecount)
                                            .toString(),
                                        amount: (controller.loginFileStatusCount
                                                .first.disbursedamount)
                                            .toString(),
                                        statusColor: Colors.blue,
                                        onPress: () {
                                          Get.to(const AdminDisbursement(
                                            title: 'Disbursement',
                                          ));
                                        },
                                      ),
                                      FileStatusCard(
                                        title: "Incentive",
                                        fileCount: '0',
                                        amount: '0',
                                        statusColor: Colors.yellow,
                                        onPress: () {},
                                      ),
                                    ],
                                  ),
                                ]))
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Obx(
                                  () => Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    32) /
                                                2,
                                            child: FileStatusCard(
                                              title: "Today",
                                              fileCount: controller
                                                      .callBackCount.isNotEmpty
                                                  ? controller.callBackCount
                                                      .first.todayCallback
                                                      .toString()
                                                  : '0',
                                              statusColor: Colors.green,
                                              onPress: () {
                                                Get.to(CallBackData(
                                                    title: 'Today',
                                                    headerTitle: 'Today',
                                                    controller:
                                                        followBackFormController,
                                                    getDataList: () =>
                                                        followBackFormController!
                                                            .dailycallbackData));
                                              },
                                            ),
                                          ),
                                          // Monthly card
                                          SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    32) /
                                                2, // Half width minus padding
                                            child: FileStatusCard(
                                              title: "Monthly",
                                              fileCount: controller
                                                      .callBackCount.isNotEmpty
                                                  ? controller.callBackCount
                                                      .first.monthlyCallback
                                                      .toString()
                                                  : '0',
                                              statusColor: Colors.blue,
                                              onPress: () {
                                                Get.to(CallBackData(
                                                    title: 'Monthly Callback',
                                                    headerTitle: 'Monthly',
                                                    controller:
                                                        followBackFormController,
                                                    getDataList: () =>
                                                        followBackFormController!
                                                            .monthlybackData));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      IncentiveCard(
                                          title: 'Incentives',
                                          items: [
                                            IncentiveItem("Target", "₹0"),
                                            IncentiveItem(
                                              "Achievement",
                                              _disbursementDetailsController
                                                      .disbursementList
                                                      .isNotEmpty
                                                  ? "₹${CurrencyUtils.formatAmount(_disbursementDetailsController.disbursementList.first.amount)}"
                                                  : "₹0",
                                            ),
                                            IncentiveItem("Incentive", "₹0"),
                                          ],
                                          statusColor: AppColors.greenCOlor)
                                    ],
                                  ),
                                ),
                              ),

                        verticalSpace(15.h),
                        // : verticalSpace(15.h),

                        // customContainer(40.h),

                        // unused designs

                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        //   // decoration: BoxDecoration(
                        //   //     border: Border.all(color: Colors.grey.shade300),
                        //   //     borderRadius: BorderRadius.circular(5)),
                        //   child: const Text(
                        //     'Login File Status',
                        //     style: TextStyle(
                        //         color: AppColors.textColor2,
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        // SizedBox(height: 5.h),
                        // Container(
                        //   padding: const EdgeInsets.all(5),
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(8),
                        //       border: Border.all(color: Colors.grey.shade400)),
                        //   child: Column(
                        //     children: [
                        //       Obx(
                        //         () => TabBar(
                        //             indicatorSize: TabBarIndicatorSize.tab,
                        //             indicatorWeight: 3.0,
                        //             // onTap: (_) {
                        //             //   controller.selectedIndex.value =
                        //             //       controller.tabController.index;
                        //             // },
                        //             controller: controller.tabController,
                        //             dividerColor: Colors.transparent,
                        //             indicatorColor: AppColors.backgroundColor,
                        //             indicator: BoxDecoration(
                        //                 color: AppColors.primaryColor,
                        //                 borderRadius: BorderRadius.circular(6),
                        //                 border:
                        //                     Border.all(color: AppColors.primaryColor)),
                        //             labelColor: Colors.white,
                        //             unselectedLabelColor: Colors.black,
                        //             padding: EdgeInsets.all(5.w),
                        //             tabs: [
                        //               Tab(
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 3, vertical: 3),
                        //                   child: Column(
                        //                     mainAxisSize: MainAxisSize.min,
                        //                     children: [
                        //                       Text(
                        //                           "Active - ${controller.totalActiveCount}"),
                        //                       Text(
                        //                         controller.priceFormatter(
                        //                             controller.totalValActive.value),
                        //                         style: const TextStyle(
                        //                             fontWeight: FontWeight.bold),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //               Tab(
                        //                 child: Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 5, vertical: 3),
                        //                   child: Column(
                        //                     mainAxisSize: MainAxisSize.max,
                        //                     children: [
                        //                       Text(
                        //                           "InActive - ${controller.totalInActiveCount}"),
                        //                       Text(
                        //                         controller.priceFormatter(
                        //                             controller.totalNoValActive.value),
                        //                         style: const TextStyle(
                        //                             fontWeight: FontWeight.bold),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ),
                        //             ]),
                        //       ),
                        //       Obx(
                        //         () => SizedBox(
                        //           height: (controller.activeList.isNotEmpty ||
                        //                   controller.inActiveList.isNotEmpty)
                        //               ? (controller.selectedIndex.value == 0
                        //                   ? controller.activeList.length *
                        //                       controller.itemHeight
                        //                   : controller.inActiveList.length *
                        //                       controller.itemHeight)
                        //               : 100,
                        //           child: TabBarView(
                        //               controller: controller.tabController,
                        //               // physics:
                        //               //     const NeverScrollableScrollPhysics(),
                        //               children: [
                        //                 controller.activeList.isNotEmpty
                        //                     ? ListView.builder(
                        //                         padding: EdgeInsets.zero,
                        //                         shrinkWrap: true,
                        //                         physics:
                        //                             const NeverScrollableScrollPhysics(),
                        //                         itemCount: controller.activeList.length,
                        //                         itemBuilder: (context, index) {
                        //                           final item =
                        //                               controller.activeList[index];
                        //                           return Material(
                        //                             color: Colors.transparent,
                        //                             child: InkWell(
                        //                               onTap: () {
                        //                                 dataController.selectedStatuses
                        //                                     .clear();
                        //                                 dataController.selectedStatuses
                        //                                     .add(item.id
                        //                                         .toString()
                        //                                         .toUpperCase());
                        //                                 dataController
                        //                                     .applyStatusFilter();
                        //                                 Get.to(() => DataEntryViewScreen(
                        //                                       showBack: true,
                        //                                     ));
                        //                               },
                        //                               child: Container(
                        //                                 padding:
                        //                                     const EdgeInsets.symmetric(
                        //                                         vertical: 5,
                        //                                         horizontal: 12),
                        //                                 margin:
                        //                                     const EdgeInsets.symmetric(
                        //                                         vertical: 2,
                        //                                         horizontal: 4),
                        //                                 decoration: BoxDecoration(
                        //                                   color: Colors.white,
                        //                                   borderRadius:
                        //                                       BorderRadius.circular(10),
                        //                                   boxShadow: [
                        //                                     BoxShadow(
                        //                                       color: Colors.grey
                        //                                           .withOpacity(0.2),
                        //                                       spreadRadius: 1,
                        //                                       blurRadius: 5,
                        //                                       offset: const Offset(0, 2),
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                                 child: Row(
                        //                                   mainAxisAlignment:
                        //                                       MainAxisAlignment.start,
                        //                                   children: [
                        //                                     Expanded(
                        //                                       flex: 3,
                        //                                       child: Column(
                        //                                         crossAxisAlignment:
                        //                                             CrossAxisAlignment
                        //                                                 .start,
                        //                                         children: [
                        //                                           Text(
                        //                                             controller.capitalizeWords(item
                        //                                                 .StatusGroupModelName!
                        //                                                 .toLowerCase()),
                        //                                             style:
                        //                                                 const TextStyle(
                        //                                               fontWeight:
                        //                                                   FontWeight.bold,
                        //                                               color: AppColors
                        //                                                   .textColor2,
                        //                                             ),
                        //                                             overflow: TextOverflow
                        //                                                 .ellipsis,
                        //                                           ),
                        //                                           Text(
                        //                                             '${item.filecount} files',
                        //                                             style:
                        //                                                 const TextStyle(
                        //                                               fontWeight:
                        //                                                   FontWeight.w600,
                        //                                               color: AppColors
                        //                                                   .appBarColor,
                        //                                             ),
                        //                                             overflow: TextOverflow
                        //                                                 .ellipsis,
                        //                                           ),
                        //                                         ],
                        //                                       ),
                        //                                     ),
                        //                                     // Expanded(
                        //                                     //   flex: 2,
                        //                                     //   child: Text(
                        //                                     //     '${item.filecount} files',
                        //                                     //     style:
                        //                                     //         const TextStyle(
                        //                                     //       fontWeight:
                        //                                     //           FontWeight
                        //                                     //               .w600,
                        //                                     //       color: AppColors
                        //                                     //           .appBarColor,
                        //                                     //     ),
                        //                                     //     overflow:
                        //                                     //         TextOverflow
                        //                                     //             .ellipsis,
                        //                                     //   ),
                        //                                     // ),
                        //                                     Expanded(
                        //                                       flex: 1,
                        //                                       child: Text(
                        //                                         controller.priceFormatter(
                        //                                             item.totalLoanAmount),
                        //                                         textAlign: TextAlign.end,
                        //                                         style: const TextStyle(
                        //                                           fontSize: 13,
                        //                                           fontWeight:
                        //                                               FontWeight.bold,
                        //                                           color: AppColors
                        //                                               .textColor2,
                        //                                         ),
                        //                                       ),
                        //                                     ),
                        //                                   ],
                        //                                 ),
                        //                               ),
                        //                             ),
                        //                           );
                        //                         },
                        //                       )
                        //                     : const Center(
                        //                         child: Text("No Active Cases")),
                        //                 controller.inActiveList.isNotEmpty
                        //                     ? ListView.builder(
                        //                         padding: EdgeInsets.zero,
                        //                         shrinkWrap: true,
                        //                         physics:
                        //                             const NeverScrollableScrollPhysics(), // ✅ disable inner scroll
                        //                         itemCount: controller.inActiveList.length,
                        //                         itemBuilder: (context, index) {
                        //                           final item =
                        //                               controller.inActiveList[index];
                        //                           return GestureDetector(
                        //                             onTap: () {
                        //                               dataController.selectedStatuses
                        //                                   .clear();
                        //                               dataController.selectedStatuses.add(
                        //                                   item.id
                        //                                       .toString()
                        //                                       .toUpperCase());
                        //                               dataController.applyStatusFilter();
                        //                               Get.to(() => DataEntryViewScreen(
                        //                                     showBack: true,
                        //                                   ));
                        //                             },
                        //                             child: Container(
                        //                               padding: const EdgeInsets.symmetric(
                        //                                   vertical: 5, horizontal: 12),
                        //                               margin: const EdgeInsets.symmetric(
                        //                                   vertical: 2, horizontal: 4),
                        //                               decoration: BoxDecoration(
                        //                                 color: Colors.white,
                        //                                 borderRadius:
                        //                                     BorderRadius.circular(10),
                        //                                 boxShadow: [
                        //                                   BoxShadow(
                        //                                     color: Colors.grey
                        //                                         .withOpacity(0.2),
                        //                                     spreadRadius: 1,
                        //                                     blurRadius: 5,
                        //                                     offset: const Offset(0, 2),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                               child: Row(
                        //                                 children: [
                        //                                   Expanded(
                        //                                     flex: 4,
                        //                                     child: Column(
                        //                                       crossAxisAlignment:
                        //                                           CrossAxisAlignment
                        //                                               .start,
                        //                                       children: [
                        //                                         Text(
                        //                                           item.StatusGroupModelName ??
                        //                                               "",
                        //                                           style: const TextStyle(
                        //                                             fontWeight:
                        //                                                 FontWeight.bold,
                        //                                             color: AppColors
                        //                                                 .textColor2,
                        //                                           ),
                        //                                           overflow: TextOverflow
                        //                                               .ellipsis,
                        //                                         ),
                        //                                         Text(
                        //                                           '${item.filecount} files',
                        //                                           style: const TextStyle(
                        //                                             fontWeight:
                        //                                                 FontWeight.w600,
                        //                                             color: AppColors
                        //                                                 .appBarColor,
                        //                                           ),
                        //                                           overflow: TextOverflow
                        //                                               .ellipsis,
                        //                                         ),
                        //                                       ],
                        //                                     ),
                        //                                   ),
                        //                                   // Expanded(
                        //                                   //   flex: 2,
                        //                                   //   child: Text(
                        //                                   //     '${item.filecount} files',
                        //                                   //     style:
                        //                                   //         const TextStyle(
                        //                                   //       fontWeight:
                        //                                   //           FontWeight
                        //                                   //               .w600,
                        //                                   //       color: AppColors
                        //                                   //           .appBarColor,
                        //                                   //     ),
                        //                                   //     overflow:
                        //                                   //         TextOverflow
                        //                                   //             .ellipsis,
                        //                                   //   ),
                        //                                   // ),
                        //                                   Expanded(
                        //                                     flex: 2,
                        //                                     child: Text(
                        //                                       controller.priceFormatter(
                        //                                           item.totalLoanAmount),
                        //                                       textAlign: TextAlign.end,
                        //                                       style: const TextStyle(
                        //                                         fontSize: 13,
                        //                                         fontWeight:
                        //                                             FontWeight.bold,
                        //                                         color:
                        //                                             AppColors.textColor2,
                        //                                       ),
                        //                                     ),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             ),
                        //                           );
                        //                         },
                        //                       )
                        //                     : const Center(
                        //                         child: Text("No  IActive Cases")),
                        //               ]),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 15.h),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        //   // decoration: BoxDecoration(
                        //   //     border: Border.all(color: Colors.grey.shade300),
                        //   //     borderRadius: BorderRadius.circular(5)),
                        //   child: Text(
                        //     tellecallerLabels,
                        //     style: const TextStyle(
                        //         color: AppColors.textColor2,
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        // SizedBox(height: 5.h),
                        // Container(
                        //   padding: const EdgeInsets.all(8),
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(8),
                        //     border: Border.all(color: Colors.grey.shade400),
                        //   ),
                        //   child: Column(children: [
                        //     TabBar(
                        //         isScrollable: false,
                        //         indicatorPadding: EdgeInsets.zero,
                        //         padding: EdgeInsets.zero,
                        //         onTap: (value) {
                        //           StaticStoredData.roleName == "telecaller"
                        //               ? controller.loadTodayAndMonthlyData(value)
                        //               : controller.loadtellecallerTabData(value);
                        //         },
                        //         indicatorSize: TabBarIndicatorSize.tab,
                        //         controller: followBackFormController.callController,
                        //         labelPadding: EdgeInsets.zero,
                        //         labelStyle: const TextStyle(
                        //             fontSize: 13, fontWeight: FontWeight.bold),
                        //         dividerColor: Colors.transparent,
                        //         indicatorColor: AppColors.backgroundColor,
                        //         indicator: BoxDecoration(
                        //             color: AppColors.primaryColor,
                        //             borderRadius: BorderRadius.circular(6),
                        //             border: Border.all(color: AppColors.primaryColor)),
                        //         labelColor: Colors.white,
                        //         unselectedLabelColor: Colors.black,
                        //         tabs: StaticStoredData.roleName == 'telecaller'
                        //             ? callBackTabFortellecaller
                        //             : callBackTabForAdmin),

                        //     SizedBox(height: 5.h),

                        //     /// TabBarView Content

                        //     // final selectedIndex = followBackFormController
                        //     //     .selectedIndex.value;
                        //     // int length = 0;

                        //     // double cardHeight =
                        //     //     StaticStoredData.roleName == 'tellecaller'
                        //     //         ? followBackFormController
                        //     //             .tellececalleritemHeight
                        //     //         : followBackFormController
                        //     //             .tellececalleritemHeight;

                        //     // if (selectedIndex == 0) {
                        //     //   length = followBackFormController
                        //     //       .dailycallbackData
                        //     //       .map((e) => e.tcname)
                        //     //       .toSet()
                        //     //       .length;
                        //     // } else if (selectedIndex == 1) {
                        //     //   length = followBackFormController
                        //     //       .callLogData.length;
                        //     // } else if (selectedIndex == 2) {
                        //     //   length = followBackFormController
                        //     //           .disbursementList.length +
                        //     //       2;
                        //     // }

                        //     // final height = length > 0
                        //     //     ? (length * cardHeight).toDouble()
                        //     //     : 100.0;

                        //     SizedBox(
                        //       height: 500.h,
                        //       child: TabBarView(
                        //           physics: const ScrollPhysics(),
                        //           controller: followBackFormController.callController,
                        //           children: StaticStoredData.roleName == 'telecaller'
                        //               ? callBackTabBarFortellecaller
                        //               : callBackTabBarForAdmin),
                        //     ),

                        //     SizedBox(
                        //       height: 6.h,
                        //     ),

                        //     const SizedBox(height: 15),
                        //   ]),
                        // )
                        //  ]
                      ]);
                      // }
                    }),
                  ),
          ),
        ),
      ),
    );
  }

  String maskFirst6Digits(String number) {
    if (number.length < 6) return number; // Handle edge case
    return 'xxxxxx${number.substring(6)}';
  }

  Widget dashboardStatCard({
    required String iconPath,
    required String value,
    required String label,
    //  required String duration,
    Color? textColor,
    Color? iconColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon + Value
        Center(
          child: SvgPicture.asset(
            iconPath,
            color: iconColor,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }

  Widget performer(String imageurl, String profileImage,
      String performerDuration, String name, String amount) {
    return Column(
      children: [
        Container(
            width: 160.w,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(imageurl),
                  fit: BoxFit.fitWidth), // makes it fill nicely),
              borderRadius: BorderRadius.circular(6),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Image with white border
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white, // border color
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: ImageHelper.getImageProvider(
                        profileImage: profileImage, // string from API
                        fallbackUrl:
                            "https://ui-avatars.com/api/?name=$name&background=random&color=fff",
                        baseUrl: APIUrls.imagebaseUrl,
                        assetPath: "assets/images/user.png",
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Name & Amount
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${CurrencyUtils.formatAmount(amount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),

                  // Performer Duration
                ])),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            performerDuration,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget loginStatusCard(
    final String title,
    final String fileCount,
    final String amount,
    final Color statusColor,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row with colored dot and arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.black54),
            ],
          ),

          const SizedBox(height: 4),

          // File Count
          Text(
            "$fileCount Files",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 12),

          // Amount
          Text(
            "₹${CurrencyUtils.formatIndianCurrency(amount)}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget dailyCallBack() {
  //   return Obx(() {
  //     final uniqueTcNames = followBackFormController.dailycallbackData
  //         .map((e) => e.tcname)
  //         .toList();
  //     return followBackFormController.isdailyCallLoading.value
  //         ? const LoadingPage()
  //         : ListView.builder(
  //             padding: EdgeInsets.zero,
  //             itemCount: uniqueTcNames.length,
  //             shrinkWrap: true,
  //             physics: const ScrollPhysics(),
  //             itemBuilder: (context, index) {
  //               final item = followBackFormController
  //                   .dailycallbackData[index]; // Use the passed list

  //               return Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Colors.grey.shade300, width: 1),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: ExpansionTile(
  //                   minTileHeight: 60,
  //                   tilePadding:
  //                       EdgeInsets.symmetric(horizontal: 10.h, vertical: 0.0),
  //                   shape: const RoundedRectangleBorder(
  //                     side: BorderSide(color: Colors.transparent, width: 0),
  //                   ),
  //                   childrenPadding: EdgeInsets.zero,
  //                   expandedCrossAxisAlignment: CrossAxisAlignment.start,
  //                   initiallyExpanded: false,
  //                   dense: true,
  //                   showTrailingIcon: true,
  //                   leading: GestureDetector(
  //                       onTap: () {
  //                         if (!_dialerController.isCallOngoing.value) {
  //                           _dialerController.makePhoneCall(
  //                               item.contactNumber.toString(),
  //                               followUpId: item.id ?? '');
  //                         }

  //                         followBackFormController.mobile.value =
  //                             item.contactNumber ?? "";
  //                         followBackFormController.bankName.value =
  //                             item.bankName ?? "";
  //                         followBackFormController.customerName.value =
  //                             item.customerName ?? "";
  //                         _dialerController.customerName.value =
  //                             item.customerName ?? '';
  //                         // _dialerController.customerLoan.value =
  //                         //     '';
  //                         // _dialerController.customerName.value =
  //                         //     item.customerName ?? "";
  //                         _dialerController.datatype.value = '';
  //                         followBackFormController.remark.value =
  //                             item.remark ?? '';
  //                         _dialerController.followup_id.value = item.id ?? '';
  //                         _dialerController.excel_id.value = '';
  //                       },
  //                       child: SvgPicture.asset('assets/images/dialler.svg')),
  //                   title: Text(
  //                     item.customerName.toString(),
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   subtitle: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         maskFirst6Digits(item.contactNumber.toString()),
  //                         style: const TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       Text(
  //                         DateFormat('dd-MM-yy hh:mm:ss a').format(
  //                             DateTime.parse(item.entryDate.toString())),
  //                         style: const TextStyle(fontSize: 10),
  //                       ),
  //                     ],
  //                   ),
  //                   trailing: const Icon(Icons.keyboard_arrow_down),
  //                   children: [
  //                     _buildSingleRow(Icons.comment, item.remark ?? 'NA'),
  //                   ],
  //                 ),
  //               );
  //             });
  //   });
  // }

  // Widget monthlyCallBack() {
  //   return Obx(() {
  //     final uniqueTcNames = followBackFormController.monthlybackData
  //         .map((e) => e.contactNumber)
  //         .toSet()
  //         .toList();
  //     return followBackFormController.isMonthlyCallLoading.value
  //         ? const LoadingPage()
  //         : ListView.builder(
  //             padding: EdgeInsets.zero,
  //             itemCount: uniqueTcNames.length,
  //             shrinkWrap: true,
  //             physics: const ScrollPhysics(),
  //             itemBuilder: (context, index) {
  //               final item = followBackFormController
  //                   .monthlybackData[index]; // Use the passed list

  //               return Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Colors.grey.shade300, width: 1),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: ExpansionTile(
  //                   minTileHeight: 60,
  //                   tilePadding:
  //                       EdgeInsets.symmetric(horizontal: 10.h, vertical: 0.0),
  //                   shape: const RoundedRectangleBorder(
  //                     side: BorderSide(color: Colors.transparent, width: 0),
  //                   ),
  //                   childrenPadding: EdgeInsets.zero,
  //                   expandedCrossAxisAlignment: CrossAxisAlignment.start,
  //                   initiallyExpanded: false,
  //                   dense: true,
  //                   showTrailingIcon: true,
  //                   leading: GestureDetector(
  //                       onTap: () {
  //                         if (!_dialerController.isCallOngoing.value) {
  //                           _dialerController.makePhoneCall(
  //                               item.contactNumber.toString(),
  //                               followUpId: item.id ?? '');
  //                         }

  //                         followBackFormController.mobile.value =
  //                             item.contactNumber ?? "";
  //                         followBackFormController.bankName.value =
  //                             item.bankName ?? "";
  //                         followBackFormController.customerName.value =
  //                             item.customerName ?? "";
  //                         _dialerController.customerName.value =
  //                             item.customerName ?? '';
  //                         // _dialerController.customerLoan.value =
  //                         //     '';
  //                         // _dialerController.customerName.value =
  //                         //     item.customerName ?? "";
  //                         _dialerController.datatype.value = '';
  //                         followBackFormController.remark.value =
  //                             item.remark ?? '';
  //                         _dialerController.followup_id.value = item.id ?? '';
  //                         _dialerController.excel_id.value = '';
  //                       },
  //                       child: SvgPicture.asset('assets/images/dialler.svg')),
  //                   title: Text(
  //                     item.customerName.toString(),
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   subtitle: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         maskFirst6Digits(item.contactNumber.toString()),
  //                         style: const TextStyle(fontWeight: FontWeight.bold),
  //                       ),
  //                       Text(
  //                         DateFormat('dd-MM-yy hh:mm:ss a').format(
  //                             DateTime.parse(item.entryDate.toString())),
  //                         style: const TextStyle(fontSize: 10),
  //                       ),
  //                     ],
  //                   ),
  //                   trailing: const Icon(Icons.keyboard_arrow_down),
  //                   children: [
  //                     _buildSingleRow(Icons.comment, item.remark ?? 'NA'),
  //                   ],
  //                 ),
  //               );
  //             });
  //   });
  // }

  // Widget callback(IconData data) {
  //   return Obx(() {
  //     final uniqueTcNames = followBackFormController.callBackData
  //         .map((e) => e.name)
  //         .toSet()
  //         .toList();

  //     final totaldata = followBackFormController.callBackTotalData.first;

  //     return followBackFormController.iscallBackLoading.value
  //         ? const LoadingPage()
  //         : Column(
  //             children: [
  //               Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
  //                 padding: EdgeInsets.symmetric(vertical: 4.h),
  //                 decoration: BoxDecoration(
  //                   color: Colors.blue.shade50,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Colors.grey.shade300, width: 1),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Padding(
  //                   padding: EdgeInsets.symmetric(vertical: 4.h),
  //                   child: ListTile(
  //                     dense: true,
  //                     leading: CircleAvatar(
  //                       radius: 23,
  //                       backgroundColor: AppColors.primaryColor,
  //                       child: data != null
  //                           ? Icon(data, color: Colors.white)
  //                           : const Text(
  //                               'T',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ), // you can change color
  //                     ),
  //                     title: const Text(
  //                       'Total',
  //                       style: TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     trailing: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text('Today- ${totaldata.todayCallbackTotal}'),
  //                         Text('Monthly -${totaldata.monthlyCallbackTotal}')
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: ListView.builder(
  //                     padding: EdgeInsets.zero,
  //                     itemCount: uniqueTcNames.length,
  //                     physics: const BouncingScrollPhysics(),
  //                     itemBuilder: (context, index) {
  //                       // 👇 Remaining rows → CallBackData
  //                       final item = followBackFormController.callBackData[
  //                           index]; // subtract 1 because first row is totals

  //                       return Container(
  //                         margin: const EdgeInsets.symmetric(
  //                             vertical: 5, horizontal: 6),
  //                         padding: EdgeInsets.symmetric(vertical: 7.h),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(12),
  //                           border: Border.all(
  //                               color: Colors.grey.shade300, width: 1),
  //                           boxShadow: const [
  //                             BoxShadow(
  //                               color: Colors.black12,
  //                               blurRadius: 4,
  //                               offset: Offset(0, 2),
  //                             ),
  //                           ],
  //                         ),
  //                         child: Padding(
  //                           padding: EdgeInsets.zero,
  //                           child: ListTile(
  //                             dense: true,
  //                             contentPadding: EdgeInsets.symmetric(
  //                                 horizontal: 15.w, vertical: 0.8.h),
  //                             leading: CircleAvatar(
  //                               radius: 23,
  //                               backgroundImage: ImageHelper.getImageProvider(
  //                                 profileImage:
  //                                     item.profileImage, // string from API
  //                                 fallbackUrl:
  //                                     "https://ui-avatars.com/api/?name=${item.name}&background=random&color=fff",
  //                                 // profileController.profileImageUrl.value,
  //                                 baseUrl: APIUrls.imagebaseUrl,
  //                                 assetPath: "assets/images/user.png",
  //                               ),
  //                             ),
  //                             //  CircleAvatar(
  //                             //   radius: 23,
  //                             //   backgroundColor: AppColors.primaryColor,
  //                             //   child: data != null
  //                             //       ? Icon(data, color: Colors.white)
  //                             //       : Text(
  //                             //           item.name[index].isNotEmpty
  //                             //               ? item.name[index][0].toUpperCase()
  //                             //               : "?",
  //                             //           style: const TextStyle(
  //                             //             color: Colors.white,
  //                             //             fontWeight: FontWeight.bold,
  //                             //           ),
  //                             //         ), // you can change color
  //                             // ),
  //                             title: Text(
  //                               followBackFormController
  //                                   .callBackData[index].name,
  //                               style: const TextStyle(
  //                                   fontWeight: FontWeight.bold),
  //                             ),
  //                             trailing: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text('Today- ${item.todayCallbackCount}'),
  //                                 Text('Monthly -${item.monthlyCallbackCount}')
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     }),
  //               ),
  //             ],
  //           );
  //   });
  // }

  // Widget callLog(IconData data) {
  //   return Obx(() {
  //     final uniqueTcNames = followBackFormController.callLogData
  //         .map((e) => e.name)
  //         .toSet()
  //         .toList();

  //     return followBackFormController.iscallLogLoading.value
  //         ? const LoadingPage()
  //         : ListView.builder(
  //             itemCount: uniqueTcNames.length,
  //             padding: EdgeInsets.zero,
  //             physics: const BouncingScrollPhysics(),
  //             itemBuilder: (context, index) {
  //               final callData = followBackFormController.callLogData[index];

  //               return Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
  //                 decoration: BoxDecoration(
  //                   color: index == 0 ? Colors.blue.shade50 : Colors.white,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Colors.grey.shade300, width: 1),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Padding(
  //                   padding: EdgeInsets.zero,
  //                   child: ListTile(
  //                     dense: true,
  //                     contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
  //                     leading: CircleAvatar(
  //                       radius: 23,
  //                       backgroundColor: AppColors.primaryColor,
  //                       // ignore: unnecessary_null_comparison
  //                       child: CircleAvatar(
  //                         radius: 40,
  //                         backgroundImage: ImageHelper.getImageProvider(
  //                           profileImage:
  //                               callData.profileImage, // string from API
  //                           fallbackUrl:
  //                               "https://ui-avatars.com/api/?name=${callData.name}&background=random&color=fff",
  //                           baseUrl: APIUrls.imagebaseUrl,
  //                           assetPath: "assets/images/user.png",
  //                         ),
  //                       ), // you can change color
  //                     ),
  //                     title: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           callData.name.toString(),
  //                           style: const TextStyle(fontWeight: FontWeight.bold),
  //                         ),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             SizedBox(
  //                               width: 75.w,
  //                               child: Text(
  //                                 callData.totalCallTime,
  //                                 style: TextStyle(fontSize: 12.sp),
  //                                 textAlign: TextAlign.start,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     subtitle: Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       mainAxisSize: MainAxisSize.max,
  //                       children: [
  //                         const SizedBox(height: 10),
  //                         Expanded(
  //                           child: Container(
  //                             width: 35.w,
  //                             alignment: Alignment.bottomLeft,
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 SvgPicture.asset(
  //                                   'assets/images/dashboard_attempted.svg',
  //                                   width: 12,
  //                                   height: 12,
  //                                 ),
  //                                 SizedBox(width: 5.w),
  //                                 Text(
  //                                   callData.callAttempt,
  //                                   style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 25.w,
  //                         ),
  //                         Expanded(
  //                           child: SizedBox(
  //                             width: 35.w,
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 SvgPicture.asset(
  //                                     'assets/images/dashboard_connected.svg',
  //                                     height: 12,
  //                                     width: 12),
  //                                 SizedBox(width: 5.w),
  //                                 Text(
  //                                   callData.callContacted,
  //                                   style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 25.w,
  //                         ),
  //                         Expanded(
  //                           child: SizedBox(
  //                             width: 35.w,
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.start,
  //                               children: [
  //                                 SvgPicture.asset(
  //                                     'assets/images/dashboard_not_connected.svg',
  //                                     height: 12,
  //                                     width: 12),
  //                                 SizedBox(width: 5.w),
  //                                 Text(
  //                                   callData.callNotcontact,
  //                                   style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 25.w,
  //                         ),
  //                       ],
  //                     ),
  //                     // trailing: Column(
  //                     //   mainAxisAlignment: MainAxisAlignment.start,
  //                     //   children: [
  //                     //     Text(
  //                     //       callData.totalCallTime,
  //                     //       style: TextStyle(fontSize: 12.sp),
  //                     //       textAlign: TextAlign.end,
  //                     //     ),
  //                     //   ],
  //                     // ),
  //                   ),
  //                 ),
  //               );
  //             });
  //   });
  // }

  // Widget callDisbursement(IconData data) {
  //   return Obx(() {
  //     final uniqueTcNames = followBackFormController.disbursementList
  //         .map((e) => e.name)
  //         .toSet()
  //         .toList();
  //     final totaldata = followBackFormController.disbursementTotal.isNotEmpty
  //         ? followBackFormController.disbursementTotal.first
  //         : null;

  //     return followBackFormController.iscallDisbursedLoading.value
  //         ? const LoadingPage()
  //         : Column(
  //             children: [
  //               Container(
  //                 margin:
  //                     const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
  //                 decoration: BoxDecoration(
  //                   color: Colors.blue.shade50,
  //                   borderRadius: BorderRadius.circular(12),
  //                   border: Border.all(color: Colors.grey.shade300, width: 1),
  //                   boxShadow: const [
  //                     BoxShadow(
  //                       color: Colors.black12,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: ListTile(
  //                   contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
  //                   dense: true,
  //                   leading: CircleAvatar(
  //                       radius: 23,
  //                       backgroundColor: AppColors.primaryColor,
  //                       child: Icon(data, color: Colors.white)),
  //                   title: const Text(
  //                     'Total',
  //                     style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                   subtitle:
  //                       Text('Login Files -${totaldata?.loginCountTotal ?? 0}'),
  //                   trailing: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Text(controller
  //                           .priceFormatter(totaldata?.amountTotal ?? 0)),
  //                       SizedBox(height: 10.h),
  //                       Text(
  //                           'Disbursed File - ${totaldata?.disbursedCountTotal ?? 0}'),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: ListView.builder(
  //                     padding: EdgeInsets.zero,
  //                     itemCount: uniqueTcNames.length,
  //                     physics: const BouncingScrollPhysics(),
  //                     itemBuilder: (context, index) {
  //                       final disbursementData =
  //                           followBackFormController.disbursementList;

  //                       return Container(
  //                         margin: const EdgeInsets.symmetric(
  //                             vertical: 5, horizontal: 6),
  //                         decoration: BoxDecoration(
  //                           color: Colors.white,
  //                           borderRadius: BorderRadius.circular(12),
  //                           border: Border.all(
  //                               color: Colors.grey.shade300, width: 1),
  //                           boxShadow: const [
  //                             BoxShadow(
  //                               color: Colors.black12,
  //                               blurRadius: 4,
  //                               offset: Offset(0, 2),
  //                             ),
  //                           ],
  //                         ),
  //                         child: Padding(
  //                           padding: EdgeInsets.zero,
  //                           child: ListTile(
  //                             dense: true,
  //                             contentPadding:
  //                                 EdgeInsets.symmetric(horizontal: 10.w),
  //                             leading: CircleAvatar(
  //                               radius: 23,
  //                               backgroundColor: AppColors.primaryColor,
  //                               // ignore: unnecessary_null_comparison
  //                               child: CircleAvatar(
  //                                 radius: 40,
  //                                 backgroundImage: ImageHelper.getImageProvider(
  //                                   profileImage: disbursementData[index]
  //                                       .profileImage, // string from API
  //                                   fallbackUrl:
  //                                       "https://ui-avatars.com/api/?name=${disbursementData[index].name}&background=random&color=fff",
  //                                   baseUrl: APIUrls.imagebaseUrl,
  //                                   assetPath: "assets/images/user.png",
  //                                 ),
  //                               ), // you can change color
  //                             ),
  //                             title: Text(
  //                               disbursementData[index].name,
  //                               style: const TextStyle(
  //                                   fontWeight: FontWeight.bold),
  //                             ),
  //                             subtitle: Text(
  //                                 'Login Files -${disbursementData[index].loginCount}'),
  //                             trailing: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.end,
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Text(controller.priceFormatter(
  //                                     disbursementData[index].amount)),
  //                                 SizedBox(height: 10.h),
  //                                 Text(
  //                                     'Disbursed File - ${disbursementData[index].disbursedCount}'),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     }),
  //               ),
  //             ],
  //           );
  //   });
  // }

  showDatePicker() async {
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
      ),
      dialogSize: const Size(325, 400),
      value: controller.dateRangeList,
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null) {
      if (results.first == results.last) {
        controller.dateRangeList.clear();
        controller.dateRangeList.add(results.first);
      } else {
        controller.dateRangeList.value = results;
      }
      controller.formateDate();

      if (controller.dateRangeList.length != 1) {
        DateTime? date = controller.dateRangeList.first;
        DateTime? lDate = controller.dateRangeList.last;
        // if(date!=null){
        controller.dateRange.value =
            "${date?.day}-${date?.month}-${lDate?.year},${lDate?.day}-${lDate?.month}-${date?.year}";
        print(controller.dateRange.value);
      } else {
        DateTime? date = controller.dateRangeList.first;
        if (date != null) {
          controller.dateRange.value =
              "${date.day}-${date.month}-${date.year},${date.day}-${date.month}-${date.year}";
        }
      }
      await controller.getTimeGraph();
    }
  }

  Widget headerTitleWithContainer(String title) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: AppColors.appBarTextColor,
        child: Text(
          title,
          style: AppTextStyle.headerTitle,
        ));
  }

  Widget customContainer(double height) {
    return Container(
        decoration: const BoxDecoration(color: AppColors.appBarTextColor),
        height: height);
  }

  Widget headerTitle(String title, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Text(title, style: style),
    );
  }

  Widget headerTitles(String title, TextStyle style) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Obx(
        () => Text(
          title,
          style: style.copyWith(
            color: themeController.primaryColor.value, // 👈 dynamic
          ),
        ),
      ),
    );
  }

  Widget verticalSpace(double h) => SizedBox(height: h);
  Widget subHeaderTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        title,
        style: AppTextStyle.hintText,
      ),
    );
  }

  Widget disbursementCard(String month, String amount) {
    return Container(
      width: 115.w,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            month,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyUtils.formatIndianCurrency(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSingleRow(IconData icon, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
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

class DashboardSection extends StatefulWidget {
  final String? amount;
  final String title;
  final Data? data;
  final DashboardController controller;
  final List<StatusGroupModel> list;
  final String graphLabel;

  const DashboardSection(
      {Key? key,
      required this.amount,
      required this.graphLabel,
      required this.title,
      required this.data,
      required this.controller,
      required this.list})
      : super(key: key);

  @override
  State<DashboardSection> createState() => _DashboardSectionState();
}

class _DashboardSectionState extends State<DashboardSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "${widget.amount}",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // controller.buildChunkedGrid(list, 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 32),
            child: DataTable(
              dataRowHeight: 30,
              horizontalMargin: 10,
              headingRowHeight: 35,
              clipBehavior: Clip.hardEdge,
              headingRowColor: WidgetStatePropertyAll(
                  AppColors.primaryColor.withOpacity(.7)),
              columnSpacing: 15.0,
              border: TableBorder.all(
                  color: Colors.black,
                  width: 0.5,
                  borderRadius: BorderRadius.circular(13)),
              columns: [
                DataColumn(
                    headingRowAlignment: MainAxisAlignment.center,
                    label: Text(
                      widget.graphLabel,
                      style: const TextStyle(color: Colors.white),
                    )),
                const DataColumn(
                    headingRowAlignment: MainAxisAlignment.center,
                    label: Text(
                      "Amount",
                      style: TextStyle(color: Colors.white),
                    )),
                const DataColumn(
                    headingRowAlignment: MainAxisAlignment.center,
                    label: Text(
                      "Files",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
              rows: widget.list.asMap().entries.map((entry) {
                // val+=1;
                final index = entry.key;
                final row = entry.value;
                return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        // Alternate row color for even indexes
                        return index.isEven
                            ? Colors.white
                                .withOpacity(0.1) // Define your color here
                            : AppColors.primaryColor
                                .withOpacity(.3); // Default color for odd rows
                      },
                    ),
                    cells: [
                      DataCell(Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    index == widget.list.length - 1 ? 13 : 0))),
                        child: Text(
                          row.StatusGroupModelName ?? '',
                          style:
                              TextStyle(fontSize: 13.sp, color: Colors.black),
                        ),
                      )),
                      DataCell(Container(
                        alignment: Alignment.center,
                        child: Text(
                            widget.controller
                                .priceFormatter("${row.totalLoanAmount ?? ''}"),
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.black)),
                      )),
                      DataCell(Container(
                        alignment: Alignment.center,
                        child: Text(row.filecount ?? '',
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.black)),
                      ))
                    ]);
              }).toList(),
            ),
          ),
        ),
        // Row(
        //   children: [
        //    const Flexible(
        //       child: DashboardCardNew(
        //         icon: Icons.file_copy_sharp,
        //         title: "Document Sent",
        //         count: "Rs. 25,000 2 files",
        //         backgroundColor: const Color(0xFFE3F2FD),
        //       ),
        //     ),
        //     SizedBox(width: 12.w,),
        //    const Flexible(
        //       child: DashboardCardNew(
        //         icon: Icons.file_copy_sharp,
        //         title: "Login Process",
        //         count: "Rs. 30,000 4 files",
        //         backgroundColor: const Color(0xFFE3F2FD),
        //       ),
        //     ),
        //   ],
        // ),

        //    SingleChildScrollView(
        //      scrollDirection: Axis.horizontal,
        //      child: Row(
        //        children: [
        //          const DashboardCardNew(
        //            icon: Icons.file_copy_sharp,
        //            fileCount: "2",
        //            title: "Document Sent",
        //            count: "25,000",
        //            backgroundColor:  Color(0xFFE3F2FD),
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            icon: Icons.file_copy_sharp,
        //            title: "Login Process",
        //            count: "30,000",
        //            fileCount: '4',
        //            backgroundColor: const Color(0xFFE1F5FE),
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            fileCount: '2',
        //            icon: Icons.file_copy_sharp,
        //            title: "Query",
        //            count: "0",
        //            backgroundColor: const Color(0xFFFFF8E1),
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            fileCount: "3",
        //            icon: Icons.file_copy_sharp,
        //            title: "Login Done",
        //            count: "30,000",
        //            backgroundColor: const Color(0xFFFCE4EC),
        //          ),
        //        ],
        //      ),
        //    ),
        //    SizedBox(
        //      height: 12.h,
        //    ),
        //    SingleChildScrollView(
        //      scrollDirection: Axis.horizontal,
        //      child: Row(
        //        children: [
        //          const DashboardCardNew(
        //            icon: Icons.file_copy_sharp,
        //            fileCount: "2",
        //            title: "Verification Stage",
        //            count: "25,000",
        //            backgroundColor:  Color(0xFFE1F5FE),
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            icon: Icons.file_copy_sharp,
        //            title: "Relook",
        //            count: "30,000",
        //            fileCount: '4',
        //            backgroundColor:
        // Color(0xFFFFF8E1)
        //            ,
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            fileCount: '2',
        //            icon: Icons.file_copy_sharp,
        //            title: "Relook Done",
        //            count: "0",
        //            backgroundColor:
        //               Color(0xFFFCE4EC)
        //            ,
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            fileCount: "3",
        //            icon: Icons.file_copy_sharp,
        //            title: "Underwriting",
        //            count: "30,000",
        //            backgroundColor:
        //             Color(0xFFE3F2FD)
        //           ,
        //          ),
        //        ],
        //      ),
        //    ),
        //    SizedBox(
        //      height: 12.h,
        //    ),
        //    SingleChildScrollView(
        //      scrollDirection: Axis.horizontal,
        //      child: Row(
        //        children: [
        //          const DashboardCardNew(
        //            icon: Icons.file_copy_sharp,
        //            fileCount: "2",
        //            title: "Recommended",
        //            count: "25,000",
        //            backgroundColor: const Color(0xFFE3F2FD),
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            icon: Icons.file_copy_sharp,
        //            title: "Approved",
        //            count: "30,000",
        //            fileCount: '4',
        //            backgroundColor: const Color(0xFFE1F5FE),
        //          ),
        //          SizedBox(
        //            width: 12.w,
        //          ),
        //          const DashboardCardNew(
        //            fileCount: '2',
        //            icon: Icons.file_copy_sharp,
        //            title: "Distributed",
        //            count: "0",
        //            backgroundColor: const Color(0xFFFFF8E1),
        //          ),
        //        ],
        //      ),
        //    ),

        // GridView.count(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   crossAxisCount: 2,
        //   childAspectRatio: 1.3,
        //   crossAxisSpacing: 12.w,
        //   mainAxisSpacing: 12.h,
        //   children: const [
        //     DashboardCardNew(
        //       icon: Icons.file_copy_sharp,
        //       fileCount: "2",
        //       title: "Document Sent",
        //       count: "25,000",
        //       backgroundColor: const Color(0xFFE3F2FD),
        //     ),
        //     DashboardCardNew(
        //       icon: Icons.file_copy_sharp,
        //       title: "Login Process",
        //       count: "30,000",
        //       fileCount: '4',
        //       backgroundColor: const Color(0xFFE1F5FE),
        //     ),
        //     DashboardCardNew(
        //       fileCount: '2',
        //       icon: Icons.file_copy_sharp,
        //       title: "Query",
        //       count: "0",
        //       backgroundColor: const Color(0xFFFFF8E1),
        //     ),
        //     DashboardCardNew(
        //       fileCount: "3",
        //       icon: Icons.file_copy_sharp,
        //       title: "Login Done",
        //       count: "30,000",
        //       backgroundColor: const Color(0xFFFCE4EC),
        //     ),
        //     const DashboardCardNew(
        //       icon: Icons.file_copy_sharp,
        //       fileCount: "2",
        //       title: "Verification Stage",
        //       count: "25,000",
        //       backgroundColor: const Color(0xFFE3F2FD),
        //     ),
        //     const DashboardCardNew(
        //       icon: Icons.file_copy_sharp,
        //       title: "Relook",
        //       count: "30,000",
        //       fileCount: '4',
        //       backgroundColor: const Color(0xFFE1F5FE),
        //     ),
        //     const DashboardCardNew(
        //       fileCount: '2',
        //       icon: Icons.file_copy_sharp,
        //       title: "Relook Done",
        //       count: "0",
        //       backgroundColor: const Color(0xFFFFF8E1),
        //     ),
        //     const DashboardCardNew(
        //       fileCount: "3",
        //       icon: Icons.file_copy_sharp,
        //       title: "Underwriting",
        //       count: "30,000",
        //       backgroundColor: const Color(0xFFFCE4EC),
        //     ),
        //     const DashboardCardNew(
        //       icon: Icons.file_copy_sharp,
        //       fileCount: "2",
        //       title: "Recommended",
        //       count: "25,000",
        //       backgroundColor: const Color(0xFFE3F2FD),
        //     ),
        //     const DashboardCardNew(
        //       icon: Icons.file_copy_sharp,
        //       title: "Approved",
        //       count: "30,000",
        //       fileCount: '4',
        //       backgroundColor: const Color(0xFFE1F5FE),
        //     ),
        //     const DashboardCardNew(
        //       fileCount: '2',
        //       icon: Icons.file_copy_sharp,
        //       title: "Distributed",
        //       count: "0",
        //       backgroundColor: const Color(0xFFFFF8E1),
        //     ),
        //
        //     // DashboardCard(
        //     //   icon: Icons.person,
        //     //   title: "TOTAL ATTEMPT",
        //     //   count: (data?.totalAttempt ?? 0).toString(),
        //     //   backgroundColor: const Color(0xFFE3F2FD),
        //     // ),
        //     // DashboardCard(
        //     //   icon: Icons.headphones,
        //     //   title: "CONTACTED",
        //     //   count: (data?.totalContact ?? 0).toString(),
        //     //   backgroundColor: const Color(0xFFE1F5FE),
        //     // ),
        //     // DashboardCard(
        //     //   icon: Icons.mic_off,
        //     //   title: "NOT CONTACTED",
        //     //   count: (data?.totalNocontact ?? 0).toString(),
        //     //   backgroundColor: const Color(0xFFFFF8E1),
        //     // ),
        //     // DashboardCard(
        //     //   icon: Icons.calendar_month,
        //     //   title: "Disbursement".toUpperCase(),
        //     //   count: (data?.totalLead ?? 0).toString(),
        //     //   backgroundColor: const Color(0xFFFCE4EC),
        //     // ),
        //     //
        //   ],
        // ),
        //
      ],
    );
  }
}
