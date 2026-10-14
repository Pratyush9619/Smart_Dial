import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/controllers/theme_controller.dart';
import 'package:smart_solutions/widget/common_form_field.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/text_style.dart';

// class PersonalDetailScreen extends StatefulWidget {
//   const PersonalDetailScreen({super.key});

//   static const Color primaryBlue = Color(0xFF2F6DF6);

//   @override
//   State<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
// }

// class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
//   final ThemeController themeController = Get.find<ThemeController>();
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController staffNameController = TextEditingController();
//   final TextEditingController guardianNameController = TextEditingController();
//   final TextEditingController emergencyNameController = TextEditingController();
//   final TextEditingController emergencyAddressController =
//       TextEditingController();

//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController emergencyMobileController =
//       TextEditingController();

//   String gender = 'Male';
//   String maritalStatus = 'Married';
//   String bloodGroup = 'O+';
//   String emergencyRelation = 'Father';

//   DateTime? dob;

//   String get dobText {
//     if (dob == null) return 'DD/MM/YYYY';
//     return '${dob!.day.toString().padLeft(2, '0')}/'
//         '${dob!.month.toString().padLeft(2, '0')}/'
//         '${dob!.year}';
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: dob ?? DateTime(2000),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) setState(() => dob = picked);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: CommonScaffold(
//         title: "Update Profile",
//         body: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Personal Details',
//                       style: AppTextStyle.textfieldheading,
//                     ),
//                   ),
//                 ),

//                 /// PERSONAL DETAILS
//                 CommonTextField(
//                   label: "Staff Name",
//                   controller: staffNameController,
//                   validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                   focusedBorderColor: themeController.primaryColor.value,
//                 ),

//                 CommonCountryPhoneField(
//                   label: 'Mobile No.',
//                   controller: mobileController,
//                   validator: (v) =>
//                       v == null || v.length != 10 ? 'Enter valid number' : null,
//                 ),

//                 CommonDateField(
//                   label: "Date Of Birth",
//                   value: dobText,
//                   onTap: _pickDate,
//                 ),

//                 CommonDropdownField(
//                   label: "Gender",
//                   value: gender,
//                   items: const ["Male", "Female", "Other"],
//                   onChanged: (v) => setState(() => gender = v!),
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                 ),

//                 CommonDropdownField(
//                   label: "Marital Status",
//                   value: maritalStatus,
//                   items: const ["Single", "Married", "Divorced", "Widowed"],
//                   onChanged: (v) => setState(() => maritalStatus = v!),
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                 ),

//                 CommonDropdownField(
//                   label: "Blood Group",
//                   value: bloodGroup,
//                   items: const ['O+', 'O-', 'A+', 'B+', 'AB+'],
//                   onChanged: (v) => setState(() => bloodGroup = v!),
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                 ),

//                 CommonTextField(
//                   label: "Guardian Name",
//                   controller: guardianNameController,
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                   focusedBorderColor: themeController.primaryColor.value,
//                 ),

//                 const Divider(thickness: 10, color: Color(0xFFE0E0E0)),

//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Emergency Contact Details',
//                       style: AppTextStyle.textfieldheading,
//                     ),
//                   ),
//                 ),

//                 /// EMERGENCY DETAILS
//                 CommonTextField(
//                   label: "Emergency Contact Name",
//                   controller: emergencyNameController,
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                   focusedBorderColor: themeController.primaryColor.value,
//                 ),

//                 CommonDropdownField(
//                   label: "Emergency Relation",
//                   value: emergencyRelation,
//                   items: const [
//                     'Father',
//                     'Mother',
//                     'Brother',
//                     'Sister',
//                     'Spouse'
//                   ],
//                   onChanged: (v) => setState(() => emergencyRelation = v!),
//                   borderColor:
//                       themeController.primaryColor.value.withOpacity(0.4),
//                 ),

//                 CommonCountryPhoneField(
//                   label: 'Emergency Contact Mobile',
//                   controller: emergencyMobileController,
//                 ),

//                 CommonAddressField(
//                   label: 'Emergency Address',
//                   controller: emergencyAddressController,
//                   validator: (v) =>
//                       v == null || v.isEmpty ? 'Address required' : null,
//                 ),

//                 // const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         //  backgroundColor: CurrentEmploymentPage.primaryBlue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                       onPressed: () {},
//                       child: const Text(
//                         'Save Details',
//                         style: TextStyle(
//                           color: Color(0xffFFFFFF),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 /// SAVE BUTTON
//                 // Padding(
//                 //   padding: const EdgeInsets.symmetric(horizontal: 16),
//                 //   child: SizedBox(
//                 //     width: double.infinity,
//                 //     height: 48,
//                 //     child: ElevatedButton(
//                 //       style: ElevatedButton.styleFrom(
//                 //         backgroundColor: PersonalDetailScreen.primaryBlue,
//                 //         shape: RoundedRectangleBorder(
//                 //           borderRadius: BorderRadius.circular(6),
//                 //         ),
//                 //       ),
//                 //       onPressed: () {
//                 //         if (_formKey.currentState!.validate()) {
//                 //           // ✅ submit logic here
//                 //         }
//                 //       },
//                 //       child: const Text(
//                 //         'Save Details',
//                 //         style: TextStyle(
//                 //           color: Colors.white,
//                 //           fontWeight: FontWeight.w600,
//                 //         ),
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_solutions/controllers/theme_controller.dart';

