import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/attendence_controller.dart';

class AttendanceView extends StatelessWidget {
  AttendanceView({super.key});

  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: const Icon(Icons.menu, color: Colors.black),
          title: const Text(
            "Time Tracking",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_none, color: Colors.black),
            )
          ],
        ),
        body: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// GREETING CARD
                _greetingCard(),

                const SizedBox(height: 16),

                /// ATTENDANCE METHOD
                _attendanceMethod(),

                const SizedBox(height: 16),

                //    _attendanceAction(), // Add here

                //     const SizedBox(height: 16),

                /// CAMERA CARD
                _cameraCard(),

                const SizedBox(height: 16),

                /// LOCATION CARD
                _locationCard(),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  // ---------------- UI WIDGETS ----------------

  Widget _attendanceAction() {
    return Obx(() {
      final isPunchedIn = controller.isPunchedIn.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              isPunchedIn
                  ? "You are currently Punched In"
                  : "Ready to start your work",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isPunchedIn) {
                    controller.punch();
                  } else {
                    // controller.markPunchIn();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isPunchedIn ? "MARK OUT" : "MARK IN",
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _greetingCard() {
    final punchedIn = controller.isPunchedIn.value;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: punchedIn ? const Color(0xffFFF1E8) : const Color(0xffEAF7F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            punchedIn ? Icons.wb_twilight : Icons.wb_sunny,
            color: punchedIn ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punchedIn
                      ? "Good evening, ${controller.userName}!"
                      : "Good morning, ${controller.userName}!",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  punchedIn
                      ? "You're doing great today."
                      : "Have a productive day ahead.",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          //   decoration: BoxDecoration(
          //     color:
          //         punchedIn ? const Color(0xffFFD9C8) : const Color(0xffCFF1DE),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     punchedIn ? "PUNCHED IN" : "NOT PUNCHED IN",
          //     style: TextStyle(
          //       fontSize: 11,
          //       color: punchedIn ? Colors.orange : Colors.green,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _attendanceMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Attendance Method",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _methodButton(
              title: "Selfie",
              icon: Icons.person,
              selected: true,
            ),
            const SizedBox(width: 12),
            _methodButton(
              title: "QR Scan",
              icon: Icons.qr_code,
              selected: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _methodButton({
    required String title,
    required IconData icon,
    required bool selected,
  }) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xffEAF7F0) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.green : Colors.grey),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cameraCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            "Position your face in the frame",
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),

          /// CAMERA

          Obx(() {
            if (controller.isAttendanceCompleted.value) {
              return Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.shade200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.check_circle,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Attendance Completed",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You have successfully completed\ntoday's attendance.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            bool isHoliday =
                controller.isHoliday(controller.selectedDate.value);
            if (isHoliday) {
              return Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.shade200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.check_circle,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Holiday",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 280,
                width: double.infinity,
                child: controller.selfie.value == null
                    ? (controller.cameraReady.value
                        ? CameraPreview(controller.cameraController!)
                        : const Center(child: CircularProgressIndicator()))
                    : Image.file(
                        File(controller.selfie.value!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            );
          }),

          // ClipRRect(
          //   borderRadius: BorderRadius.circular(12),
          //   child: SizedBox(
          //     height: 280,
          //     width: double.infinity,
          //     child: controller.selfie.value == null
          //         ? (controller.cameraReady.value
          //             ? CameraPreview(controller.cameraController!)
          //             : const Center(child: CircularProgressIndicator()))
          //         : Image.file(
          //             File(controller.selfie.value!.path),
          //             fit: BoxFit.cover,
          //           ),
          //   ),
          // ),

          const SizedBox(height: 14),

          // Obx(() {
          //   switch (controller.attendanceStatus.value) {
          //     case AttendanceStatus.notPunched:
          //       return PunchInButton();

          //     case AttendanceStatus.punchedIn:
          //       return PunchOutButton();

          //     case AttendanceStatus.punchedOut:
          //       return const SizedBox.shrink(); // Hide both buttons
          //   }
          // }),

          Obx(() {
            if (controller.isAttendanceCompleted.value) {
              return const SizedBox.shrink();
            }

            final isHoliday = controller.isHoliday(
              controller.selectedDate.value,
            );

            if (isHoliday) {
              return const SizedBox(
                child: Text(
                  "Holiday - No Punch Required",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // =========================
                // PUNCH OUT
                // =========================
                if (controller.isPunchedIn.value)
                  _attendanceActionButton(
                    title: "Punch Out",
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    enabled: true,
                    loading: controller.isPunching.value,
                    onTap: () async {
                      await controller.captureSelfie();

                      if (controller.selfie.value != null) {
                        await controller.punch();
                      }
                    },
                  ),

                // =========================
                // PUNCH IN
                // =========================
                if (!controller.isPunchedIn.value)
                  _attendanceActionButton(
                    title: "Punch In",
                    icon: Icons.camera_alt_rounded,
                    color: Colors.green,
                    enabled: true,
                    loading: controller.isPunching.value,
                    onTap: () async {
                      await controller.captureSelfie();

                      if (controller.selfie.value != null) {
                        await controller.punchOut();
                      }
                    },
                  ),
              ],
            );
            // return Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     if (controller.isPunchedIn.value)
            //       _attendanceActionButton(
            //           title: "Punch Out",
            //           icon: Icons.logout_rounded,
            //           color: Colors.red,
            //           enabled: true,
            //           onTap: () async {
            //             // controller.punchOut();
            //             await controller.captureSelfie();
            //           }),
            //     if (!controller.isPunchedIn.value)
            //       _attendanceActionButton(
            //         title: "Punch In",
            //         icon: Icons.camera_alt_rounded,
            //         color: Colors.green,
            //         enabled: true,
            //         loading: controller.isPunching.value,
            //         onTap: () async {
            //           if (controller.selfie.value == null) {
            //             await controller.captureSelfie();
            //           }
            //         },
            //       ),
            //   ],
            // );
          }),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     // MARK LOGOUT
          //     controller.isPunchedIn.value
          //         ? Obx(
          //             () => _attendanceActionButton(
          //                 title: "Punch Out",
          //                 icon: Icons.logout_rounded,
          //                 color: controller.isPunchedIn.value
          //                     ? Colors.red
          //                     : Colors.grey,
          //                 enabled: controller.isPunchedIn.value,
          //                 onTap: () {
          //                   controller.punchOut();
          //                 }),
          //           )
          //         : const SizedBox.shrink(),
          //     const SizedBox(width: 10),

          //     // PUNCH BUTTON
          //     controller.isPunchedIn.value
          //         ? const SizedBox.shrink()
          //         : Obx(
          //             () => _attendanceActionButton(
          //               title: "Punch In",
          //               icon: Icons.camera_alt_rounded,
          //               color: controller.isPunchedIn.value
          //                   ? Colors.orange
          //                   : Colors.green,
          //               enabled: true,
          //               loading: controller.isPunching.value,
          //               onTap: () async {
          //                 if (controller.selfie.value == null) {
          //                   await controller.captureSelfie();
          //                 }
          //                 // await controller.punch();
          //               },
          //             ),
          //           ),
          //   ],
          // )

          // GestureDetector(
          //   onTap: () async {
          //     if (controller.selfie.value == null) {
          //       await controller.captureSelfie();
          //     }

          //     await controller.punch();
          //   },
          //   child: Obx(
          //     () => CircleAvatar(
          //       radius: 30,
          //       backgroundColor:
          //           controller.isPunchedIn.value ? Colors.red : Colors.green,
          //       child: controller.isPunching.value
          //           ? const CircularProgressIndicator(
          //               color: Colors.white,
          //             )
          //           : const Icon(
          //               Icons.camera_alt,
          //               color: Colors.white,
          //               size: 28,
          //             ),
          //     ),
          //   ),
          // ),

          /// CAPTURE BUTTON
          ///
          ///
          // GestureDetector(
          //   onTap: () {
          //     if (controller.selfie.value == null) {
          //       controller.captureSelfie();
          //     }
          //     //  else {
          //     //   controller.punch();
          //     // }
          //   },
          //   child: CircleAvatar(
          //     radius: 30,
          //     backgroundColor:
          //         controller.isPunchedIn.value ? Colors.red : Colors.green,
          //     child:
          //         const Icon(Icons.camera_alt, color: Colors.white, size: 28),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _attendanceActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool enabled,
    bool loading = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 145,
        height: 55,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color:
              enabled ? color.withOpacity(0.12) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled ? color : Colors.grey,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  color: color,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color,
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _locationCard() {
    return Obx(() {
      final ok = controller.locationAllowed.value;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: ok ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Office Location",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    controller.address.value,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              ok ? "Within range" : "Out of range",
              style: TextStyle(
                color: ok ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month), label: "Attendance"),
        BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Timesheet"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
