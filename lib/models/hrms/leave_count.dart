class LeaveCount {
  final String key;
  final String label;
  final int limit;
  final int used;
  final int remaining;
  final String period;

  LeaveCount({
    required this.key,
    required this.label,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.period,
  });

  factory LeaveCount.fromJson(String key, Map<String, dynamic> json) {
    return LeaveCount(
      key: key,
      label: json['label'] ?? '',
      limit: json['limit'] ?? 0,
      used: json['used'] ?? 0,
      remaining: json['remaining'] ?? 0,
      period: json['period'] ?? '',
    );
  }
}
