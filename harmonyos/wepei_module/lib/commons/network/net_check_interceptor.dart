part of 'wpy_dio.dart';

class NetStatusListener {
  static final NetStatusListener _instance = NetStatusListener._();

  NetStatusListener._();

  factory NetStatusListener() => _instance;

  static Future<void> init() async {}

  bool get hasNetwork => true;
}

class NetCheckInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(options, handler) async {
    return handler.next(options);
  }
}
