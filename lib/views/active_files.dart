import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/constants/static_stored_data.dart';
import 'package:smart_solutions/controllers/active_files_controller.dart';
import 'package:smart_solutions/controllers/chartCard_controller.dart';
import 'package:smart_solutions/controllers/dailer_controller.dart';
import 'package:smart_solutions/controllers/data_entry_controller.dart';
import 'package:smart_solutions/controllers/follow_form_controller.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/utils/currency_util.dart';
import 'package:smart_solutions/utils/scroll_utils.dart';
import 'package:smart_solutions/views/chart_card_toggle.dart';
import 'package:smart_solutions/views/data_entry_form.dart';
import 'package:smart_solutions/views/spacing_constants.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/common_title_card.dart';
import 'package:smart_solutions/widget/flutter_chiplist.dart';
import 'package:smart_solutions/widget/header_title.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import 'package:smart_solutions/widget/searchbarwithclear.dart';
import 'package:smart_solutions/widget/text_style.dart';

class ActiveFiles extends StatefulWidget {
  final String title;
  final int status;
  final bool isShowBack;
  final bool isDrawer;

  const ActiveFiles(
      {super.key,
      required this.title,
      required this.status,
      this.isShowBack = false,
      this.isDrawer = false});

  @override
  State<ActiveFiles> createState() => _ActiveFilesState();
}

class _ActiveFilesState extends State<ActiveFiles> {
  final DataController dataController = Get.find<DataController>();
  final ActiveFilesController _activeFilesController =
      Get.find<ActiveFilesController>();
  final DialerController _dialerController = Get.find<DialerController>();
  final ThemeController _themeController = Get.find<ThemeController>();
  final FollowBackFormController _formController =
      Get.find<FollowBackFormController>();

  final ChartCardsController _chartCardsController =
      Get.find<ChartCardsController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _activeFilesController.currentStatus.value = widget.status;
      _activeFilesController.updateFilteredList();
    });

    super.initState();
  }

  @override
  void dispose() {
    _chartCardsController.selectedIndex.value = 0;
    _activeFilesController.filterController.clearFilters();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: widget.title,
        isDrawer: widget.isDrawer,
        showBack: widget.isShowBack,
        key: _scaffoldKey,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            color: AppColors.appBarTextColor,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeaderTitle(
                      title: widget.title, style: AppTextStyle.headerTitle),
                  Visibility(
                      visible: widget.title == 'Leads' ? true : false,
                      child: ChartCardsToggle(
                        data: const ['Active', 'Inactive'],
                      ))
                ],
              ),
              SearchBarWithClear(
                  controller:
                      _activeFilesController.filterController.searchController,
                  onChanged: (value) {
                    //    _activeFilesController.updateFilteredList();
                  },
                  onClear: () {
                    _activeFilesController.filterController.clearFilters();
                    ScrollUtils.scrollToStart(
                        _activeFilesController.filterScrollController);

                    _activeFilesController.updateFilteredList();
                  }),
              kVerticalSpace(10),
              Obx(() {
                final filterList =
                    _activeFilesController.filterController.filters;

                final selectedIndex = _activeFilesController
                    .filterController.selectedFilter.value;

                final safeIndex =
                    selectedIndex < filterList.length ? selectedIndex : 0;

                return FilterChipList(
                  filters: filterList,
                  controller: _activeFilesController.filterScrollController,
                  selectedIndex: safeIndex,
                  onSelected:
                      _activeFilesController.filterController.selectFilter,
                );
              })
            ]),
          ),
          Expanded(child: Obx(() {
            if (dataController.isLoading.value) {
              return const Center(child: LoadingPage());
            }

            if (_activeFilesController.isFiltering.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = _activeFilesController.filteredList;

            if (list.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_sim, size: 50, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No data entries available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final totalAmount = list.fold<double>(
              0,
              (sum, item) =>
                  sum + (double.tryParse(item.loanAmount.toString()) ?? 0),
            );

            return Column(children: [
              totalSummaryRow(
                totalCustomers: list.length,
                totalAmount: CurrencyUtils.formatIndianCurrency(totalAmount),
              ),
              Expanded(child: Obx(() {
                return RefreshIndicator(
                  onRefresh: () => _activeFilesController.refreshData(),
                  child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _activeFilesController.filteredList.length,
                      itemBuilder: (context, index) {
                        var data = _activeFilesController.filteredList[index];

                        return CommonTitleCard(
                          leading: Obx(
                            () => SvgPicture.asset(
                              'assets/images/phone_call.svg',
                              color: _themeController.primaryColor.value,
                            ),
                          ),
                          onLeadingTap: () {
                            _dialerController.makePhoneCall(data.mobileNo ?? '',
                                followUpId: data.id ?? '');
                            _formController.mobile.value = data.mobileNo ?? "";
                            _formController.bankName.value =
                                data.bankName ?? "";
                            _formController.customerName.value =
                                data.customerName ?? "";
                            _dialerController.customerName.value =
                                data.customerName ?? '';
                            _dialerController.datatype.value = '';
                            _formController.remark.value = data.comments ?? '';
                            _dialerController.followup_id.value = data.id ?? '';
                            _dialerController.excel_id.value = '';
                          },
                          title: data.customerName ?? '',
                          subtitle: data.loginBank ?? '',
                          date: DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(data.date.toString())),
                          mobNo: maskFirst6Digits(data.mobileNo ?? ''),
                          status: data.status ?? '',
                          statusColor:
                              data.dataStatus?.toLowerCase() == 'active'
                                  ? Colors.green.shade400
                                  : Colors.redAccent.shade200,
                          amount: CurrencyUtils.formatIndianCurrency(
                              data.loanAmount),
                          showEdit: StaticStoredData.roleName != 'telecaller' &&
                              StaticStoredData.roleName != 'teamleader',
                          onEdit: () async {
                            dataController.editLoadData();
                            await Get.to(DataEntryForm(
                              id: data.id,
                              tellecallerId: data.teleCallerId,
                              dsaId: data.dsaName,
                              bankerId: data.bankerId,
                            ));
                          },
                          children: [
                            // if (StaticStoredData.roleName == 'teamleader')
                            //   _buildSingleRow(
                            //       Icons.person_2_outlined, data.tcName ?? 'NA'),
                            if (StaticStoredData.roleName != 'telecaller')
                              _buildDoubleRow(
                                iconLeft: Icons.headphones_outlined,
                                valueLeft: data.tcName ?? '',
                                iconRight: Icons.person_2_outlined,
                                valueRight: data.tlName ?? '',
                              ),
                            // _buildDoubleRow(
                            //   iconLeft: 'assets/images/call.svg',
                            //   valueLeft: maskFirst6Digits(data.mobileNo ?? ''),
                            //   iconRight: 'assets/images/calendar.svg',
                            //   valueRight: DateFormat('dd-MM-yyyy')
                            //       .format(DateTime.parse(data.date.toString())),
                            // ),
                            _buildSingleRow(
                                'assets/images/message_dots_circle.svg',
                                data.comments ?? 'NA'),
                          ],
                        );
                      }),
                );
              }))
            ]);
          })),
        ]));
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
                _buildIcon(iconLeft),
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

  Widget totalSummaryRow({
    required int totalCustomers,
    required String totalAmount,
  }) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _themeController.primaryColor.value,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // CUSTOMERS
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.people, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customers",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      totalCustomers.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// DIVIDER
            Container(
              height: 28,
              width: 1,
              color: Colors.white.withOpacity(.3),
            ),

            /// AMOUNT
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.currency_rupee,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Amount",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      totalAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
