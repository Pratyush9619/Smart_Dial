import 'incentive_model.dart';

class IncentiveResponse {
  final List<IncentiveUser> data;

  IncentiveResponse({required this.data});

  factory IncentiveResponse.fromJson(Map<String, dynamic> json) {
    return IncentiveResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => IncentiveUser.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
