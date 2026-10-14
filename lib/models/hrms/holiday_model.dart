class HolidayModel {
  final String id;
  final String title;
  final String date;
  final String created;

  HolidayModel({
    required this.id,
    required this.title,
    required this.date,
    required this.created,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'] ?? '',
      title: json['h_title'] ?? '',
      date: json['h_date'] ?? '',
      created: json['created'] ?? '',
    );
  }
}
