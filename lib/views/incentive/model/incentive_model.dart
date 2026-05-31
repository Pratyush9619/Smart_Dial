class IncentiveUser {
  final String id;
  final String name;
  final String? profileImage;
  final String teamLeaderId;
  final String financialYear;
  final String month;
  final int totalTarget;
  final int achievement;
  final int currentMonthBacklog;

  IncentiveUser({
    required this.id,
    required this.name,
    this.profileImage,
    required this.teamLeaderId,
    required this.financialYear,
    required this.month,
    required this.totalTarget,
    required this.achievement,
    required this.currentMonthBacklog,
  });

  factory IncentiveUser.fromJson(Map<String, dynamic> json) {
    return IncentiveUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      profileImage: json['profile_image'],
      teamLeaderId: json['teamleader_id'].toString(),
      financialYear: json['financial_year'].toString(),
      month: json['month'].toString(),
      totalTarget: int.tryParse(json['total_target'].toString()) ?? 0,
      achievement: int.tryParse(json['achievement'].toString()) ?? 0,
      currentMonthBacklog:
          int.tryParse(json['current_month_backlog'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'teamleader_id': teamLeaderId,
      'financial_year': financialYear,
      'month': month,
      'total_target': totalTarget,
      'achievement': achievement,
      'current_month_backlog': currentMonthBacklog,
    };
  }

  /// 🔢 Derived values (useful for UI)
  double get achievementPercent =>
      totalTarget == 0 ? 0 : (achievement / totalTarget) * 100;

  bool get isTargetAchieved => achievement >= totalTarget;
}
