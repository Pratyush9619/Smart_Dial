import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/leave_status_controller.dart';
import '../../models/hrms/leave_status_model.dart';
import 'leave_details_page.dart';

class LeaveStatusPage extends StatelessWidget {
  LeaveStatusController controller = Get.put(LeaveStatusController());
  LeaveStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Leave Status",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: "All"),
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return TabBarView(
            children: [
              leaveList(controller.getLeavesByStatus(null)),
              leaveList(controller.getLeavesByStatus('Pending')),
              leaveList(controller.getLeavesByStatus('Approved')),
              leaveList(controller.getLeavesByStatus('Rejected')),
            ],
          );
        }),
      ),
    );
  }

  Widget leaveList(List<LeaveData> leaves) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Obx(() => _summaryCard()),
          if (leaves.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No leave records found',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              return _leaveCard(leaves[index]);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final b = controller.balances.value;

    if (b == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave Balance Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _balanceBox(
                  b.sickLeave.remaining.toString(),
                  b.sickLeave.label,
                  Colors.blue.shade50,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceBox(
                  b.casualLeave.remaining.toString(),
                  b.casualLeave.label,
                  Colors.green.shade50,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceBox(
                  b.paidLeave.remaining.toString(),
                  b.paidLeave.label,
                  Colors.orange.shade50,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Expanded(
              //   child: _balanceBox(
              //     b.paidLeave.remaining.toString(),
              //     b.paidLeave.label,
              //     Colors.orange.shade50,
              //     Colors.orange,
              //   ),
              // ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceBox(
                  b.unpaidLeave.remaining.toString(),
                  b.unpaidLeave.label,
                  Colors.purple.shade50,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _balanceBox(
                  b.halfDay.remaining.toString(),
                  b.halfDay.label,
                  Colors.teal.shade50,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceBox(
      String count, String title, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaveCard(LeaveData item) {
    Color statusColor;

    switch (item.status) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    final start = DateTime.parse(item.startDate);

    return InkWell(
      onTap: () {
        Get.to(
          () => LeaveDetailsPage(
            leave: item,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DATE SECTION
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    start.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _month(start.month),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    start.year.toString(),
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            // VERTICAL DIVIDER
            Container(
              height: 78,
              width: 1,
              margin: const EdgeInsets.symmetric(
                horizontal: 9,
              ),
              color: Colors.grey.shade300,
            ),

            // LEAVE DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leave type + status
                  Row(children: [
                    Expanded(
                      child: Text(
                        item.leaveTypeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Compact status
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    //   Column(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 7,
                    //           vertical: 3,
                    //         ),
                    //         decoration: BoxDecoration(
                    //           color: statusColor.withOpacity(0.12),
                    //           borderRadius: BorderRadius.circular(20),
                    //         ),
                    //         child: Text(
                    //           item.status,
                    //           style: TextStyle(
                    //             fontSize: 10,
                    //             color: statusColor,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ),
                    //       InkWell(
                    //         borderRadius: BorderRadius.circular(20),
                    //         onTap: () {
                    //           // Get.to(
                    //           //   () => LeaveDetailsPage(
                    //           //     leave: item,
                    //           //   ),
                    //           // );
                    //         },
                    //         child: const Icon(
                    //           Icons.arrow_forward_ios,
                    //           size: 16,
                    //           color: Colors.grey,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ],
                  ]),

                  const SizedBox(height: 6),

                  // Dates
                  Text(
                    '${item.startDate}  →  ${item.endDate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Reason
                  Text(
                    item.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black45,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    //  Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    //   padding: const EdgeInsets.all(14),
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(16),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.grey.withOpacity(.08),
    //         blurRadius: 6,
    //         offset: const Offset(0, 2),
    //       ),
    //     ],
    //   ),
    //   child: Row(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       SizedBox(
    //         width: 55,
    //         child: Column(
    //           children: [
    //             Text(
    //               start.day.toString().padLeft(2, '0'),
    //               style: const TextStyle(
    //                 fontSize: 24,
    //                 fontWeight: FontWeight.w700,
    //                 color: Colors.blue,
    //               ),
    //             ),
    //             Text(
    //               '${_month(start.month)}\n${start.year}',
    //               textAlign: TextAlign.center,
    //               style: const TextStyle(
    //                 fontSize: 11,
    //                 fontWeight: FontWeight.w500,
    //                 color: Colors.black54,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       Container(
    //         margin: const EdgeInsets.symmetric(horizontal: 12),
    //         height: 70,
    //         width: 1,
    //         color: Colors.grey.shade300,
    //       ),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               item.leaveTypeName,
    //               style: const TextStyle(
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //             ),
    //             const SizedBox(height: 6),
    //             Text(
    //               'From : ${item.startDate}',
    //               style: const TextStyle(fontSize: 13),
    //             ),
    //             const SizedBox(height: 2),
    //             Text(
    //               'To      : ${item.endDate}',
    //               style: const TextStyle(fontSize: 13),
    //             ),
    //             const SizedBox(height: 6),
    //             Text(
    //               item.reason,
    //               maxLines: 2,
    //               overflow: TextOverflow.ellipsis,
    //               style: const TextStyle(
    //                 fontSize: 13,
    //                 fontWeight: FontWeight.w500,
    //                 color: Colors.black54,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       Column(
    //         children: [
    //           Chip(
    //             backgroundColor: statusColor.withOpacity(.12),
    //             side: BorderSide.none,
    //             label: Text(
    //               item.status,
    //               style: TextStyle(
    //                 color: statusColor,
    //                 fontWeight: FontWeight.w600,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return months[month - 1];
  }
}
