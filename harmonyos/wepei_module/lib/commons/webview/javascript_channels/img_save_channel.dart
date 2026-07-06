import 'dart:convert';

import 'package:wepei_module/commons/channel/image_save/image_save.dart';
import 'package:wepei_module/commons/util/logger.dart';
import 'package:wepei_module/commons/util/toast_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ImgSaveChannel implements JavascriptChannel {
  final String page;

  ImgSaveChannel(this.page);

  @override
  String get name => "WbyImgSaveChannel";

  @override
  get onMessageReceived => imgSave;

  Future<void> imgSave(JavascriptMessage message) async {
    try {
      final bytes = base64.decode(message.message.split(",")[1]);
      final fileName = "$page${DateTime.now().millisecondsSinceEpoch}.jpg";
      await ImageSave.saveImageFromBytes(bytes, fileName, album: true);
      ToastProvider.success("保存成功");
    } catch (error, stack) {
      Logger.reportError(error, stack);
      ToastProvider.error('图片保存失败');
    }
  }
}
