import 'dart:convert';

import 'package:get/get.dart';

import '../constants/api_urls.dart';
import '../models/hrms/holiday_model.dart';
import '../services/api_service.dart';

class HolidayController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<HolidayModel> holidays = <HolidayModel>[].obs;

  Future<void> getHolidayList() async {
    try {
      isLoading.value = true;

      final response = await ApiService().postRequest(
        APIUrls.viewHolidayList,
        {
          'year': DateTime.now().year.toString(),
          'month': '',
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        holidays.value = (data['data'] as List)
            .map((e) => HolidayModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Holiday Error $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getHolidayList();
  }

  // Group holiday by month
  Map<String, List<HolidayModel>> get groupedHoliday {
    Map<String, List<HolidayModel>> data = {};

    for (var item in holidays) {
      DateTime date = DateTime.parse(item.date);

      String month = getMonthName(date.month);

      data.putIfAbsent(month, () => []);

      data[month]!.add(item);
    }

    return data;
  }

  String getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return months[month];
  }
}
