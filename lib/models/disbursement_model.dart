import 'dart:convert';

DisbursementModel disbursementModelFromJson(String str) =>
    DisbursementModel.fromJson(json.decode(str));

String disbursementModelToJson(DisbursementModel data) =>
    json.encode(data.toJson());

class DisbursementModel {
  List<DisbursementData> data;

  DisbursementModel({
    required this.data,
  });

  factory DisbursementModel.fromJson(Map<String, dynamic> json) =>
      DisbursementModel(
        data: List<DisbursementData>.from(
            json["data"].map((x) => DisbursementData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DisbursementData {
  String id;
  String name;
  String? profileImage;
  String teamleaderId;
  String loginCount;
  String disbursedCount;
  String amount;

  DisbursementData({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.teamleaderId,
    required this.loginCount,
    required this.disbursedCount,
    required this.amount,
  });

  factory DisbursementData.fromJson(Map<String, dynamic> json) =>
      DisbursementData(
        id: json["id"],
        name: json["name"],
        profileImage: json["profile_image"]?.toString() ?? '',
        teamleaderId: json['teamleader_id']?.toString() ?? '',
        loginCount: json["login_count"],
        disbursedCount: json["disbursed_count"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profileImage": profileImage,
        "teamleader_id": teamleaderId,
        "login_count": loginCount,
        "disbursed_count": disbursedCount,
        "amount": amount,
      };
}

class disbursementTotals {
  int loginCountTotal;
  int disbursedCountTotal;
  String amountTotal;

  disbursementTotals({
    required this.loginCountTotal,
    required this.disbursedCountTotal,
    required this.amountTotal,
  });

  factory disbursementTotals.fromJson(Map<String, dynamic> json) =>
      disbursementTotals(
        loginCountTotal: json["login_count_total"],
        disbursedCountTotal: json["disbursed_count_total"],
        amountTotal: json["amount_total"],
      );

  Map<String, dynamic> toJson() => {
        "login_count_total": loginCountTotal,
        "disbursed_count_total": disbursedCountTotal,
        "amount_total": amountTotal,
      };
}
