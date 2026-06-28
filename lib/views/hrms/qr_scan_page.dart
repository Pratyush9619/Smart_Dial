import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../controllers/attendence_controller.dart';

class QRScanPage extends GetView<AttendanceController> {
  const QRScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        onDetect: (barcode) {
          final code = barcode.barcodes.first.rawValue;
          if (code == "OFFICE_ATTENDANCE_2026") {
            Get.back();
            controller.markAttendance();
          }
        },
      ),
    );
  }
}
