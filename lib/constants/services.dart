import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

void logOutput(String message) {
  log(message);
}

class Services {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // ANDROID ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    }
    return '';
  }
}
