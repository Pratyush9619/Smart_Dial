import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/attendence_controller.dart';

class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({super.key});

  @override
  State<ViewAttendancePage> createState() => _ViewAttendancePageState();
}

// yahan hum sirf date -> color store karenge
class _ViewAttendancePageState extends State<ViewAttendancePage> {
  DateTime focusedDay = DateTime.now();

  DateTime? selectedDay = DateTime.now();

// state for calendar format
  CalendarFormat _format = CalendarFormat.month;

// current month and year
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // helper: sirf date part (time hata do)
  DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  // helper: convert month number to month name
  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // jis date ka box color change karna hai, usko yahan add karo
  final Map<DateTime, Color> dayColors = {};

  AttendanceController controller = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();

    selectedDay = DateTime.now();
    focusedDay = DateTime.now();

    controller.getMonthlyAttendance(
      month: DateTime.now().month,
      year: DateTime.now().year,

      // date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    controller.onDateSelected(
      selectedDay!,
      focusedDay,
    );

    // sample colored days
    dayColors[onlyDate(DateTime(2022, 11, 1))] = const Color(
      0xFFE74C3C,
    ); // absent - red
    dayColors[onlyDate(DateTime(2022, 11, 2))] = const Color(
      0xFF2ECC71,
    ); // present - green
    dayColors[onlyDate(DateTime(2022, 11, 10))] = const Color(
      0xFFF2A33A,
    ); // half-day - orange

    // mark Sundays as week off (grey)
    for (int d = 1; d <= 31; d++) {
      final date = DateTime(2022, 11, d);
      if (date.month != 11) continue;
      if (date.weekday == DateTime.sunday) {
        dayColors[onlyDate(date)] = Colors.grey.shade700;
      }
    }

