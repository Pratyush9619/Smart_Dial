import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/widget/common_form_field.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';

import '../../controllers/hrms/profile_controller.dart';

// class CurrentEmploymentPage extends StatefulWidget {
//   const CurrentEmploymentPage({super.key});

//   // static const Color primaryBlue = Color(0xFF2F6DF6);
//   // static const Color borderGrey = Color(0xFFE0E0E0);
//   // static const Color textGrey = Color.fromARGB(255, 27, 26, 26);
//   // static const Color labelColor = Color.fromARGB(255, 62, 59, 59);

//   @override
//   State<CurrentEmploymentPage> createState() => _CurrentEmploymentPageState();
// }

// class _CurrentEmploymentPageState extends State<CurrentEmploymentPage> {
//   // Controllers
//   final TextEditingController branchController = TextEditingController(
//       // text: 'Smart Solution Main Branch',
//       );
//   final TextEditingController employeeIdController = TextEditingController(
//       // text: 'SS-001',
//       );
//   final TextEditingController emailController = TextEditingController(
//       // text: 'chiragwadhwani29@gmail.com',
//       );
//   final TextEditingController pfController = TextEditingController(
//       // text: '63620hc762g',
//       );
//   final TextEditingController esiController = TextEditingController(
//       // text: '63620hc762g',
//       );
//        final ThemeController themeController = Get.find<ThemeController>();

//   String department = 'All Departments Assigned';
//   String employeeType = 'Full Time';
//   String jobTitle = 'Back Office';

//   DateTime? joiningDate;
//   DateTime? leavingDate;

//   String _formatDate(DateTime? date) {
//     if (date == null) return '';
//     return '${date.day.toString().padLeft(2, '0')} '
//         '${_monthName(date.month)} '
//         '${date.year}';
//   }

//   String _monthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }

//   Future<void> _pickDate(bool isJoining) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isJoining) {
//           joiningDate = picked;
//         } else {
//           leavingDate = picked;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CommonScaffold(
//       title: "Current Employment",
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CommonTextField(label: "Branch", controller: branchController),
//             CommonDropdownField(
//               label: "Departments",
//               value: department,
//               items: const ['All Departments Assigned', 'HR', 'Finance', 'IT'],
//               onChanged: (v) => setState(() => department = v!),
//             ),
//             CommonDropdownField(
//               label: "Employee Type",
//               value: employeeType,
//               items: const ['Full Time', 'Part Time', 'Contract'],
//               onChanged: (v) => setState(() => employeeType = v!),
//             ),
//             CommonDropdownField(
//               label: "Job Title",
//               value: jobTitle,
//               items: const ['Back Office', 'Manager', 'Supervisor'],
//               onChanged: (v) => setState(() => jobTitle = v!),
//             ),
//             CommonDateField(
//               label: 'Date of Joining',
//               value: joiningDate == null ? '' : _formatDate(joiningDate),
//               onTap: () => _pickDate(true),
//             ),
//             CommonDateField(
//               label: 'Date of Leaving',
//               value: leavingDate == null ? '' : _formatDate(leavingDate),
//               onTap: () => _pickDate(false),
//             ),
//             CommonTextField(
//                 label: "Emoloyee ID", controller: employeeIdController),
//             CommonTextField(
//                 label: "Official Email ID", controller: emailController),
//             CommonTextField(label: "PF A/C.", controller: pfController),
//             CommonTextField(label: "ESI A/C No.", controller: esiController),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 1),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: themeController.primaryColor.value,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   onPressed: () {},
//                   child: const Text(
//                     'Save Details',
//                     style: TextStyle(
//                       color: Color(0xffFFFFFF),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

class CurrentEmploymentPage extends StatefulWidget {
  const CurrentEmploymentPage({super.key});

  @override
  State<CurrentEmploymentPage> createState() => _CurrentEmploymentPageState();
}

class _CurrentEmploymentPageState extends State<CurrentEmploymentPage> {
  final ThemeController themeController = Get.find<ThemeController>();

  final ViewProfileController controller = Get.find<ViewProfileController>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController branchController = TextEditingController();

  final TextEditingController employeeIdController = TextEditingController();

  final TextEditingController pfController = TextEditingController();

  // ============================================================
  // DROPDOWN DEFAULTS
  // ============================================================

  String department = 'All Departments Assigned';

