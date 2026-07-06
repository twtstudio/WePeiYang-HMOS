import 'package:flutter/material.dart';
import 'package:wepei_module/commons/network/wpy_dio.dart';
import 'package:wepei_module/commons/preferences/common_prefs.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/webview/javascript_channels/img_save_channel.dart';
import 'package:wepei_module/commons/webview/wby_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackSummaryPage extends WbyWebView {
  FeedbackSummaryPage({Key? key, required BuildContext context})
      : super(
            page: "年度总结",
            backgroundColor: WpyColorKey.primaryBackgroundColor,
            fullPage: false,
            key: key);

  @override
  _FeedbackSummaryPageState createState() => _FeedbackSummaryPageState();
}

class _FeedbackSummaryPageState extends WbyWebViewState {
  @override
  Future<String> getInitialUrl(BuildContext context) async {
    final baseUrl = "http://summary.twtstudio.com/";
    final response = await _dio.post("user/login",
        formData: FormData.fromMap({
          "username": CommonPreferences.account.value,
          "password": CommonPreferences.password.value,
        }));
    final token = response.data['data']['token'] ?? "null";
    return baseUrl + "?token=$token";
  }

  @override
  List<JavascriptChannel>? getJsChannels() {
    return [ImgSaveChannel("summary")];
  }
}

class SummaryDio extends DioAbstract {
  @override
  String get baseUrl => "https://areas.twt.edu.cn/api/";
}

final _dio = SummaryDio();
