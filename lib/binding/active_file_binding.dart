import 'package:get/get.dart';

import '../controllers/active_files_controller.dart';

class ActiveFileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ActiveFilesController>(ActiveFilesController());
  }
}
