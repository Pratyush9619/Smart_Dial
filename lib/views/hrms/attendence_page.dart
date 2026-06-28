import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/attendence_controller.dart';

class AttendancePage extends GetView<AttendanceController> {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.officeLocation,
                zoom: 16,
              ),
              myLocationEnabled: true,
              circles: {
                Circle(
                  circleId: const CircleId("zone"),
                  center: controller.officeLocation,
                  radius: 150,
                  fillColor: Colors.green.withOpacity(0.2),
                  strokeColor: Colors.green,
                  strokeWidth: 2,
                )
              },
            ),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      "Distance: ${controller.userDistance.value.toStringAsFixed(2)} meters",
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: controller.canMarkAttendance.value
                          ? controller.markAttendance
                          : null,
                      child: const Text("Mark Attendance"),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed("/qr"),
                      child: const Text("Scan QR Code"),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
