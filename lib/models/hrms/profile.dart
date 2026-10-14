class ProfileModel {
  final String? id;
  final String? name;
  final String? username;
  final String? profileImage;
  final String? roleName;
  final String? mobile;

  final PersonalDetails? personalDetails;
  final CurrentEmployment? currentEmployment;
  final BankDetails? bankDetails;

  ProfileModel({
    this.id,
    this.name,
    this.username,
    this.profileImage,
    this.roleName,
    this.mobile,
    this.personalDetails,
    this.currentEmployment,
    this.bankDetails,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      username: json['username']?.toString(),
      profileImage: json['profile_image']?.toString(),
      roleName: json['role_name']?.toString(),
      mobile: json['mobile']?.toString(),
      personalDetails: json['personal_details'] != null
          ? PersonalDetails.fromJson(json['personal_details'])
          : null,
      currentEmployment: json['current_employment'] != null
          ? CurrentEmployment.fromJson(json['current_employment'])
          : null,
      bankDetails: json['bank_details'] != null
          ? BankDetails.fromJson(json['bank_details'])
          : null,
    );
  }
}

class PersonalDetails {
  final String? id;
  final String? name;
  final String? roleName;
  final String? username;
  final String? mobile;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? bloodGroup;
  final String? emergencyContactName;
  final String? emergencyContactMobile;
  final String? emergencyAddress;

  PersonalDetails({
    this.id,
    this.name,
    this.roleName,
    this.username,
    this.mobile,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.bloodGroup,
    this.emergencyContactName,
    this.emergencyContactMobile,
    this.emergencyAddress,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      roleName: json['role_name']?.toString(),
      username: json['username']?.toString(),
      mobile: json['mobile']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString() ?? json['dob']?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactMobile: json['emergency_contact_mobile']?.toString(),
      emergencyAddress: json['emergency_address']?.toString(),
    );
  }
}

class CurrentEmployment {
  final String? branch;
  final String? department;
  final String? officeTitle;
  final String? employeeId;
  final String? joiningDate;
  final String? dateOfLeaving;
  final String? pfAccountNo;

  CurrentEmployment({
    this.branch,
    this.department,
    this.officeTitle,
    this.employeeId,
    this.joiningDate,
    this.dateOfLeaving,
    this.pfAccountNo,
  });

  factory CurrentEmployment.fromJson(Map<String, dynamic> json) {
    return CurrentEmployment(
      branch: json['branch']?.toString(),
      department: json['department']?.toString(),
      officeTitle: json['office_title']?.toString(),
      employeeId: json['employee_id']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      dateOfLeaving: json['date_of_leaving']?.toString(),
      pfAccountNo: json['pf_account_no']?.toString(),
    );
  }
}

class BankDetails {
  final String? bankHolderName;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;

  BankDetails({
    this.bankHolderName,
    this.accountNumber,
    this.bankName,
    this.ifscCode,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankHolderName: json['bank_holder_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
    );
  }
}
