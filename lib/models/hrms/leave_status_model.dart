class LeaveStatusModel {
  final int status;
  final int count;
  final String message;
  final List<LeaveData> data;
  final LeaveBalances leaveBalances;

  LeaveStatusModel({
    required this.status,
    required this.count,
    required this.message,
    required this.data,
    required this.leaveBalances,
  });

  factory LeaveStatusModel.fromJson(Map<String, dynamic> json) {
    return LeaveStatusModel(
      status: json['status'] ?? 0,
      count: json['count'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => LeaveData.fromJson(e))
          .toList(),
      leaveBalances: LeaveBalances.fromJson(json['leave_balances'] ?? {}),
    );
  }
}

class LeaveData {
  final String id;
  final String employeeId;
  final String startDate;
  final String endDate;
  final String leaveType;
  final String reason;
  final String status;
  final String? approvedBy;
  final String? actionDate;
  final String? remark;
  final String createdAt;
  final String employeeName;
  final String? approverName;
  final String leaveTypeName;
  final String approveDate;

  LeaveData({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.actionDate,
    this.remark,
    required this.createdAt,
    required this.employeeName,
    this.approverName,
    required this.leaveTypeName,
    required this.approveDate,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      leaveType: json['leave_type'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      approvedBy: json['approved_by']?.toString(),
      actionDate: json['action_date'],
      remark: json['remark'],
      createdAt: json['created_at'] ?? '',
      employeeName: json['employee_name'] ?? '',
      approverName: json['approver_name'],
      leaveTypeName: json['leave_type_name'] ?? '',
      approveDate: json['approve_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "employee_id": employeeId,
      "start_date": startDate,
      "end_date": endDate,
      "leave_type": leaveType,
      "reason": reason,
      "status": status,
      "approved_by": approvedBy,
      "action_date": actionDate,
      "remark": remark,
      "created_at": createdAt,
      "employee_name": employeeName,
      "approver_name": approverName,
      "leave_type_name": leaveTypeName,
      "approve_date": approveDate,
    };
  }
}
// class LeaveData {
//   final String id;
//   final String employeeId;
//   final String startDate;
//   final String endDate;
//   final String leaveTypeName;
//   final String reason;
//   final String status;
//   final String employeeName;
//   final String approverName;

//   LeaveData({
//     required this.id,
//     required this.employeeId,
//     required this.startDate,
//     required this.endDate,
//     required this.leaveTypeName,
//     required this.reason,
//     required this.status,
//     required this.employeeName,
//     required this.approverName,
//   });

//   factory LeaveData.fromJson(Map<String, dynamic> json) {
//     return LeaveData(
//       id: json['id'].toString(),
//       employeeId: json['employee_id'].toString(),
//       startDate: json['start_date'] ?? '',
//       endDate: json['end_date'] ?? '',
//       leaveTypeName: json['leave_type_name'] ?? '',
//       reason: json['reason'] ?? '',
//       status: json['status'] ?? '',
//       employeeName: json['employee_name'] ?? '',
//       approverName: json['approver_name'] ?? '',
//     );
//   }
// }

class LeaveBalances {
  final LeaveBalance sickLeave;
  final LeaveBalance casualLeave;
  final LeaveBalance paidLeave;
  final LeaveBalance unpaidLeave;
  final LeaveBalance halfDay;

  LeaveBalances({
    required this.sickLeave,
    required this.casualLeave,
    required this.paidLeave,
    required this.unpaidLeave,
    required this.halfDay,
  });

  factory LeaveBalances.fromJson(Map<String, dynamic> json) {
    return LeaveBalances(
      sickLeave: LeaveBalance.fromJson(json['sick_leave'] ?? {}),
      casualLeave: LeaveBalance.fromJson(json['casual_leave'] ?? {}),
      paidLeave: LeaveBalance.fromJson(json['paid_leave'] ?? {}),
      unpaidLeave: LeaveBalance.fromJson(json['unpaid_leave'] ?? {}),
      halfDay: LeaveBalance.fromJson(json['half_day'] ?? {}),
    );
  }
}

class LeaveBalance {
  final String label;
  final int limit;
  final int used;
  final int remaining;
  final String period;

  LeaveBalance({
    required this.label,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.period,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      label: json['label'] ?? '',
      limit: json['limit'] ?? 0,
      used: json['used'] ?? 0,
      remaining: json['remaining'] ?? 0,
      period: json['period'] ?? '',
    );
  }
}
