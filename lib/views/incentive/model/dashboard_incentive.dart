class IncentiveSummary {
  final String totalTarget;
  final String achievement;
  final String currentMonthBacklog;

  IncentiveSummary({
    required this.totalTarget,
    required this.achievement,
    required this.currentMonthBacklog,
  });

  factory IncentiveSummary.fromJson(Map<String, dynamic> json) {
    return IncentiveSummary(
      totalTarget: json['total_target'] ?? 0,
      achievement: json['achievement'] ?? 0,
      currentMonthBacklog: json['current_month_backlog'] ?? 0,
    );
  }
}
