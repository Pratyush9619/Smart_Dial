import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/models/hrms/leave_count.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import '../../controllers/hrms/leave_controller.dart';
import '../../controllers/leave_request_controller.dart';
import '../../controllers/theme_controller.dart';
import 'leave_status_page.dart';

class RequestLeavePage extends StatefulWidget {
  const RequestLeavePage({super.key});

  @override
  State<RequestLeavePage> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends State<RequestLeavePage> {
  // String _leaveType = 'Sick Leave (04)';
  // DateTime? _fromDate;
  // DateTime? _toDate;

  // final TextEditingController _reasonController = TextEditingController();

  LeaveCount? _getSelectedLeave() {
    try {
      return leaveCountController.leaveTypes.firstWhere(
        (leave) => leave.key == controller.leaveType.value,
      );
    } catch (e) {
      return null;
    }
  }

  int get selectedLeaveRemaining {
    final selectedKey = controller.leaveType.value;

    if (selectedKey.isEmpty) {
      return 0;
    }

    final selectedLeave = leaveCountController.leaveTypes.firstWhereOrNull(
      (leave) => leave.key == selectedKey,
    );

    return selectedLeave?.remaining ?? 0;
  }

  // Future<void> _pickFromDate() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: controller.fromDate.value ??
  //         controller.fromDate.value ??
  //         DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //   );
  //   if (picked != null) {
  //     setState(() => controller.fromDate.value = picked);
  //   }
  // }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.fromDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        controller.fromDate.value = picked;
        controller.toDate.value = null;
      });
    }
  }

  Future<void> _pickToDate() async {
    if (controller.leaveType.value.isEmpty) {
      Get.snackbar(
        "Leave Type",
        "Please select leave type first",
      );
      return;
    }

    if (controller.fromDate.value == null) {
      Get.snackbar(
        "From Date",
        "Please select From Date first",
      );
      return;
    }

    final remaining = selectedLeaveRemaining;

    if (remaining <= 0) {
      Get.snackbar(
        "Leave Balance",
        "No leave balance remaining",
      );
      return;
    }

    final fromDate = controller.fromDate.value!;

    // Maximum To Date based on remaining leave
    final maxToDate = fromDate.add(
      Duration(days: remaining - 1),
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: controller.toDate.value ?? fromDate,
      firstDate: fromDate,
      lastDate: maxToDate,
    );

    if (picked != null) {
      setState(() {
        controller.toDate.value = picked;
      });
    }
  }
  // Future<void> _pickToDate() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: controller.toDate.value ??
  //         controller.fromDate.value ??
  //         DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //   );
  //   if (picked != null) {
  //     setState(() => controller.toDate.value = picked);
  //   }
  // }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  final controller = Get.put(LeaveController());
  final leaveCountController = Get.put(LeaveCountController());
  final ThemeController themeController = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Request Leave',
      showBack: true,
      isDrawer: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
              onTap: () {
                Get.off(() => LeaveStatusPage());
              },
              child: const Icon(Icons.list, color: Colors.white)),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min, // IMPORTANT
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Leave Type'),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    if (leaveCountController.leaveTypes.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Column(
                      children: List.generate(
                        (leaveCountController.leaveTypes.length / 2).ceil(),
                        (index) {
                          final startIndex = index * 2;

                          final first =
                              leaveCountController.leaveTypes[startIndex];

                          final second = startIndex + 1 <
                                  leaveCountController.leaveTypes.length
                              ? leaveCountController.leaveTypes[startIndex + 1]
                              : null;

                          return _leaveRadioRow([
                            first,
                            if (second != null) second,
                          ]);
                        },
                      ),
                    );

                    // return Column(
                    //   children: List.generate(
                    //     (leaveCountController.leaveTypes.length / 2).ceil(),
                    //     (index) {
                    //       final startIndex = index * 2;

                    //       final first =
                    //           leaveCountController.leaveTypes[startIndex];

                    //       final second = startIndex + 1 <
                    //               leaveCountController.leaveTypes.length
                    //           ? leaveCountController.leaveTypes[startIndex + 1]
                    //           : null;

                    //       return _leaveRadioRow(
                    //         [
                    //           _getLeaveLabel(first),
                    //           if (second != null) _getLeaveLabel(second),
                    //         ],
                    //       );
                    //     },
                    //   ),
                    // );
                  }),
                  // _leaveRadioRow(['Sick Leave (04)', 'Casual Leave (01)']),
                  // _leaveRadioRow(['Paid Leave (02)', 'Unpaid Leave']),
                  // _leaveRadioRow(['Half Day (03)']),
                ],
              ),
              const SizedBox(height: 15),
              const Text('From'),
              const SizedBox(height: 6),
              _dateField(
                text: controller.fromDate.value == null
                    ? 'Select date'
                    : _formatDate(controller.fromDate.value),
                onTap: _pickFromDate,
              ),
              const SizedBox(height: 12),
              const Text('To'),
              const SizedBox(height: 6),
              _dateField(
                text: controller.toDate.value == null
                    ? 'Select date'
                    : _formatDate(controller.toDate.value ?? DateTime.now()),
                onTap: _pickToDate,
              ),
              const SizedBox(height: 16),
              const Text('Reason For Leave'),
              const SizedBox(height: 6),
              TextField(
                controller: controller.reasonController.value,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeController.primaryColor.value,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            print("Button Pressed");

                            if (controller.fromDate.value == null) {
                              Get.snackbar(
                                "Error",
                                "Please select From Date",
                              );
                              return;
                            }

                            if (controller.toDate.value == null) {
                              Get.snackbar(
                                "Error",
                                "Please select To Date",
                              );
                              return;
                            }

                            if (controller.reasonController.value.text
                                .trim()
                                .isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please enter reason",
                              );
                              return;
                            }

                            print("Calling submitLeave...");

                            await controller.submitLeave(
                              context: context,
                              leaveTypeId: controller.leaveType.value,
                              fromDate: controller.fromDate.value!,
                              toDate: controller.toDate.value!,
                              reason:
                                  controller.reasonController.value.text.trim(),
                            );
                          },
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Request Leave",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              )
              // SizedBox(
              //   width: double.infinity,
              //   height: 48,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primaryColor,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //     onPressed: () {
              //       Obx(
              //         () => SizedBox(
              //           width: double.infinity,
              //           height: 48,
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: AppColors.primaryColor,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(10),
              //               ),
              //             ),
              //             onPressed: controller.isSubmitting.value
              //                 ? null
              //                 : () async {
              //                     if (_fromDate == null) {
              //                       Get.snackbar(
              //                           "Error", "Please select From Date");
              //                       return;
              //                     }

              //                     if (_toDate == null) {
              //                       Get.snackbar(
              //                           "Error", "Please select To Date");
              //                       return;
              //                     }

              //                     if (_reasonController.text.trim().isEmpty) {
              //                       Get.snackbar("Error", "Please enter reason");
              //                       return;
              //                     }

              //                     controller.submitLeave(context);
              //                   },
              //             child: controller.isSubmitting.value
              //                 ? const SizedBox(
              //                     height: 20,
              //                     width: 20,
              //                     child: CircularProgressIndicator(
              //                       color: Colors.white,
              //                       strokeWidth: 2,
              //                     ),
              //                   )
              //                 : const Text(
              //                     "Request Leave",
              //                     style: TextStyle(
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.w600,
              //                     ),
              //                   ),
              //           ),
              //         ),
              //       );
              //     },
              //     child: const Text(
              //       'Request Leave',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        }),
      ),
    );
  }

  Widget _leaveRadioRow(List<LeaveCount> leaves) {
    return Row(
      children: leaves.map((leave) {
        final label =
            '${leave.label} (${leave.remaining.toString().padLeft(2, '0')})';

        return Expanded(
          child: Row(
            children: [
              Radio<String>(
                value: leave.key,
                groupValue: controller.leaveType.value,
                onChanged: leave.remaining <= 0
                    ? null
                    : (value) {
                        setState(() {
                          controller.leaveType.value = value!;

                          // Clear dates when changing leave type
                          controller.fromDate.value = null;
                          controller.toDate.value = null;
                        });
                      },
                activeColor: AppColors.primaryColor,
              ),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  // Widget _leaveRadioRow(List<String> labels) {
  //   return Row(
  //     children: labels.map((label) {
  //       return Expanded(
  //         child: Row(
  //           children: [
  //             Radio<String>(
  //               value: label,
  //               groupValue: controller.leaveType.value,
  //               onChanged: (v) =>
  //                   setState(() => controller.leaveType.value = v!),
  //               activeColor: AppColors.primaryColor,
  //             ),
  //             Flexible(
  //               child: Text(label, style: const TextStyle(fontSize: 13)),
  //             ),
  //           ],
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _dateField({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: text == 'Select date' ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            SvgPicture.asset(
              "assets/hrms/calander_date.svg",
              width: 22,
              height: 22,
            ),
          ],
        ),
      ),
    );
  }
}

String _getLeaveLabel(LeaveCount leave) {
  return '${leave.label} (${leave.remaining.toString().padLeft(2, '0')})';
}

String apiDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
