import 'package:flutter/material.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({super.key});

  @override
  State<ViewAttendancePage> createState() => _ViewAttendancePageState();
}

// yahan hum sirf date -> color store karenge
class _ViewAttendancePageState extends State<ViewAttendancePage> {
  DateTime focusedDay = DateTime(2022, 11, 2);
  DateTime? selectedDay;

  // state for calendar format
  CalendarFormat _format = CalendarFormat.month;

  // dropdown selected values (month: 1..12, year)
  int selectedMonth = DateTime(2022, 11, 2).month;
  int selectedYear = DateTime(2022, 11, 2).year;

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

  @override
  void initState() {
    super.initState();

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
  void _onMonthYearChanged(int month, int year) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
      focusedDay = DateTime(year, month, 1);
      selectedDay = focusedDay;
    });
  }

  // Reusable day cell builder (color box)
  Widget buildDayCell(DateTime day, {bool isSelected = false}) {
    final Color? color = dayColors[onlyDate(day)];
    Color bg = color ?? Colors.transparent;
    Color textColor = color == null ? Colors.black : Color(0xffFFFFFF);

    // today detection
    final bool isToday = onlyDate(day) == onlyDate(DateTime.now());

    // if selected but no special color, give a faint blue bg
    if (isSelected && color == null) {
      bg = const Color(0xFF2F6DF6).withValues(alpha: 0.15);
      textColor = const Color.fromARGB(255, 255, 255, 255);
    }

    // decoration: border if today & not colored
    final BoxDecoration decoration = BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: isToday && color == null
          ? Border.all(color: const Color(0xFF2F6DF6), width: 1.2)
          : null,
    );

    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: decoration,
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

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
    return CommonScaffold(
      title: "View Attendance",
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- LEAVE TYPE ROW ----------
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Leave Type',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  LeaveTypeCard(
                    title: 'Present',
                    count: '01',
                    borderColor: Color(0xFF2ECC71),
                    bgColor: Color(0xFFE8F8F0),
                  ),
                  LeaveTypeCard(
                    title: 'Absent',
                    count: '03',
                    borderColor: Color(0xFFE74C3C),
                    bgColor: Color(0xFFFDECEC),
                  ),
                  LeaveTypeCard(
                    title: 'Half day',
                    count: '01',
                    borderColor: Color(0xFFF2A33A),
                    bgColor: Color(0xFFFFF4E5),
                  ),
                  LeaveTypeCard(
                    title: 'Paid Leave',
                    count: '01',
                    borderColor: Color(0xFF7D60FF),
                    bgColor: Color(0xFFEDE9FF),
                  ),
                  LeaveTypeCard(
                    title: 'Week Off',
                    count: '01',
                    borderColor: Color(0xFF828282),
                    bgColor: Color(0xFFF1F1F1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(thickness: 1, color: (Color(0xFFE0E0E0))),

            // ---------- CALENDAR ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: focusedDay,
                calendarFormat: _format,
                startingDayOfWeek: StartingDayOfWeek.monday,

                // tell TableCalendar which day is selected
                selectedDayPredicate: (day) =>
                    onlyDate(day) == onlyDate(selectedDay ?? DateTime(0)),

                onDaySelected: (day, newFocusedDay) {
                  setState(() {
                    selectedDay = day;
                    focusedDay = newFocusedDay;
                    // keep dropdowns in sync
                    selectedMonth = focusedDay.month;
                    selectedYear = focusedDay.year;
                  });
                },

                // disable internal chevrons because header is custom
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: false,
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

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
                                  _onMonthYearChanged(m, selectedYear);
                                },
                                // small caret to match UI
                                icon: const Icon(Icons.keyboard_arrow_down),
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
                                  _onMonthYearChanged(selectedMonth, y);
                                },
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },

                  // default days
                  defaultBuilder: (context, day, focusedDay) {
                    final isSelected =
                        onlyDate(day) == onlyDate(selectedDay ?? DateTime(0));
                    return buildDayCell(day, isSelected: isSelected);
                  },

                  selectedBuilder: (context, day, focusedDay) {
                    return buildDayCell(day, isSelected: true);
                  },

                  todayBuilder: (context, day, focusedDay) {
                    final isSelected =
                        onlyDate(day) == onlyDate(selectedDay ?? DateTime(0));
                    return buildDayCell(day, isSelected: isSelected);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(thickness: 6, color: (Color(0xFFE0E0E0))),

            // ---------- LOG IN / LOG OUT CARDS ----------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: LogCard(isLogin: true)),
                  SizedBox(width: 12),
                  Expanded(child: LogCard(isLogin: false)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  const LogCard({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    final Color iconBg =
        isLogin ? const Color(0xFFE6F6EC) : const Color(0xFFFDE9E9);
    final Color iconColor = isLogin
        ? const Color.from(alpha: 1, red: 0.18, green: 0.8, blue: 0.443)
        : const Color(0xFFE74C3C);
    final Color cardBg =
        isLogin ? const Color(0xFFE6F6EC) : const Color(0xFFFDE9E9);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  isLogin ? 'assets/hrms/login.svg' : 'assets/hrms/logout.svg',
                  width: 18,
                  height: 18,
                  //ignore:deprecated_member_use
                  color: iconColor, // optional → applies tint
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isLogin ? 'LOG IN' : 'LOG OUT',
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 18,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '10:12:32 AM',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          const SizedBox(height: 12),
          const Text(
            'Madhuban,Vasai west\n401207',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w300,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}
