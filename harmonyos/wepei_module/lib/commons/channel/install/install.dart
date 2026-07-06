import 'dart:io';

import 'package:flutter/services.dart';

class InstallManager {
  static const _channel = MethodChannel('com.twt.service/install');
  static bool canGoToMarket = false;

  static void install(String apkName) {
    if (Platform.isIOS) return;
    var argument = {'path': apkName};
    _channel.invokeMethod('install', argument).catchError((_) {});
  }

  static Future<void> goToMarket() async {
    if (Platform.isIOS) return;
    try {
      await _channel.invokeMethod<bool>("goToMarket").catchError((_) {});
    } catch (_) {}
  }

  static Future<void> getCanGoToMarket() async {
    if (Platform.isIOS) {
      canGoToMarket = false;
      return;
    }
    try {
      canGoToMarket =
          await _channel.invokeMethod<bool>("canGoToMarket").catchError((_) => false) ?? false;
    } catch (_) {
      canGoToMarket = false;
    }
  }
}
