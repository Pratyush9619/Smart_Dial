class PlanModel {
  final DateTime planStart;
  final DateTime planExpiry;
  final String name;
  final String status;

  PlanModel({
    required this.planStart,
    required this.planExpiry,
    required this.name,
    required this.status,
  });

  /// FROM JSON
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      planStart: DateTime.parse(json['plan_start'] ?? ''),
      planExpiry: DateTime.parse(json['plan_expiry'] ?? ''),
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }

  /// TO JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'plan_start': planStart.toIso8601String(),
      'plan_expiry': planExpiry.toIso8601String(),
      'name': name,
      'status': status,
    };
  }

  /// ✅ Check if plan is expired
  bool get isExpired => DateTime.now().isAfter(planExpiry);

  /// Days remaining
  int get daysRemaining => planExpiry.difference(DateTime.now()).inDays;
}
