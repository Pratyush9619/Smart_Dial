class AttendanceResponse {
  final int status;
  final String message;
  final int count;
  final int totalPresent;
  final int totalLeave;
  final int totalApprovedLeave;
  final int halfDays;
  final int lateMarks;
  final int weekOff;
  final int paidLeave;
  final List<Attendance> data;
  final int code;

  AttendanceResponse({
    required this.status,
    required this.message,
    required this.count,
    required this.totalPresent,
    required this.totalLeave,
    required this.totalApprovedLeave,
    required this.halfDays,
    required this.lateMarks,
    required this.weekOff,
    required this.paidLeave,
    required this.data,
    required this.code,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      totalPresent: json['total_present'] ?? 0,
      totalLeave: json['total_leave'] ?? 0,
      totalApprovedLeave: json['total_approved_leave'] ?? 0,
      halfDays: json['half_days'] ?? 0,
      lateMarks: json['late_marks'] ?? 0,
      weekOff: json['week_off'] ?? 0,
      paidLeave: json['paid_leave'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Attendance.fromJson(e))
          .toList(),
      code: json['code'] ?? 0,
    );
  }
}

class Attendance {
  final String date;
  final String status;
  final String? punchInTime;
  final String? punchOutTime;
  final String? workingHours;

  Attendance({
    required this.date,
    required this.status,
    this.punchInTime,
    this.punchOutTime,
    this.workingHours,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      date: json["date"],
      status: json["status"],
      punchInTime: json["punch_in_time"],
      punchOutTime: json["punch_out_time"],
      workingHours: json["working_hours"],
    );
  }
}
