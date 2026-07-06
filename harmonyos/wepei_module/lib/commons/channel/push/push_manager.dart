import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wepei_module/commons/util/toast_provider.dart';

import 'push_intent.dart';
import 'request_push_dialog.dart';

export 'push_intent.dart';

class PushManager extends ChangeNotifier {
  PushManager() {
    _pushChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'refreshPushPermission':
          openPush = false;
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  bool _openPush = Platform.isIOS ? true : false;

  bool get openPush => _openPush;

  set openPush(bool value) {
    _openPush = value;
    notifyListeners();
  }

  static const Tag = 'PushManager_RequestNotification';

  void showRequestNotificationDialog() {
    SmartDialog.show(
      clickMaskDismiss: false,
      backDismiss: false,
      tag: Tag,
      builder: (BuildContext context) {
        return RequestPushDialog();
      },
    );
  }

  void closeDialogAndRetryTurnOnPush() {
    SmartDialog.dismiss(status: SmartStatus.dialog, tag: Tag);
    if (Platform.isIOS) {
      openAppSettings();
      return;
    }
    turnOnPushService(() {
      openPush = true;
    }, () {
      ToastProvider.success("可以在设置中打开推送");
    }, () {
      //
    });
  }

  void closeDialogAndTurnOffPush() {
    SmartDialog.dismiss(status: SmartStatus.dialog, tag: Tag);
    turnOffPushService(() {
      openPush = false;
    }, () {
      //
    });
  }

  // 在用户同意隐私协议后，开启个推
  // TODO: iOS逻辑还可以完善
  Future<void> initGeTuiSdk() async {
    if (Platform.isAndroid) {
      try {
        final result = await _pushChannel.invokeMethod<String>("initGeTuiSdk").timeout(const Duration(seconds: 3)).catchError((_) {});
        switch (result) {
          case 'open push service success':
            openPush = true;
            break;
          case 'refuse open push':
            // 1. 在对话框中选择不打开推送
            // 2. 在推送权限页中不允许通知权限
            // 3. 不允许推送（没有权限或手动关闭）
            openPush = false;
            break;
          case 'showRequestNotificationDialog':
            showRequestNotificationDialog();
            break;
        }
      } on PlatformException catch (e) {
        switch (e.code) {
          case "OPEN_PUSH_SERVICE_ERROR":
            break;
          case "OPEN_NOTIFICATION_CONFIG_PAGE_ERROR":
            break;
          case "CHECK_NOTIFICATION_ENABLE_ERROR":
            break;
          case "INIT_GT_SDK_ERROR":
            break;
          case 'OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR':
            break;
          case 'FATAL_ERROR':
            break;
          default:
            break;
        }
      } catch (e) {
        // TODO
      }
    } else if (Platform.isIOS) {
      try {
        final canPush = await Permission.notification.isGranted;
        if (!canPush) showRequestNotificationDialog();
      } catch (_) {}
    }
  }

  // 在设置里，可以手动打开推送
  Future<void> turnOnPushService(
      Function success, Function failure, Function error) async {
    try {
      final result = await _pushChannel.invokeMethod("turnOnPushService").timeout(const Duration(seconds: 3)).catchError((_) {});
      switch (result) {
        case 'open push service success':
          openPush = true;
          success();
          break;
        case 'refuse open push':
          openPush = false;
          failure();
          break;
      }
    } on PlatformException catch (e) {
      switch (e.code) {
        case "OPEN_PUSH_SERVICE_ERROR":
          break;
        case "OPEN_NOTIFICATION_CONFIG_PAGE_ERROR":
          break;
        case "CHECK_NOTIFICATION_ENABLE_ERROR":
          break;
        case 'OPEN_REQUEST_NOTIFICATION_DIALOG_ERROR':
          break;
        case 'FATAL_ERROR':
          break;
        default:
          break;
      }
      error();
    } catch (e) {
      error();
    }
  }

  Future<void> turnOffPushService(Function success, Function error) async {
    try {
      await _pushChannel.invokeMethod("turnOffPushService").timeout(const Duration(seconds: 3)).catchError((_) {});
      openPush = false;
      success();
    } catch (e) {
      error();
    }
  }

  Future<void> getCurrentCanReceivePush(
      Function(bool) success, Function(Object) error, Function noResult) async {
    try {
      final result =
          await _pushChannel.invokeMethod<bool>("getCurrentCanReceivePush").timeout(const Duration(seconds: 3)).catchError((_) {});
      if (result != null) {
        success(result);
      } else {
        noResult.call();
      }
    } catch (e) {
      error(e);
    }
  }

  Future<String?> getCid() async {
    try {
      return await _pushChannel.invokeMethod<String>("getCid").timeout(const Duration(seconds: 3))
          .timeout(const Duration(seconds: 3)).catchError((_) {});
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelNotification(
      int id, Function success, Function error) async {
    try {
      await _pushChannel.invokeMethod("cancelNotification", {"id", id}).timeout(const Duration(seconds: 3)).catchError((_) {});
      success();
    } catch (e) {
      error();
    }
  }

  Future<void> cancelAllNotification(Function success, Function error) async {
    try {
      await _pushChannel.invokeMethod("cancelAllNotification").timeout(const Duration(seconds: 3)).catchError((_) {});
      success();
    } catch (e) {
      error();
    }
  }

  Future<String?> getIntentUri<T extends PushIntent>(T intent) async {
    try {
      final r = await _pushChannel.invokeMethod<String>(
        "getIntentUri",
        intent.toMap(),
      ).timeout(const Duration(seconds: 3)).catchError((_) {});
      return r;
    } catch (e) {
      return null;
    }
  }
}

const _pushChannel = MethodChannel('com.twt.service/push');
