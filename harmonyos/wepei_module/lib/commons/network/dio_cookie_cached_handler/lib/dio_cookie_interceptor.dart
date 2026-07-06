import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

/// 使用 DefaultCookieJar（纯内存 Cookie 存储，无文件 I/O）。
/// 仅在获取办公网课表/GPA/CAS 登录时需要 Cookie。
/// 内存存储足够，重启后重新登录即可。
final CookieJar _globalCookieJar = DefaultCookieJar();

Interceptor cookieCachedHandler() {
  return CookieManager(_globalCookieJar);
}
