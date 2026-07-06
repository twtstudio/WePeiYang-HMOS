import 'dart:io';

import 'package:flutter/services.dart';

class LocalSetting {
  static const _channel = MethodChannel("com.twt.service/local_setting");

  static Future<void> changeBrightness(double brightness) async {
    await _channel
        .invokeMethod("changeWindowBrightness", {'brightness': brightness}).timeout(const Duration(seconds: 2)).catchError((_) {});
    ;
  }

  static Future<void> changeSecurity(bool enable) async {
    if (Platform.isAndroid)
      await _channel.invokeMethod("changeWindowSecure", {'isSecure': enable}).timeout(const Duration(seconds: 2)).catchError((_) {});
    ;
  }

  static Future<String> getBundleVersion() async {
    if (Platform.isAndroid || (!Platform.isAndroid && !Platform.isIOS)) return '';
    return await _channel.invokeMethod<String>('bundleVersion').timeout(const Duration(seconds: 2)).catchError((_) => '') ?? '';
  }
}