import 'package:smart_solutions/widget/common_form_field.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';

import '../../controllers/hrms/profile_controller.dart';

class PersonalDetailScreen extends StatefulWidget {
  const PersonalDetailScreen({super.key});

  static const Color primaryBlue = Color(0xFF2F6DF6);

  @override
  State<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  final ThemeController themeController = Get.find<ThemeController>();

  final ViewProfileController controller = Get.find<ViewProfileController>();

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController staffNameController = TextEditingController();

  final TextEditingController guardianNameController = TextEditingController();

  final TextEditingController emergencyNameController = TextEditingController();

  final TextEditingController emergencyAddressController =
      TextEditingController();

  final TextEditingController mobileController = TextEditingController();

  final TextEditingController emergencyMobileController =
      TextEditingController();

  // ============================================================
  // DEFAULT VALUES
  // ============================================================

  String gender = 'Male';

  String maritalStatus = 'Married';

  String bloodGroup = 'O+';

  String emergencyRelation = 'Father';

  DateTime? dob;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _fillPersonalDetails();

    // API response aane ke baad UI update
    ever(controller.profile, (_) {
      if (mounted) {
        _fillPersonalDetails();
      }
    });
  }

  // ============================================================
  // GET DATA FROM API
  // ============================================================

  void _fillPersonalDetails() {
    final profile = controller.profile.value;

    if (profile == null) {
      return;
    }

    final personalDetails = profile.personalDetails;

    if (personalDetails == null) {
      return;
    }

    setState(() {
      // ========================================================
      // NAME
      // API:
      // personal_details.name
      // ========================================================

      staffNameController.text = personalDetails.name ?? '';

      // ========================================================
      // MOBILE
      // API:
      // personal_details.mobile
      // ========================================================

      mobileController.text = personalDetails.mobile ?? '';

      // ========================================================
      // DATE OF BIRTH
      // API:
      // personal_details.date_of_birth
      // OR personal_details.dob
      // ========================================================

      final dateOfBirth =
          personalDetails.dateOfBirth ?? personalDetails.dateOfBirth;

      if (dateOfBirth != null &&
          dateOfBirth.trim().isNotEmpty &&
          dateOfBirth != 'null') {
        dob = _parseDate(dateOfBirth);
      } else {
        dob = null;
      }

      // ========================================================
      // GENDER
      // ========================================================

      if (personalDetails.gender != null &&
          personalDetails.gender!.trim().isNotEmpty &&
          personalDetails.gender != 'null') {
        gender = personalDetails.gender!;
      } else {
        gender = 'Male';
      }

      // ========================================================
      // MARITAL STATUS
      // ========================================================

      if (personalDetails.maritalStatus != null &&
          personalDetails.maritalStatus!.trim().isNotEmpty &&
          personalDetails.maritalStatus != 'null') {
        maritalStatus = personalDetails.maritalStatus!;
      } else {
        maritalStatus = 'Married';
      }

      // ========================================================
      // BLOOD GROUP
      // ========================================================

      if (personalDetails.bloodGroup != null &&
          personalDetails.bloodGroup!.trim().isNotEmpty &&
          personalDetails.bloodGroup != 'null') {
        bloodGroup = personalDetails.bloodGroup!;
      } else {
        bloodGroup = 'O+';
      }

      // ========================================================
      // EMERGENCY CONTACT NAME
      // ========================================================

      emergencyNameController.text = personalDetails.emergencyContactName ?? '';

      // ========================================================
      // EMERGENCY CONTACT MOBILE
      // ========================================================

      emergencyMobileController.text =
          personalDetails.emergencyContactMobile ?? '';

      // ========================================================
      // EMERGENCY ADDRESS
      // ========================================================

      emergencyAddressController.text = personalDetails.emergencyAddress ?? '';

      // ========================================================
      // THESE ARE NOT PRESENT IN API
      // ========================================================

      guardianNameController.text = '';

      emergencyRelation = 'Father';
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
      debugPrint('Date parse error: $e');
      return null;
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  // ============================================================
  // DOB TEXT
  // ============================================================

  String get dobText {
    if (dob == null) {
      return 'DD/MM/YYYY';
    }

    return '${dob!.day.toString().padLeft(2, '0')}/'
        '${dob!.month.toString().padLeft(2, '0')}/'
        '${dob!.year}';
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _saveDetails() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    debugPrint('============================');
    debugPrint('PERSONAL DETAILS');
    debugPrint(
      'Name: ${staffNameController.text}',
    );
    debugPrint(
      'Mobile: ${mobileController.text}',
    );
    debugPrint(
      'DOB: $dob',
    );
    debugPrint(
      'Gender: $gender',
    );
    debugPrint(
      'Marital Status: $maritalStatus',
    );
    debugPrint(
      'Blood Group: $bloodGroup',
    );
    debugPrint(
      'Emergency Name: ${emergencyNameController.text}',
    );
    debugPrint(
      'Emergency Mobile: ${emergencyMobileController.text}',
    );
    debugPrint(
      'Emergency Address: ${emergencyAddressController.text}',
    );
    debugPrint('============================');

    // TODO:
    // Call UPDATE PERSONAL DETAILS API here.
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    staffNameController.dispose();
    guardianNameController.dispose();
    emergencyNameController.dispose();
    emergencyAddressController.dispose();
    mobileController.dispose();
    emergencyMobileController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CommonScaffold(
        title: "Update Profile",
        body: Obx(
          () {
            // ==================================================
            // LOADING
            // ==================================================

            if (controller.isLoading.value &&
                controller.profile.value == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ==================================================
                    // PERSONAL DETAILS TITLE
                    // ==================================================

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personal Details',
                          style: AppTextStyle.textfieldheading,
                        ),
                      ),
                    ),

                    // ==================================================
                    // STAFF NAME
                    // API: name
                    // ==================================================

                    CommonTextField(
                      label: "Staff Name",
                      controller: staffNameController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                      focusedBorderColor: themeController.primaryColor.value,
                    ),

                    // ==================================================
                    // MOBILE
                    // API: mobile
                    // ==================================================

                    CommonCountryPhoneField(
                      label: 'Mobile No.',
                      controller: mobileController,
                      validator: (v) => v == null || v.length != 10
                          ? 'Enter valid number'
                          : null,
                    ),

                    // ==================================================
                    // DATE OF BIRTH
                    // API: date_of_birth / dob
                    // ==================================================

                    CommonDateField(
                      label: "Date Of Birth",
                      value: dobText,
                      onTap: _pickDate,
                    ),

                    // ==================================================
                    // GENDER
                    // API: gender
                    // ==================================================

                    CommonDropdownField(
                      label: "Gender",
                      value: gender,
                      items: const [
                        "Male",
                        "Female",
                        "Other",
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            gender = v;
                          });
                        }
                      },
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                    ),

                    // ==================================================
                    // MARITAL STATUS
                    // API: marital_status
                    // ==================================================

                    CommonDropdownField(
                      label: "Marital Status",
                      value: maritalStatus,
                      items: const [
                        "Single",
                        "Married",
                        "Divorced",
                        "Widowed",
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            maritalStatus = v;
                          });
                        }
                      },
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                    ),

                    // ==================================================
                    // BLOOD GROUP
                    // API: blood_group
                    // ==================================================

                    CommonDropdownField(
                      label: "Blood Group",
                      value: bloodGroup,
                      items: const [
                        'O+',
                        'O-',
                        'A+',
                        'A-',
                        'B+',
                        'B-',
                        'AB+',
                        'AB-',
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            bloodGroup = v;
                          });
                        }
                      },
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                    ),

                    // ==================================================
                    // GUARDIAN NAME
                    //
                    // NOT AVAILABLE IN API
                    // Kept because it exists in your UI.
                    // ==================================================

                    CommonTextField(
                      label: "Guardian Name",
                      controller: guardianNameController,
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                      focusedBorderColor: themeController.primaryColor.value,
                    ),

                    // ==================================================
                    // DIVIDER
                    // ==================================================

                    const Divider(
                      thickness: 10,
                      color: Color(0xFFE0E0E0),
                    ),

                    // ==================================================
                    // EMERGENCY TITLE
                    // ==================================================

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Emergency Contact Details',
                          style: AppTextStyle.textfieldheading,
                        ),
                      ),
                    ),

                    // ==================================================
                    // EMERGENCY CONTACT NAME
                    // API:
                    // emergency_contact_name
                    // ==================================================

                    CommonTextField(
                      label: "Emergency Contact Name",
                      controller: emergencyNameController,
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                      focusedBorderColor: themeController.primaryColor.value,
                    ),

                    // ==================================================
                    // EMERGENCY RELATION
                    //
                    // NOT AVAILABLE IN API
                    // ==================================================

                    CommonDropdownField(
                      label: "Emergency Relation",
                      value: emergencyRelation,
                      items: const [
                        'Father',
                        'Mother',
                        'Brother',
                        'Sister',
                        'Spouse',
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            emergencyRelation = v;
                          });
                        }
                      },
                      borderColor:
                          themeController.primaryColor.value.withOpacity(0.4),
                    ),

                    // ==================================================
                    // EMERGENCY MOBILE
                    // API:
                    // emergency_contact_mobile
                    // ==================================================

                    CommonCountryPhoneField(
                      label: 'Emergency Contact Mobile',
                      controller: emergencyMobileController,
                    ),

                    // ==================================================
                    // EMERGENCY ADDRESS
                    // API:
                    // emergency_address
                    // ==================================================

                    CommonAddressField(
                      label: 'Emergency Address',
                      controller: emergencyAddressController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Address required' : null,
                    ),

                    // ==================================================
                    // SAVE BUTTON
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        16,
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