    selectedDay = focusedDay;
    selectedMonth = focusedDay.month;
    selectedYear = focusedDay.year;
  }

  // change calendar view month/week

  // when month or year dropdown changes, jump calendar to first day of selected month/year
  void _onMonthYearChanged(int month, int year, String date) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
      focusedDay = DateTime(year, month, 1);
    });

    controller.getMonthlyAttendance(
      month: month,
      year: year,
    );
  }

  Widget buildDayCell(
    DateTime day, {
    bool isSelected = false,
    String? status,
  }) {
    // Color color = Colors.white;

    Color bgColor = Colors.grey;
    Color textColor = Colors.black;

    print(status);

    switch (status) {
      case "Present":
        bgColor = Colors.green;
        textColor = Colors.white;
        break;

      case "Absent":
        bgColor = Colors.red;
        textColor = Colors.white;
        break;

      case "Half Day":
        bgColor = Colors.yellow;
        textColor = Colors.black;
        break;

      case "Late Mark":
        bgColor = Colors.orange;
        textColor = Colors.white;
        break;

      case "Paid Leave":
        bgColor = Colors.amber;
        textColor = Colors.white;
        break;

      case "Sunday":
        bgColor = Colors.grey;
        textColor = Colors.black;
        break;

      case "Holiday (Holiday)":
        bgColor = Colors.purpleAccent;
        textColor = Colors.white;
        break;
      case "Week Off":
        bgColor = Colors.grey;
        textColor = Colors.black;
        break;

      default:
        bgColor = Colors.grey.shade300;
        textColor = Colors.black;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            //isSelected ? Colors.blue :
            bgColor,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
      ),
      child: Center(
        child: Text(
          "${day.day}",
          style: TextStyle(
            color: isSelected ? Colors.black : textColor,
          ),
        ),
      ),
    );
  }
  // // Reusable day cell builder (color box)
  // Widget buildDayCell(DateTime day, {bool isSelected = false}) {
  //   final Color? color = dayColors[onlyDate(day)];
  //   Color bg = color ?? Colors.transparent;
  //   Color textColor = color == null ? Colors.black : Color(0xffFFFFFF);

  //   // today detection
  //   final bool isToday = onlyDate(day) == onlyDate(DateTime.now());

  //   // if selected but no special color, give a faint blue bg
  //   if (isSelected && color == null) {
  //     bg = const Color(0xFF2F6DF6).withValues(alpha: 0.15);
  //     textColor = const Color.fromARGB(255, 255, 255, 255);
  //   }

  //   // decoration: border if today & not colored
  //   final BoxDecoration decoration = BoxDecoration(
  //     color: bg,
  //     borderRadius: BorderRadius.circular(6),
  //     border: isToday && color == null
  //         ? Border.all(color: const Color(0xFF2F6DF6), width: 1.2)
  //         : null,
  //   );

  //   return Center(
  //     child: Container(
  //       width: 40,
  //       height: 40,
  //       decoration: decoration,
  //       alignment: Alignment.center,
  //       child: Text(
  //         '${day.day}',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           color: textColor,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // build list of month DropdownMenuItems

  List<DropdownMenuItem<int>> _monthItems() {
    return List.generate(12, (i) {
      final m = i + 1;
      return DropdownMenuItem(value: m, child: Text(_monthName(m)));
    });
  }

  // build list of year DropdownMenuItems (2020..2030)
  List<DropdownMenuItem<int>> _yearItems() {
    return List.generate(11, (i) {
      final y = 2020 + i;
      return DropdownMenuItem(value: y, child: Text('$y'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = controller.response;

    return CommonScaffold(
      title: "View Attendance",
      body: SingleChildScrollView(
        child: Obx(() {
          final attendance = controller.selectedAttendance.value;
          final data = controller.response;

          if (data == null) return const SizedBox();

          return Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- LEAVE TYPE ROW ----------
                // const Padding(
                //   padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                //   child: Text(
                //     'Leave Type',
                //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                //   ),
                // ),

                // if (controller.isLoading.value) {
                //   return const Center(child: CircularProgressIndicator());
                // }

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          LeaveTypeCard(
                            title: "Present",
                            count: data.totalPresent.toString(),
                            borderColor: Colors.green,
                            bgColor: Colors.green.withOpacity(0.12),
                          ),
                          LeaveTypeCard(
                            title: "Absent",
                            count: data.totalLeave.toString(),
                            borderColor: Colors.red,
                            bgColor: Colors.red.withOpacity(0.12),
                          ),
                          LeaveTypeCard(
                            title: "Half Day",
                            count: data.halfDays.toString(),
                            borderColor: Colors.yellow,
                            bgColor: Colors.yellow.withOpacity(0.20),
                          ),
                          LeaveTypeCard(
                            title: "Late Mark",
                            count: data.lateMarks.toString(), // if available
                            borderColor: Colors.orange,
                            bgColor: Colors.orange.withOpacity(0.12),
                          ),
                          LeaveTypeCard(
                            title: "Paid Leave",
                            count: data.paidLeave.toString(),
                            borderColor: Colors.amber,
                            bgColor: Colors.amber.withOpacity(0.12),
                          ),
                          LeaveTypeCard(
                            title: "Holiday",
                            count: data.totalApprovedLeave
                                .toString(), // if available
                            borderColor: Colors.purpleAccent,
                            bgColor: Colors.purpleAccent.withOpacity(0.15),
                          ),
                          LeaveTypeCard(
                            title: "Week Off",
                            count: data.weekOff.toString(),
                            borderColor: Colors.grey,
                            bgColor: Colors.grey.withOpacity(0.15),
                          ),
                        ],
                      )
                      //  ListView(
                      //   scrollDirection: Axis.horizontal,
                      //   children: [
                      //     LeaveTypeCard(
                      //       title: "Present",
                      //       count: data.totalPresent.toString(),
                      //       borderColor: Colors.green,
                      //       bgColor: const Color(0xFFE8F8F0),
                      //     ),
                      //     LeaveTypeCard(
                      //       title: "Absent",
                      //       count: data.totalLeave.toString(),
                      //       borderColor: Colors.red,
                      //       bgColor: const Color(0xFFFDECEC),
                      //     ),
                      //     LeaveTypeCard(
                      //       title: "Half Day",
                      //       count: data.halfDays.toString(),
                      //       borderColor: Colors.orange,
                      //       bgColor: const Color(0xFFFFF4E5),
                      //     ),
                      //     LeaveTypeCard(
                      //       title: "Paid Leave",
                      //       count: data.paidLeave.toString(),
                      //       borderColor: Colors.deepPurple,
                      //       bgColor: const Color(0xFFEDE9FF),
                      //     ),
                      //     LeaveTypeCard(
                      //       title: "Holiday",
                      //       count: data.weekOff.toString(),
                      //       borderColor: Colors.grey,
                      //       bgColor: const Color(0xFFF1F1F1),
                      //     ),
                      //     LeaveTypeCard(
                      //       title: "Week Off",
                      //       count: data.weekOff.toString(),
                      //       borderColor: Colors.grey,
                      //       bgColor: const Color(0xFFF1F1F1),
                      //     ),
                      //   ],
                      // ),

                      ),
                ),

                const Divider(
                  height: 0,
                  thickness: 0.5,
                  color: Colors.grey,
                ),

                // SizedBox(
                //   height: 72,
                //   child: ListView(
                //     scrollDirection: Axis.horizontal,
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     children: const [
                //       LeaveTypeCard(
                //         title: 'Present',
                //         count: '01',
                //         borderColor: Color(0xFF2ECC71),
                //         bgColor: Color(0xFFE8F8F0),
                //       ),
                //       LeaveTypeCard(
                //         title: 'Absent',
                //         count: '03',
                //         borderColor: Color(0xFFE74C3C),
                //         bgColor: Color(0xFFFDECEC),
                //       ),
                //       LeaveTypeCard(
                //         title: 'Half day',
                //         count: '01',
                //         borderColor: Color(0xFFF2A33A),
                //         bgColor: Color(0xFFFFF4E5),
                //       ),
                //       LeaveTypeCard(
                //         title: 'Paid Leave',
                //         count: '01',
                //         borderColor: Color(0xFF7D60FF),
                //         bgColor: Color(0xFFEDE9FF),
                //       ),
                //       LeaveTypeCard(
                //         title: 'Week Off',
                //         count: '01',
                //         borderColor: Color(0xFF828282),
                //         bgColor: Color(0xFFF1F1F1),
                //       ),
                //     ],
                //   ),
                // ),

                //    const SizedBox(height: 8),
                const Divider(thickness: 1, color: (Color(0xFFE0E0E0))),

                // ---------- CALENDAR ----------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Obx(() {
                    controller.attendanceList.length; // Listen to changes

                    return TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      currentDay: DateTime.now(),
                      focusedDay: focusedDay,
                      calendarFormat: _format,
                      rowHeight: 48,
                      daysOfWeekHeight: 25,

                      // Remove extra space
                      headerStyle: const HeaderStyle(
                        headerPadding: EdgeInsets.zero,
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),

                      startingDayOfWeek: StartingDayOfWeek.monday,

                      // tell TableCalendar which day is selected
                      selectedDayPredicate: (day) =>
                          onlyDate(day) == onlyDate(selectedDay ?? DateTime(0)),

                      // controller.selectedAttendance.value =
                      //     controller.attendanceOf(day);

                      onDaySelected: (day, focusedDay) {
                        setState(() {
                          selectedDay = day;
                          this.focusedDay = focusedDay;
                        });

                        controller.getMonthlyAttendance(
                          month: day.month,
                          year: day.year,
                        );

                        controller.onDateSelected(
                          selectedDay!,
                          focusedDay,
                        );
                      },

                      // When calendar is swiped to another month
                      onPageChanged: (newFocusedDay) async {
                        setState(() {
                          focusedDay = newFocusedDay;

                          selectedMonth = newFocusedDay.month;
                          selectedYear = newFocusedDay.year;
                        });

                        // Get attendance for the newly visible month
                        await controller.getMonthlyAttendance(
                          month: newFocusedDay.month,
                          year: newFocusedDay.year,
                        );

                        // Update selected attendance after API data is loaded
                        controller.onDateSelected(
                          selectedDay ?? newFocusedDay,
                          newFocusedDay,
                        );
                      },

                      // disable internal chevrons because header is custom
                      // headerStyle: const HeaderStyle(
                      //   formatButtonVisible: false,
                      //   titleCentered: false,
                      //   leftChevronVisible: false,
                      //   rightChevronVisible: false,
                      //   titleTextStyle: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w600,
                      //     color: Colors.black,
                      //   ),
                      // ),

                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        isTodayHighlighted: false,
                      ),

                      calendarBuilders: CalendarBuilders(
                        // custom header with dropdowns for month & year
                        headerTitleBuilder: (context, day) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Month dropdown
                                Row(
                                  children: [
                                    DropdownButton<int>(
                                      value: selectedMonth,
                                      underline: const SizedBox(),
                                      items: _monthItems(),
                                      onChanged: (m) {
                                        if (m == null) return;
                                        _onMonthYearChanged(m, selectedYear,
                                            selectedDay.toString());
                                      },
                                      // small caret to match UI
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                    ),
                                  ],
                                ),

                                // Year dropdown
                                Row(
                                  children: [
                                    DropdownButton<int>(
                                      value: selectedYear,
                                      underline: const SizedBox(),
                                      items: _yearItems(),
                                      onChanged: (y) {
                                        if (y == null) return;
                                        _onMonthYearChanged(selectedMonth, y,
                                            selectedDay.toString());
                                      },
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },

                        // // default days
                        // defaultBuilder: (context, day, focusedDay) {
                        //   final isSelected =
                        //       onlyDate(day) == onlyDate(selectedDay ?? DateTime(0));
                        //   return buildDayCell(day, isSelected: isSelected);
                        // },

                        defaultBuilder: (context, day, focusedDay) {
                          final attendance = controller.attendanceOf(day);

                          return buildDayCell(
                            day,
                            isSelected: onlyDate(day) ==
                                onlyDate(selectedDay ?? DateTime(0)),
                            status: attendance?.status,
                          );
                        },

                        selectedBuilder: (context, day, focusedDay) {
                          final attendance = controller.attendanceOf(day);

                          return buildDayCell(
                            day,
                            isSelected: true,
                            status: attendance?.status,
                          );
                        },

                        todayBuilder: (context, day, focusedDay) {
                          final attendance = controller.attendanceOf(day);

                          return buildDayCell(
                            day,
                            isSelected: onlyDate(day) ==
                                onlyDate(selectedDay ?? DateTime(0)),
                            status: attendance?.status,
                          );
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),
                const Divider(thickness: 6, color: (Color(0xFFE0E0E0))),

                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LogCard(
                            isLogin: true,
                            dateTime: attendance?.punchInTime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LogCard(
                            isLogin: false,
                            dateTime: attendance?.punchOutTime,
                          ),
                        ),
                      ],
                    ),

                    // Working Hours Section
                    if (attendance?.workingHours != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Working Hours: ${attendance!.workingHours} hrs",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // ---------- LOG IN / LOG OUT CARDS ----------
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   child: Row(
                //     children: [
                //       Expanded(child: LogCard(isLogin: true)),
                //       SizedBox(width: 12),
                //       Expanded(child: LogCard(isLogin: false)),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 16),
              ],
            ),
            Obx(() {
              if (!controller.isLoading.value) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.08),
                  alignment: Alignment.center,
                  child: Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ),
              );
            }),
          ]);
        }),
      ),
    );
  }
}

