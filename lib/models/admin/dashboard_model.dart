import 'dart:convert';

DasboardModel dasboardModelFromJson(String str) =>
    DasboardModel.fromJson(json.decode(str));

String dasboardModelToJson(DasboardModel data) => json.encode(data.toJson());

class DasboardModel {
  LoginFileStatus loginFileStatus;
  Login loginRequestFile;
  Login loginFileCount;
  Getcalllogcount getcalllogcount;
  Gettelecallercallback gettelecallercallback;
  TotalIncentive totalIncentive;

  DasboardModel({
    required this.loginFileStatus,
    required this.loginRequestFile,
    required this.loginFileCount,
    required this.getcalllogcount,
    required this.gettelecallercallback,
    required this.totalIncentive,
  });

  factory DasboardModel.fromJson(Map<String, dynamic> json) => DasboardModel(
      loginFileStatus: LoginFileStatus.fromJson(json["login_file_status"]),
      loginRequestFile: Login.fromJson(json["login_request_file"]),
      loginFileCount: Login.fromJson(json["login_file_count"]),
      getcalllogcount: Getcalllogcount.fromJson(json["getcalllogcount"]),
      gettelecallercallback:
          Gettelecallercallback.fromJson(json["gettelecallercallback"]),
      totalIncentive: TotalIncentive.fromJson(json['total_incentive']));

  Map<String, dynamic> toJson() => {
        "login_file_status": loginFileStatus.toJson(),
        "login_request_file": loginRequestFile.toJson(),
        "login_file_count": loginFileCount.toJson(),
        "getcalllogcount": getcalllogcount.toJson(),
        "gettelecallercallback": gettelecallercallback.toJson(),
        "total_incentive": totalIncentive.toJson()
      };
}

class Getcalllogcount {
  String callAttempt;
  String callContacted;
  String callNotcontact;
  String totalCallTime;

  Getcalllogcount({
    required this.callAttempt,
    required this.callContacted,
    required this.callNotcontact,
    required this.totalCallTime,
  });

  factory Getcalllogcount.fromJson(Map<String, dynamic> json) =>
      Getcalllogcount(
        callAttempt: json["call_attempt"],
        callContacted: json["call_contacted"],
        callNotcontact: json["call_notcontact"],
        totalCallTime: json["total_call_time"],
      );

  Map<String, dynamic> toJson() => {
        "call_attempt": callAttempt,
        "call_contacted": callContacted,
        "call_notcontact": callNotcontact,
        "total_call_time": totalCallTime,
      };
}

class Gettelecallercallback {
  String todayCallback;
  String monthlyCallback;

  Gettelecallercallback({
    required this.todayCallback,
    required this.monthlyCallback,
  });

  factory Gettelecallercallback.fromJson(Map<String, dynamic> json) =>
      Gettelecallercallback(
        todayCallback: json["today_callback"],
        monthlyCallback: json["monthly_callback"],
      );

  Map<String, dynamic> toJson() => {
        "today_callback": todayCallback,
        "monthly_callback": monthlyCallback,
      };
}

class TotalIncentive {
  final int totalTarget;
  final int achievement;
  final int currentMonthBacklog;

  TotalIncentive({
    required this.totalTarget,
    required this.achievement,
    required this.currentMonthBacklog,
  });

  factory TotalIncentive.fromJson(Map<String, dynamic> json) {
    return TotalIncentive(
      totalTarget: int.tryParse(json['total_target']?.toString() ?? '0') ?? 0,
      achievement: int.tryParse(json['achievement']?.toString() ?? '0') ?? 0,
      currentMonthBacklog:
          int.tryParse(json['current_month_backlog']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_target': totalTarget,
      'achievement': achievement,
      'current_month_backlog': currentMonthBacklog,
    };
  }
}

class Login {
  dynamic monthlycount;
  dynamic todaycount;

  Login({
    required this.monthlycount,
    required this.todaycount,
  });

  factory Login.fromJson(Map<String, dynamic> json) => Login(
        monthlycount: json["monthlycount"],
        todaycount: json["todaycount"],
      );

  Map<String, dynamic> toJson() => {
        "monthlycount": monthlycount,
        "todaycount": todaycount,
      };
}

class LoginFileStatus {
  String activefilecount;
  String inactivefilecount;
  String activeloanamount;
  String inactiveloanamount;
  String disbursedfilecount;
  String disbursedamount;

  LoginFileStatus({
    required this.activefilecount,
    required this.inactivefilecount,
    required this.activeloanamount,
    required this.inactiveloanamount,
    required this.disbursedfilecount,
    required this.disbursedamount,
  });

  factory LoginFileStatus.fromJson(Map<String, dynamic> json) =>
      LoginFileStatus(
        activefilecount: json["activefilecount"] ?? '0',
        inactivefilecount: json["inactivefilecount"] ?? '0',
        activeloanamount: json["activeloanamount"] ?? '0',
        inactiveloanamount: json["inactiveloanamount"] ?? '0',
        disbursedfilecount: json["disbursedfilecount"] ?? '0',
        disbursedamount: json["disbursedamount"] ?? '0',
      );

  Map<String, dynamic> toJson() => {
        "activefilecount": activefilecount,
        "inactivefilecount": inactivefilecount,
        "activeloanamount": activeloanamount,
        "inactiveloanamount": inactiveloanamount,
        "disbursedfilecount": disbursedfilecount,
        "disbursedamount": disbursedamount,
      };
}
