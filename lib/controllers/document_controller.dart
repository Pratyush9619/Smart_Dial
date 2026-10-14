import 'dart:convert';

import 'package:get/get.dart';
import '../constants/api_urls.dart';
import '../constants/static_stored_data.dart';
import '../models/hrms/document_model.dart';
import '../services/api_service.dart';

class DocumentsController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<DocumentModel> documents = <DocumentModel>[].obs;

  Future<void> getDocuments() async {
    String currentMonth =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";
    try {
      isLoading.value = true;

      final response = await ApiService().postRequest(APIUrls.viewDocuments, {
        'user_id': StaticStoredData.userId,
        //StaticStoredData.userId,
        'search': '',
        'month': currentMonth,
      });

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        documents.value = (data['data'] as List)
            .map((e) => DocumentModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print("Document Error : $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getDocuments();
  }
}
