import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/controllers/sallary_slip_controller.dart';
import 'package:smart_solutions/views/sallary_pdf_viewer.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SallarySlipController());

    // Example: Load salary slip from API or URL
    controller
        .loadSalarySlip("https://example.com/salary_slips/october_2025.pdf");

    return CommonScaffold(
      title: 'My Document',
      body: Obx(() {
        final url = controller.salarySlipUrl.value;

        if (url.isEmpty) {
          return const Center(
            child: Text(
              "No Salary Slip Available",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      Get.to(const SalarySlipPdfPage(
                        month: 'sele',
                      ));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.picture_as_pdf,
                                color: Colors.red, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              "Salary Slip - October 2025",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.blueAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.grey, size: 18),
                        ],
                      ),
                    ));
              },
            )

            //  Column(
            //   children: [
            //     // Header section
            //     Container(
            //       padding: const EdgeInsets.all(12),
            //       decoration: BoxDecoration(
            //         color: AppColors.primaryColor.withOpacity(0.5),
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Row(
            //         children: [
            //           Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
            //           SizedBox(width: 10),
            //           Text(
            //             "Salary Slip - October 2025",
            //             style: TextStyle(
            //               fontSize: 16,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),

            //     const SizedBox(height: 12),

            //     // PDF viewer section
            //     Expanded(
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(12),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black12,
            //               blurRadius: 8,
            //               offset: const Offset(0, 3),
            //             ),
            //           ],
            //         ),
            //         child: ClipRRect(
            //           borderRadius: BorderRadius.circular(12),
            //           child: SfPdfViewer.network(url),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            );
      }),
    );
  }
}
