import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:wepei_module/commons/channel/download/download_manager.dart';
import 'package:wepei_module/commons/util/logger.dart';
import 'package:wepei_module/commons/util/toast_provider.dart';

class WbyFontLoader {
  static void initFonts({bool hint = false}) {
    List<DownloadTask> tasks = [
      DownloadTask(
        url: 'https://upgrade.twt.edu.cn/font/noto',
        type: DownloadType.font,
      ),
      DownloadTask(
        url: 'https://upgrade.twt.edu.cn/font/ping',
        type: DownloadType.font,
      ),
    ];

    if (hint) ToastProvider.running('下载字体文件中...');
    if (Platform.isAndroid) {
      DownloadManager.getInstance().downloads(
        tasks,
        download_running: (fileName, progress) {
          // pass
        },
        download_failed: (_, __, reason) {
          // pass
        },
        download_success: (task) async {
          String? family = task.path.split('/').last.split('-').first;
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(family)) family = null;
          final list = await File(task.path).readAsBytes();
          await loadFontFromList(list, fontFamily: family);
        },
        all_success: (paths) async {
          if (hint) ToastProvider.success('加载字体成功');
        },
        all_complete: (successNum, failedNum) {
          if (hint && failedNum != 0) {
            ToastProvider.error('$successNum种字体加载成功，$failedNum种字体加载失败');
          }
        },
      );
    } else if (Platform.isIOS) {
      List<DownloadTask> taskToDownload = [];

      final dio = Dio();
      tasks.forEach((element) {
        final f = File(element.path);
        if (f.existsSync()) {
          Future.sync(() async {
            final data = await f.readAsBytes();
            await loadFontFromList(data);
          });
          return;
        }
        final dir = Directory(p.dirname(element.path));
        if (!dir.existsSync()) dir.createSync();
        taskToDownload.add(element);
      });
      if (taskToDownload.isEmpty) {
        if (hint) ToastProvider.success('加载字体成功');
        return;
      }
      try {
        Future.sync(() async {
          var res = await Future.wait(taskToDownload.map((e) => dio.get(e.url,
              options: Options(responseType: ResponseType.bytes))));
          for (var i = 0; i < res.length; i++) {
            File(taskToDownload[i].path)..writeAsBytesSync(res[i].data);
            await loadFontFromList(res[i].data);
          }
        });
      } catch (e, s) {
        Logger.reportError(e, s);
      }
    } else {
      // HarmonyOS: load fonts from bundled assets
      if (hint) ToastProvider.running('加载字体文件中...');
      _loadHarmonyOSFonts().then((_) {
        if (hint) ToastProvider.success('加载字体成功');
      }).catchError((e) {
        if (hint) ToastProvider.error('加载字体失败: $e');
      });
    }
  }

  static Future<void> _loadHarmonyOSFonts() async {
    try {
      final notoBytes = (await rootBundle.load('assets/fonts/zh/NotoSansSC-Medium.ttf')).buffer.asUint8List();
      await loadFontFromList(notoBytes, fontFamily: 'NotoSansSC');
    } catch (e) {
      debugPrint('loadFontFromList NotoSansSC failed: $e');
    }
    try {
      final pingBytes = (await rootBundle.load('assets/fonts/zh/PingFangSC-SemiBold.ttf')).buffer.asUint8List();
      await loadFontFromList(pingBytes, fontFamily: 'PingFangSC');
    } catch (e) {
      debugPrint('loadFontFromList PingFangSC failed: $e');
    }
  }
}
