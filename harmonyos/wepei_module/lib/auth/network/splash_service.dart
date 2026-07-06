import 'package:wepei_module/auth/model/banner_pic.dart';
import 'package:wepei_module/commons/network/cas_service.dart';
import 'package:wepei_module/commons/network/wpy_dio.dart';
import 'package:wepei_module/commons/util/logger.dart';

class SplashDio extends DioAbstract {
  @override
  String baseUrl = 'https://haitang.twt.edu.cn/api/v1/';

  @override
  List<Interceptor> interceptors = [
    InterceptorsWrapper(
      onResponse: (response, handler) {
        var code = response.data['error_code'] ?? 0;
        switch (code) {
          case 0: // 成功
            return handler.next(response);
          default: // 其他错误
            return handler.reject(
                WpyDioException(error: response.data['message']), true);
        }
      },
    )
  ];
}

final splashDio = SplashDio();

class SplashService with AsyncTimer {
  static Future<List<BannerPic>> getBanner() async {
    try {
      var response = await splashDio.get('banner');
      var result = response.data['result'];
      var list = <BannerPic>[];
      result.forEach((e) {
        list.add(BannerPic.fromJson(e));
      });
      return list;
    } catch (e, stack) {
      Logger.reportError(e, stack);
      return [];
    }
  }

  static Future<KeyPair?> getKeyPair() async {
    try {
      var response = await splashDio.get("keypair");
      var result = response.data['result'];
      return KeyPair.fromJson(result);
    } catch (e, stack) {
      Logger.reportError(e, stack);
      return null;
    }
  }
}
