import 'package:get/get.dart';

class SallarySlipController extends GetxController {
  final salarySlipUrl = ''.obs;

  void loadSalarySlip(String url) {
    salarySlipUrl.value = url;
  }
}
