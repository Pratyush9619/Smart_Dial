import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:get/get.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  final ThemeController themeController = Get.find<ThemeController>();
  String? _lastCode;
  bool _torchOn = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scanSize = MediaQuery.of(context).size.width * 0.85;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF808080),
        appBar: AppBar(
          backgroundColor: themeController.primaryColor.value,
          leading: const BackButton(color: Color(0xffFFFFFF)),
          title: const Text(
            "Mark Attendance",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Scan Code',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFFFFFF),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Please Scan the QR to Mark Attendance',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(179, 255, 243, 243),
                ),
              ),
            ),
            SizedBox(height: 30.h),

            // -------- Scanner Box ----------
            Center(
              child: SizedBox(
                width: scanSize,
                height: scanSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MobileScanner(
                        controller: _controller,
                        onDetect: (capture) {
                          final barcode = capture.barcodes.first;
                          final String? code = barcode.rawValue;
                          if (code == null) return;
                          if (_lastCode == code) return;
                          _lastCode = code;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Scanned: $code')),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xffFFFFFF), width: 2),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final dy = _animController.value * scanSize;
                        return Positioned(
                          top: dy,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2.h,
                            color: const Color(0xFF2F6DF6),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // -------- Bottom Controls ----------
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// 🎯 CAMERA BUTTON — ALWAYS CENTER
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _lastCode = null;
                        });
                      },
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xffFFFFFF), width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xffFFFFFF),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/hrms/scan_camera.svg",
                                height: 22.h,
                                width: 22.w,
                                color: themeController.primaryColor.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 🔦 FLASH BUTTON — FIXED RIGHT
                    Positioned(
                      right: 80,
                      child: IconButton(
                        iconSize: 30,
                        icon: Icon(
                          _torchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await _controller.toggleTorch();
                          setState(() => _torchOn = !_torchOn);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
