import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/models/profile_model.dart';
import 'package:smart_solutions/views/holiday_screen.dart';
import 'package:smart_solutions/views/hrms/holidaylist_page.dart';
import 'package:smart_solutions/views/hrms/request_leave_page.dart';
import 'package:smart_solutions/views/hrms/view_attendence_page.dart';
import 'package:smart_solutions/views/profile.dart';
import 'package:smart_solutions/views/sallary_slip.dart';
import 'package:smart_solutions/views/request_leave.dart';
import 'package:smart_solutions/views/view_attendance.dart';
import 'package:smart_solutions/widget/profile_scaffold.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final List<GridItem> items = [
    GridItem(Icons.person_outline, 'Profile'),
    GridItem(Icons.fingerprint, 'Mark Attendance'),
    GridItem(Icons.calendar_month, 'View Attendance'),
    GridItem(Icons.beach_access, 'Request Leave'),
    GridItem(Icons.folder_open, 'Documents'),
    GridItem(Icons.announcement, 'Holiday List'),
  ];

  List<Widget> allPages = [
    const ProfileListPage(),
    const RequestLeavePage(),
    const ViewAttendancePage(),
    const RequestLeavePage(),
    const DocumentsPage(),
    HolidayListPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      title: '',
      height: 300,
      showBack: true,
      bodyPadding: 170,
      body: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(), // Disable internal scroll
        shrinkWrap: true,
        itemCount: items.length, // Change as needed
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: buildGridItem(
                    index, item.icon!, item.title!, allPages[index])),
          );
        },
      ),
    );
  }
}

// Widget buildGridItem(int index, IconData icon, String title, Widget toPage) {
//   return Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: () {
//         Get.to(toPage);
//         // Handle onTap
//       },
//       splashColor: const Color(0xFF356EFF).withOpacity(0.2),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFF356EFF).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               icon,
//               size: 32,
//               color: const Color(0xFF356EFF),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
Widget buildGridItem(int index, IconData icon, String title, Widget toPage) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () => Get.to(toPage),
    splashColor: const Color(0xFF356EFF).withOpacity(0.1),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with Gradient
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF356EFF),
                  Color(0xFF5A7FFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF356EFF).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),

          const SizedBox(height: 14),

          // Title Text
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // Divider accent line (optional aesthetic)
          Container(
            width: 24,
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFF356EFF).withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ),
  );
}
