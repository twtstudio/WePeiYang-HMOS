import 'dart:io';

import 'package:flutter/services.dart';

class HotFixManager {
  static const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

  static Future<void> hotFix(String path) async {
    if (Platform.isIOS) return;
    try {
      await _hotfixChannel
          .invokeMethod("hotFix", {"path": path})
          .catchError((_) {});
    } catch (_) {}
  }

  static Future<void> restartApp() async {
    if (Platform.isIOS) return;
    try {
      await _hotfixChannel.invokeMethod("restartApp").catchError((_) {});
    } catch (_) {}
  }

  static Future<bool> soFileCanUse(String soName) async {
    if (Platform.isIOS) return false;
    try {
      final r = await _hotfixChannel
          .invokeMethod('soFileCanUse', {'soName': soName})
          .catchError((_) => false);
      return r == true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> readChannel({required String key}) async {
    if (Platform.isIOS) return null;
    try {
      final r = await _hotfixChannel
          .invokeMethod("readChannel", {"key": key})
          .catchError((_) => null);
      return r as String?;
    } catch (_) {
      return null;
    }
  }
}
