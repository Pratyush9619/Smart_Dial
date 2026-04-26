import 'plan_model.dart';

class PlanResponse {
  final PlanModel plan;

  PlanResponse({required this.plan});

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    return PlanResponse(
      plan: PlanModel.fromJson(json['data']),
    );
  }
}
