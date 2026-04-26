import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/controllers/admin/admin_disbursement.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/views/spacing_constants.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/flutter_chiplist.dart';
import 'package:smart_solutions/widget/header_title.dart';
import 'package:smart_solutions/widget/searchbarwithclear.dart';
import 'package:smart_solutions/widget/text_style.dart';
import '../../constants/static_stored_data.dart';
import '../../widget/loading_page.dart';

class AdminDisbursement extends StatefulWidget {
  final String title;
  const AdminDisbursement({super.key, required this.title});

  @override
  State<AdminDisbursement> createState() => _AdminDisbursementState();
}

class _AdminDisbursementState extends State<AdminDisbursement> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _adminDisbursementController = Get.put(DisbursementController());

  final bool isTeamLeader = StaticStoredData.roleName == 'teamleader';
  final String teamleaderId = StaticStoredData.userId;

  @override
  void initState() {
    super.initState();
    // Team leaders are loaded in controller's onInit()
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        isDrawer: false,
        showBack: true,
        title: widget.title,
        key: _scaffoldKey,
        body: Column(children: [
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
                  controller: _adminDisbursementController.searchController,
                  onClear: _adminDisbursementController.clearFilters,
                  showDatePickerIcon: true,
                  onChanged: (value) {
                    // _adminDisbursementController.getDisbursementData(
                    //     query: value, teamleaderId: teamleaderId);
                    // // Handle search if needed
                  },
                ),
                kVerticalSpace(5),
                if (!isTeamLeader) _buildFilterChips(),
                kVerticalSpace(10),
                _buildTotalSummary(),
              ],
            ),
          ),
          // Expanded(child: _buildDisbursementList())
          /// ⭐ VERY IMPORTANT
          Expanded(child: Obx(() {
            if (_adminDisbursementController.isLoading.value ||
                _adminDisbursementController.iscallDisbursedLoading.value) {
              return const LoadingPage();
            }

            return _buildDisbursementList();
          }))
        ]));
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final filterList = _adminDisbursementController.filters;

      if (filterList.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Center(
            child: Text(
              'Loading team leaders...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }

      return SizedBox(
        height: 50.h,
        child: FilterChipList(
          filters: filterList,
          controller: _adminDisbursementController.filterScrollController,
          selectedIndex: _adminDisbursementController.selectedFilter.value,
          onSelected: _adminDisbursementController.selectFilter,
        ),
      );
    });
  }

  Widget _buildTotalSummary() {
    return Obx(() {
      final list = _adminDisbursementController.disbursementList;

      if (list.isEmpty) {
        return const SizedBox.shrink();
      }

      int loginTotal = 0;
      int disbursedTotal = 0;
      double amountTotal = 0;

      for (var e in list) {
        loginTotal += int.parse(e.loginCount);
        disbursedTotal += int.parse(e.disbursedCount);
        amountTotal += int.parse(e.amount);
      }

      final totalSum = loginTotal + disbursedTotal;

      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🔹 TOTAL ROW (TOP)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.max,
                        children: const [
                          Icon(Icons.folder_open, size: 16, color: Colors.blue),
                          SizedBox(width: 6),
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            CurrencyUtils.formatAmount(amountTotal.toString()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🔹 LOGIN & DISBURSED (BOTTOM)
              Row(
                children: [
                  /// LOGIN
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.login,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          const Text("Login", style: TextStyle(fontSize: 11)),
                          const Spacer(),
                          Text(
                            loginTotal.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// DISBURSED
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 6),
                          const Text("Disbursed",
                              style: TextStyle(fontSize: 11)),
                          const Spacer(),
                          Text(
                            "$disbursedTotal",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )

          //  Column(
          //   children: [
          //     /// 🔹 TOTAL ROW (TOP)
          //     Row(
          //       children: [
          //         Container(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //           decoration: BoxDecoration(
          //             color: Colors.blue.withOpacity(.10),
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: const [
          //               Icon(Icons.folder_open, size: 16, color: Colors.blue),
          //               SizedBox(width: 6),
          //               Text(
          //                 "Total",
          //                 style: TextStyle(
          //                   fontSize: 13,
          //                   fontWeight: FontWeight.w700,
          //                   color: Colors.blue,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         const Spacer(),
          //         Container(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //           decoration: BoxDecoration(
          //             color: Colors.green.withOpacity(.10),
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               const Icon(Icons.currency_rupee,
          //                   size: 16, color: Colors.green),
          //               const SizedBox(width: 4),
          //               Text(
          //                 CurrencyUtils.formatAmount(amountTotal.toString()),
          //                 style: const TextStyle(
          //                   fontSize: 14,
          //                   fontWeight: FontWeight.w700,
          //                   color: Colors.green,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),

          //     const SizedBox(height: 10),

          //     Row(
          //       children: [
          //         /// LOGIN
          //         Expanded(
          //           child: Container(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 10, vertical: 8),
          //             decoration: BoxDecoration(
          //               color: Colors.blue.withOpacity(.08),
          //               borderRadius: BorderRadius.circular(10),
          //             ),
          //             child: Row(
          //               children: [
          //                 Icon(Icons.login,
          //                     size: 16, color: Colors.blue.shade700),
          //                 const SizedBox(width: 6),
          //                 const Text(
          //                   "Login",
          //                   style: TextStyle(fontSize: 11),
          //                 ),
          //                 const Spacer(),
          //                 Text(
          //                   loginTotal.toString(),
          //                   style: TextStyle(
          //                     fontSize: 13,
          //                     fontWeight: FontWeight.w700,
          //                     color: Colors.blue.shade900,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),

          //         const SizedBox(width: 8),

          //         /// DISBURSED
          //         Expanded(
          //           child: Container(
          //             padding: const EdgeInsets.symmetric(
          //                 horizontal: 10, vertical: 8),
          //             decoration: BoxDecoration(
          //               color: Colors.orange.withOpacity(.08),
          //               borderRadius: BorderRadius.circular(10),
          //             ),
          //             child: Row(
          //               children: [
          //                 const Icon(Icons.check_circle_outline,
          //                     size: 16, color: Colors.orange),
          //                 const SizedBox(width: 6),
          //                 const Text(
          //                   "Disbursed",
          //                   style: TextStyle(fontSize: 11),
          //                 ),
          //                 const Spacer(),
          //                 Text(
          //                   "$disbursedTotal",
          //                   style: const TextStyle(
          //                     fontSize: 13,
          //                     fontWeight: FontWeight.w700,
          //                     color: Colors.orange,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //     // /// ⭐ TOP ROW (COUNT + AMOUNT)
          //     // Row(
          //     //   children: [
          //     //     /// 🔵 TOTAL COUNT BADGE
          //     //     // Container(
          //     //     //   height: 54,
          //     //     //   width: 54,
          //     //     //   decoration: BoxDecoration(
          //     //     //     gradient: const LinearGradient(
          //     //     //       colors: [Color(0xff4facfe), Color(0xff00f2fe)],
          //     //     //       begin: Alignment.topLeft,
          //     //     //       end: Alignment.bottomRight,
          //     //     //     ),
          //     //     //     borderRadius: BorderRadius.circular(16),
          //     //     //     boxShadow: [
          //     //     //       BoxShadow(
          //     //     //         color: Colors.blue.withOpacity(.25),
          //     //     //         blurRadius: 12,
          //     //     //         offset: const Offset(0, 6),
          //     //     //       )
          //     //     //     ],
          //     //     //   ),
          //     //     //   child: Center(
          //     //     //     child: Text(
          //     //     //       totalSum.toString(),
          //     //     //       style: const TextStyle(
          //     //     //         color: Colors.white,
          //     //     //         fontWeight: FontWeight.w700,
          //     //     //         fontSize: 18,
          //     //     //       ),
          //     //     //     ),
          //     //     //   ),
          //     //     // ),

          //     //     const SizedBox(width: 14),

          //     //     /// 💰 AMOUNT CARD
          //     //     Expanded(
          //     //       child: Container(
          //     //         padding: const EdgeInsets.symmetric(
          //     //             horizontal: 14, vertical: 12),
          //     //         decoration: BoxDecoration(
          //     //           color: Colors.green.withOpacity(.08),
          //     //           borderRadius: BorderRadius.circular(14),
          //     //           border: Border.all(
          //     //             color: Colors.green.withOpacity(.25),
          //     //           ),
          //     //         ),
          //     //         child: Row(
          //     //           children: [
          //     //             const Icon(Icons.currency_rupee,
          //     //                 size: 20, color: Colors.green),
          //     //             const SizedBox(width: 6),
          //     //             Expanded(
          //     //               child: Text(
          //     //                 CurrencyUtils.formatAmount(
          //     //                     amountTotal.toString()),
          //     //                 maxLines: 1,
          //     //                 overflow: TextOverflow.ellipsis,
          //     //                 style: const TextStyle(
          //     //                   color: Colors.green,
          //     //                   fontWeight: FontWeight.w700,
          //     //                   fontSize: 15,
          //     //                 ),
          //     //               ),
          //     //             ),
          //     //           ],
          //     //         ),
          //     //       ),
          //     //     ),
          //     //   ],
          //     // ),

          //     // const SizedBox(height: 14),

          //     // /// ⭐ BOTTOM STATS CHIPS
          //     // Row(
          //     //   children: [
          //     //     /// LOGIN CHIP
          //     //     Expanded(
          //     //       child: Container(
          //     //         padding: const EdgeInsets.symmetric(
          //     //             horizontal: 12, vertical: 10),
          //     //         decoration: BoxDecoration(
          //     //           color: Colors.blue.withOpacity(.08),
          //     //           borderRadius: BorderRadius.circular(12),
          //     //         ),
          //     //         child: Row(
          //     //           children: [
          //     //             Icon(Icons.login,
          //     //                 size: 18, color: Colors.blue.shade700),
          //     //             const SizedBox(width: 6),
          //     //             Text(
          //     //               "Login",
          //     //               style: TextStyle(
          //     //                 fontSize: 12,
          //     //                 color: Colors.blue.shade700,
          //     //               ),
          //     //             ),
          //     //             const Spacer(),
          //     //             Text(
          //     //               loginTotal.toString(),
          //     //               style: TextStyle(
          //     //                 fontWeight: FontWeight.bold,
          //     //                 fontSize: 14,
          //     //                 color: Colors.blue.shade900,
          //     //               ),
          //     //             ),
          //     //           ],
          //     //         ),
          //     //       ),
          //     //     ),

          //     //     const SizedBox(width: 10),

          //     //     /// DISBURSED CHIP
          //     //     Expanded(
          //     //       child: Container(
          //     //         padding: const EdgeInsets.symmetric(
          //     //             horizontal: 12, vertical: 10),
          //     //         decoration: BoxDecoration(
          //     //           color: Colors.orange.withOpacity(.08),
          //     //           borderRadius: BorderRadius.circular(12),
          //     //         ),
          //     //         child: Row(
          //     //           children: [
          //     //             const Icon(Icons.check_circle_outline,
          //     //                 size: 18, color: Colors.orange),
          //     //             const SizedBox(width: 6),
          //     //             const Text(
          //     //               "Disbursed",
          //     //               style: TextStyle(
          //     //                 fontSize: 12,
          //     //                 color: Colors.orange,
          //     //               ),
          //     //             ),
          //     //             const Spacer(),
          //     //             Text(
          //     //               "$disbursedTotal",
          //     //               style: const TextStyle(
          //     //                 fontWeight: FontWeight.bold,
          //     //                 fontSize: 14,
          //     //                 color: Colors.orange,
          //     //               ),
          //     //             ),
          //     //           ],
          //     //         ),
          //     //       ),
          //     //     ),
          //     //   ],
          //     // ),
          //   ],
          // )

          //  Column(
          //   children: [
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         /// TOTAL COUNT BOX
          //         Container(
          //           height: 46,
          //           width: 46,
          //           decoration: BoxDecoration(
          //             color: Colors.blue,
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           child: Center(
          //             child: Text(
          //               totalSum.toString(),
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 16,
          //               ),
          //             ),
          //           ),
          //         ),

          //         const SizedBox(width: 12),

          //         /// AMOUNT
          //         Container(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          //           decoration: BoxDecoration(
          //             color: Colors.green.withOpacity(.1),
          //             borderRadius: BorderRadius.circular(8),
          //           ),
          //           child: Text(
          //             "₹${CurrencyUtils.formatAmount(amountTotal.toString())}",
          //             style: const TextStyle(
          //               color: Colors.green,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 13,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),

          //     /// LOGIN + DISBURSED
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: [
          //         Icon(Icons.login, size: 16, color: Colors.blue.shade700),
          //         const SizedBox(width: 4),
          //         Text(
          //           "Login: $loginTotal",
          //           style: const TextStyle(
          //             fontSize: 13,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //         const SizedBox(width: 12),
          //         const Icon(Icons.check_circle_outline,
          //             size: 16, color: Colors.orange),
          //         const SizedBox(width: 4),
          //         Text(
          //           "Disbursed: $disbursedTotal",
          //           style: const TextStyle(
          //             fontSize: 13,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          );
    });
  }

  Widget _buildDisbursementList() {
    final data = _adminDisbursementController.disbursementList;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No disbursement data available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        final itemTotal = (int.tryParse(item.loginCount) ?? 0) +
            (int.tryParse(item.disbursedCount) ?? 0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xffEEF2FF),
                      child: Icon(Icons.person, color: Colors.indigo),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "₹${CurrencyUtils.formatAmount(item.amount)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: $itemTotal",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            _modernStat("Login", item.loginCount, Colors.blue),
                            const SizedBox(width: 6),
                            _modernStat("Disbursed", item.disbursedCount,
                                Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );

    //  Padding(

    //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
    //   child: Container(
    //     padding: const EdgeInsets.all(14),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(14),
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black.withOpacity(.05),
    //           blurRadius: 8,
    //           offset: const Offset(0, 3),
    //         ),
    //       ],
    //     ),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //          HEADER
    //         Row(
    //           children: [
    //             const CircleAvatar(
    //               radius: 18,
    //               backgroundColor: Color(0xffEEF2FF),
    //               child: Icon(Icons.person, color: Colors.indigo),
    //             ),
    //             const SizedBox(width: 10),
    //             Expanded(
    //               child: Text(
    //                 data.name.toString(),
    //                 style: const TextStyle(
    //                   fontWeight: FontWeight.w600,
    //                   fontSize: 14,
    //                 ),
    //               ),
    //             ),
    //             Text(
    //               "Total: $itemTotal",
    //               style: const TextStyle(
    //                 fontSize: 12,
    //                 color: Colors.grey,
    //               ),
    //             ),
    //           ],
    //         ),

    //         const SizedBox(height: 12),

    //          AMOUNT
    //         Text(
    //           "₹${CurrencyUtils.formatAmount(item.amount)}",
    //           style: const TextStyle(
    //             fontSize: 18,
    //             fontWeight: FontWeight.bold,
    //             color: Colors.green,
    //           ),
    //         ),

    //         const SizedBox(height: 10),

    //          STATS
    //         Row(
    //           children: [
    //             _modernStat("Login", item.loginCount, Colors.blue),
    //             const SizedBox(width: 10),
    //             _modernStat("Disbursed", item.disbursedCount, Colors.orange),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    //  Padding(
    //   padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
    //   child: ListView.builder(
    //     itemCount: data.length,
    //     itemBuilder: (context, index) {
    //       final item = data[index];

    //       // Calculate total for this item
    //       final itemTotal = (int.tryParse(item.loginCount) ?? 0) +
    //           (int.tryParse(item.disbursedCount) ?? 0);

    //       return Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    //         child: SummaryCard(
    //           title: item.name.toString(),
    //           duration: 'Total: $itemTotal',
    //           icon: Icons.person,
    //           rows: [
    //             Wrap(
    //               spacing: 8,
    //               runSpacing: 6,
    //               alignment: WrapAlignment.end,
    //               children: [
    //                 _statChip(
    //                   icon: Icons.currency_rupee,
    //                   label: "Amount",
    //                   value: CurrencyUtils.formatAmount(item.amount),
    //                   color: Colors.green,
    //                 ),
    //                 _statChip(
    //                   icon: Icons.file_copy_outlined,
    //                   label: "Login",
    //                   value: item.loginCount,
    //                   color: Colors.blue,
    //                 ),
    //                 _statChip(
    //                   icon: Icons.check_circle_outline,
    //                   label: "Disbursed",
    //                   value: item.disbursedCount,
    //                   color: Colors.orange,
    //                 ),
    //               ],
    //             )

    //             // Container(
    //             //   padding: EdgeInsets.all(8.h),
    //             //   decoration: BoxDecoration(
    //             //     color: AppColors.appBarTextColor,
    //             //     borderRadius: BorderRadius.circular(15),
    //             //   ),
    //             //   child: Column(
    //             //     crossAxisAlignment: CrossAxisAlignment.end,
    //             //     children: [
    //             //       // Amount
    //             //       Text(
    //             //         '₹${CurrencyUtils.formatAmount(item.amount)}',
    //             //         style: AppTextStyle.blueHeaderTitletStyle.copyWith(
    //             //           fontSize: 14.sp,
    //             //           fontWeight: FontWeight.bold,
    //             //         ),
    //             //       ),
    //             //       SizedBox(height: 8.h),

    //             //       // Login Files
    //             //       Row(
    //             //         mainAxisSize: MainAxisSize.min,
    //             //         children: [
    //             //           RichText(
    //             //             text: TextSpan(
    //             //               children: [
    //             //                 const TextSpan(
    //             //                   text: 'Login Files - ',
    //             //                   style: TextStyle(
    //             //                     color: Colors.grey,
    //             //                     fontSize: 12,
    //             //                   ),
    //             //                 ),
    //             //                 TextSpan(
    //             //                   text: item.loginCount,
    //             //                   style: const TextStyle(
    //             //                     color: Colors.black,
    //             //                     fontSize: 12,
    //             //                     fontWeight: FontWeight.w600,
    //             //                   ),
    //             //                 ),
    //             //               ],
    //             //             ),
    //             //           ),
    //             //           SizedBox(width: 15.w),
    //             //           // Disbursed Files
    //             //           RichText(
    //             //             text: TextSpan(
    //             //               children: [
    //             //                 const TextSpan(
    //             //                   text: 'Disbursed Files - ',
    //             //                   style: TextStyle(
    //             //                     color: Colors.grey,
    //             //                     fontSize: 12,
    //             //                   ),
    //             //                 ),
    //             //                 TextSpan(
    //             //                   text: item.disbursedCount,
    //             //                   style: const TextStyle(
    //             //                     color: Colors.black,
    //             //                     fontSize: 12,
    //             //                     fontWeight: FontWeight.w600,
    //             //                   ),
    //             //                 ),
    //             //               ],
    //             //             ),
    //             //           ),
    //             //         ],
    //             //       ),
    //             //     ],
    //             //   ),
    //             // ),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}

Widget _modernStat(String label, String value, Color color) {
  return Chip(
    padding: EdgeInsets.zero,
    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
    backgroundColor: color.withOpacity(.08),
    label: Text(
      "$label: $value",
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}

// Widget _modernStat(String label, String value, Color color) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//     decoration: BoxDecoration(
//       color: color.withOpacity(.08),
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           "$label: ",
//           style: const TextStyle(fontSize: 11, color: Colors.grey),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     ),
//   );
// }