  String jobTitle = 'Back Office';

  // ============================================================
  // DATES
  // ============================================================

  DateTime? joiningDate;

  DateTime? leavingDate;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _fillEmploymentData();

    ever(controller.profile, (_) {
      if (mounted) {
        _fillEmploymentData();
      }
    });
  }

  // ============================================================
  // FILL API DATA
  // ============================================================

  void _fillEmploymentData() {
    final profile = controller.profile.value;

    if (profile == null) return;

    final employment = profile.currentEmployment;

    if (employment == null) return;

    setState(() {
      // branch
      branchController.text = employment.branch ?? '';

      // department
      department = employment.department?.trim().isNotEmpty == true
          ? employment.department!
          : 'All Departments Assigned';

      // office title
      jobTitle = employment.officeTitle?.trim().isNotEmpty == true
          ? employment.officeTitle!
          : 'Back Office';

      // employee id
      employeeIdController.text = employment.employeeId ?? '';

      // joining date
      if (employment.joiningDate != null &&
          employment.joiningDate!.trim().isNotEmpty) {
        joiningDate = _parseDate(employment.joiningDate!);
      } else {
        joiningDate = null;
      }

      // leaving date
      if (employment.dateOfLeaving != null &&
          employment.dateOfLeaving!.trim().isNotEmpty) {
        leavingDate = _parseDate(employment.dateOfLeaving!);
      } else {
        leavingDate = null;
      }

      // PF account
      pfController.text = employment.pfAccountNo ?? '';
    });
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  DateTime? _parseDate(String value) {
    try {
      if (value.contains(' ')) {
        value = value.split(' ').first;
      }

      return DateTime.tryParse(value);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} '
        '${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // ============================================================
  // PICK DATE
  // ============================================================

  Future<void> _pickDate(bool isJoining) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isJoining
          ? joiningDate ?? DateTime.now()
          : leavingDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isJoining) {
          joiningDate = picked;
        } else {
          leavingDate = picked;
        }
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _saveDetails() {
    debugPrint('Branch: ${branchController.text}');
    debugPrint('Department: $department');
    debugPrint('Office Title: $jobTitle');
    debugPrint(
      'Employee ID: ${employeeIdController.text}',
    );
    debugPrint(
      'Joining Date: ${_formatDate(joiningDate)}',
    );
    debugPrint(
      'Date Of Leaving: ${_formatDate(leavingDate)}',
    );
    debugPrint(
      'PF Account: ${pfController.text}',
    );

    // TODO: Update API
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    branchController.dispose();
    employeeIdController.dispose();
    pfController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "Current Employment",
      body: Obx(
        () {
          if (controller.isLoading.value && controller.profile.value == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // BRANCH
                // ==================================================

                CommonTextField(
                  label: "Branch",
                  controller: branchController,
                ),

                // ==================================================
                // DEPARTMENT
                // ==================================================

                CommonDropdownField(
                  label: "Departments",
                  value: department,
                  items: const [
                    'All Departments Assigned',
                    'HR',
                    'Finance',
                    'IT',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        department = value;
                      });
                    }
                  },
                ),

                // ==================================================
                // OFFICE TITLE
                // ==================================================

                CommonDropdownField(
                  label: "Office Title",
                  value: jobTitle,
                  items: const [
                    'Back Office',
                    'Manager',
                    'Supervisor',
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        jobTitle = value;
                      });
                    }
                  },
                ),

                // ==================================================
                // JOINING DATE
                // ==================================================

                CommonDateField(
                  label: 'Date of Joining',
                  value: _formatDate(joiningDate),
                  onTap: () => _pickDate(true),
                ),

                // ==================================================
                // DATE OF LEAVING
                // ==================================================

                CommonDateField(
                  label: 'Date of Leaving',
                  value: _formatDate(leavingDate),
                  onTap: () => _pickDate(false),
                ),

                // ==================================================
                // EMPLOYEE ID
                // ==================================================

                CommonTextField(
                  label: "Employee ID",
                  controller: employeeIdController,
                ),

                // ==================================================
                // PF ACCOUNT
                // ==================================================

                CommonTextField(
                  label: "PF A/C.",
                  controller: pfController,
                ),

                // ==================================================
                // SAVE BUTTON
                // ==================================================

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    1,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeController.primaryColor.value,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: _saveDetails,
                      child: const Text(
                        'Save Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
