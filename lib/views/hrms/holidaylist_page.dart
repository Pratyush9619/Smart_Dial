import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';

import '../../controllers/holiday_controller.dart';

class HolidayListPage extends StatelessWidget {
  HolidayListPage({super.key});

  final controller = Get.put(HolidayController());

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "Holiday List",
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                children: controller.groupedHoliday.entries.expand((entry) {
                  return [
                    _SectionTitle(entry.key),
                    const SizedBox(height: 8),
                    ...entry.value.map((holiday) {
                      final date = DateTime.parse(holiday.date);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HolidayCard(
                          title: holiday.title,
                          weekday: DateFormat('EEEE').format(date),
                          dateText: DateFormat('dd MMM yyyy').format(date),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ];
                }).toList(),
              ),
      ),
    );
  }
}

// ---------- Section heading ----------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }
}

// ---------- Holiday card ----------
class _HolidayCard extends StatelessWidget {
  final String title;
  final String weekday;
  final String dateText;

  const _HolidayCard({
    required this.title,
    required this.weekday,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.all(2), // this will act as border thickness
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFDEEDFF), Color(0xFFD2E7FF)], // gradient border
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFD2E7FF)
            ], // inner content background
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            // LEFT SIDE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // RIGHT DATE
            Text(
              dateText,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