// =============== SIMPLE WIDGETS ===============

class LeaveTypeCard extends StatelessWidget {
  final String title;
  final String count;
  final Color borderColor;
  final Color bgColor;

  const LeaveTypeCard({
    super.key,
    required this.title,
    required this.count,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return //   width: 80,
        //   height: 60,
        //   margin: const EdgeInsets.only(right: 6),
        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: bgColor,
        //     borderRadius: BorderRadius.circular(4),
        //     border: Border.all(color: borderColor, width: 1),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         title,
        //         maxLines: 1,
        //         overflow: TextOverflow.ellipsis,
        //         style: const TextStyle(
        //           fontSize: 10,
        //           fontWeight: FontWeight.w500,
        //         ),
        //       ),
        //       Text(
        //         count,
        //         style: const TextStyle(
        //           fontSize: 14,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ],
        //   ),
        // );

        Container(
      width: 85,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            count,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class LogCard extends StatelessWidget {
  final bool isLogin;
  final String? dateTime;
  final String? workingHours;

  const LogCard({
    super.key,
    required this.isLogin,
    this.dateTime,
    this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? parsedDate;

    if (dateTime != null && dateTime!.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateTime!);
    }

    final String time =
        parsedDate != null ? DateFormat('hh:mm a').format(parsedDate) : '--:--';

    final String date = parsedDate != null
        ? DateFormat('dd MMM yyyy').format(parsedDate)
        : '--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    isLogin ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  isLogin ? Icons.login : Icons.logout,
                  size: 18,
                  color: isLogin ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isLogin ? "Punch In" : "Punch Out",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// class LogCard extends StatelessWidget {
//   final bool isLogin;

//   const LogCard({super.key, required this.isLogin});

//   @override
//   Widget build(BuildContext context) {
//     final Color iconBg =
//         isLogin ? const Color(0xFFE6F6EC) : const Color(0xFFFDE9E9);
//     final Color iconColor = isLogin
//         ? const Color.from(alpha: 1, red: 0.18, green: 0.8, blue: 0.443)
//         : const Color(0xFFE74C3C);
//     final Color cardBg =
//         isLogin ? const Color(0xFFE6F6EC) : const Color(0xFFFDE9E9);

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: cardBg,
//         borderRadius: BorderRadius.circular(0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 26,
//                 height: 26,
//                 decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: SvgPicture.asset(
//                   isLogin ? 'assets/hrms/login.svg' : 'assets/hrms/logout.svg',
//                   width: 18,
//                   height: 18,
//                   //ignore:deprecated_member_use
//                   color: iconColor, // optional → applies tint
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 isLogin ? 'LOG IN' : 'LOG OUT',
//                 style: const TextStyle(
//                   color: Color(0xFF757575),
//                   fontSize: 18,
//                   // fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             '10:12:32 AM',
//             style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'Madhuban,Vasai west\n401207',
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.w300,
//               color: Color(0xFF757575),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
