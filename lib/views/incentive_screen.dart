import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/api_urls.dart';
import '../constants/static_stored_data.dart';
import '../controllers/incentive_controller.dart';
import '../controllers/theme_controller.dart';
import '../views/spacing_constants.dart';
import '../widget/common_scaffold.dart';
import '../widget/flutter_chiplist.dart';
import '../widget/header_title.dart';
import '../widget/searchbarwithclear.dart';
import '../widget/text_style.dart';
import 'incentive/model/incentive_model.dart';

class IncentivePage extends StatefulWidget {
  final String title;
  const IncentivePage({super.key, required this.title});

  @override
  State<IncentivePage> createState() => _IncentivePageState();
}

class _IncentivePageState extends State<IncentivePage> {
  final incentiveController = Get.find<IncentiveController>();
  final themeController = Get.find<ThemeController>();

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  List<IncentiveUser> get users => incentiveController.filteredList;

  double get totalTarget => users.fold(0, (s, e) => s + e.totalTarget);

  double get totalAchieved => users.fold(0, (s, e) => s + e.achievement);

  double get totalBacklog => users.fold(0, (s, e) => s + e.currentMonthBacklog);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      isDrawer: false,
      showBack: true,
      title: widget.title,
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: () => incentiveController.loadFromApi(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderTitle(title: widget.title, style: AppTextStyle.headerTitle),

            /// 🔍 SEARCH
            SearchBarWithClear(
              controller: incentiveController.searchController,
              showDatePickerIcon: true,
              monthOnly: true,
              onMonthSelected: incentiveController.selectMonth,
              onClear: incentiveController.clearFilters,
              onChanged: (value) {
                incentiveController.searchText.value = value;
                incentiveController.loadFromApi();
              },
            ),

            kVerticalSpace(6),

            /// 🏷 FILTERS
            Obx(() {
              final isAllowed = StaticStoredData.roleName != 'telecaller' &&
                  StaticStoredData.roleName != 'teamleader';

              return Visibility(
                visible: isAllowed,
                child: FilterChipList(
                  filters: incentiveController.filters,
                  controller: incentiveController.filterScrollController,
                  selectedIndex: incentiveController.selectedFilter.value,
                  onSelected: incentiveController.selectFilter,
                ),
              );
            }),

            /// 📊 SUMMARY
            Obx(() => _buildSummaryHeader()),

            /// 👤 LIST
            Expanded(child: Obx(() => _buildUserList())),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _buildSummaryHeader() {
    final double progress =
        totalTarget == 0 ? 0 : (totalAchieved / totalTarget);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeController.primaryColor.value.withAlpha(180),
              themeController.primaryColor.value
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 TOP STATS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _summaryStat(
                    label: "Target",
                    value: currencyFormat.format(totalTarget),
                    icon: Icons.flag_outlined,
                    color: Colors.white,
                  ),
                  _summaryStat(
                    label: "Achieved",
                    value: currencyFormat.format(totalAchieved),
                    icon: Icons.trending_up,
                    color: Colors.white,
                  ),
                  _summaryStat(
                    label: "Backlog",
                    value: currencyFormat.format(totalBacklog),
                    icon: Icons.trending_down,
                    color: Colors.white,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// 🔹 PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: Colors.white.withOpacity(0.25),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      height: 8,
                      width:
                          MediaQuery.of(context).size.width * progress * 0.78,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: progress >= 1
                              ? [Colors.orange, Colors.amber]
                              : [Colors.greenAccent, Colors.green],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// 🔹 PROGRESS TEXT
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${(progress * 100).toStringAsFixed(0)}% achieved",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.all(12),
    //   child: Container(
    //     color: themeController.primaryColor.value,
    //     child: Padding(
    //       padding: const EdgeInsets.all(14),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           /// TOP STATS
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               _summaryStat(
    //                 label: "Target",
    //                 value: currencyFormat.format(totalTarget),
    //                 icon: Icons.flag_outlined,
    //                 color: Colors.blue,
    //               ),
    //               _summaryStat(
    //                 label: "Achieved",
    //                 value: currencyFormat.format(totalAchieved),
    //                 icon: Icons.trending_up,
    //                 color: Colors.green,
    //               ),
    //               _summaryStat(
    //                 label: "Backlog",
    //                 value: currencyFormat.format(totalBacklog),
    //                 icon: Icons.trending_down,
    //                 color: Colors.redAccent,
    //               ),
    //             ],
    //           ),

    //           const SizedBox(height: 12),

    //           /// PROGRESS BAR
    //           Stack(
    //             children: [
    //               Container(
    //                 height: 6,
    //                 decoration: BoxDecoration(
    //                   color: Colors.grey.shade200,
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //               ),
    //               AnimatedContainer(
    //                 duration: const Duration(milliseconds: 600),
    //                 height: 6,
    //                 width: MediaQuery.of(context).size.width * progress * 0.75,
    //                 decoration: BoxDecoration(
    //                   gradient: LinearGradient(
    //                     colors: progress >= 1
    //                         ? [Colors.blue, Colors.lightBlueAccent]
    //                         : [Colors.green, Colors.greenAccent],
    //                   ),
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //               ),
    //             ],
    //           ),

    //           const SizedBox(height: 6),

    //           Align(
    //             alignment: Alignment.centerRight,
    //             child: Text(
    //               "${(progress * 100).toStringAsFixed(0)}% achieved",
    //               style: const TextStyle(fontSize: 11, color: Colors.grey),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _summaryStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.white)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // ================= USER LIST =================

  Widget _buildUserList() {
    if (incentiveController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!incentiveController.isApiLoaded.value) {
      return const SizedBox();
    }

    if (incentiveController.filteredList.isEmpty) {
      return const Center(child: Text("No data found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: incentiveController.filteredList.length,
      itemBuilder: (_, i) =>
          _incentiveCard(incentiveController.filteredList[i]),
    );
  }

  Widget _incentiveCard(IncentiveUser user) {
    final progress =
        user.totalTarget == 0 ? 0 : (user.achievement / user.totalTarget);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: '${APIUrls.imagebaseUrl}${user.profileImage}',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  // placeholder: (_, __) => const SizedBox(
                  //   width: 16,
                  //   height: 16,
                  //   child: CircularProgressIndicator(strokeWidth: 2),
                  // ),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.person, size: 20),
                ),
              ),
              // CircleAvatar(
              //   backgroundColor: Colors.green.shade100,
              //   child: const Icon(Icons.person, color: Colors.green, size: 20),
              // ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                currencyFormat.format(user.currentMonthBacklog),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat("Target", user.totalTarget, Colors.blue),
              _miniStat("Achieved", user.achievement, Colors.green),
            ],
          ),

          const SizedBox(height: 8),

          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 6,
                width: MediaQuery.of(context).size.width * progress * 0.65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: progress >= 1
                        ? [Colors.blue, Colors.lightBlueAccent]
                        : [Colors.green, Colors.greenAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toStringAsFixed(0)}% achieved",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, num value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.circle, size: 8, color: color),
        ),
        const SizedBox(width: 6),
        Text("$label: ",
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          currencyFormat.format(value),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
