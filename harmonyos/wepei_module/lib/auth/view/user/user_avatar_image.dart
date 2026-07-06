import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wepei_module/commons/preferences/common_prefs.dart';
import 'package:wepei_module/commons/themes/wpy_theme.dart';

import '../../../commons/themes/template/wpy_theme_data.dart';

Dio _createDio() {
  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));
  final adapter = dio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }
  return dio;
}

class UserAvatarImage extends StatelessWidget {
  final double size;
  final Color iconColor;
  final String tempUrl;

  UserAvatarImage({
    required this.size,
    Color? iconColor,
    this.tempUrl = "",
    required BuildContext context,
  }) : this.iconColor = iconColor ??
            WpyTheme.of(context).get(WpyColorKey.oldThirdActionColor);

  @override
  Widget build(BuildContext context) {
    var avatar = CommonPreferences.avatar.value;
    var avatarBoxUrl =
        tempUrl == '' ? CommonPreferences.avatarBoxMyUrl.value : tempUrl;
    var avatarUrl = avatar.startsWith('http')
        ? avatar
        : 'https://qnhdpic.twt.edu.cn/download/origin/' + avatar;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(500.r)),
            child: _DioImage(
              url: avatar == '' ? '' : avatarUrl,
              width: avatarBoxUrl == "" ? size : 0.54 * size,
              height: avatarBoxUrl == "" ? size : 0.54 * size,
            ),
          ),
          if (avatarBoxUrl != "Error" && avatarBoxUrl.isNotEmpty)
            Builder(
              builder: (context) => _DioBoxImage(
                url: avatarBoxUrl,
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}

class _DioImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  const _DioImage({required this.url, this.width, this.height});
  @override
  State<_DioImage> createState() => _DioImageState();
}

class _DioImageState extends State<_DioImage> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.url.isNotEmpty) _load();
    else _loading = false;
  }

  Future<void> _load() async {
    try {
      final dio = _createDio();
      final response = await dio.get<List<int>>(widget.url,
          options: Options(responseType: ResponseType.bytes));
      if (response.data != null && mounted) {
        _bytes = Uint8List.fromList(response.data!);
        _loading = false;
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return SizedBox(width: widget.width, height: widget.height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (_bytes == null) return SizedBox(width: widget.width, height: widget.height, child: const Center(child: Icon(Icons.person, size: 20, color: Colors.grey)));
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(500)),
        child: Image.memory(_bytes!, width: widget.width, height: widget.height, fit: BoxFit.cover),
      ),
    );
  }
}

class _DioBoxImage extends StatefulWidget {
  final String url;
  final double size;
  const _DioBoxImage({required this.url, required this.size});
  @override
  State<_DioBoxImage> createState() => _DioBoxImageState();
}

class _DioBoxImageState extends State<_DioBoxImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dio = _createDio();
      final response = await dio.get<List<int>>(widget.url,
          options: Options(responseType: ResponseType.bytes));
      if (response.data != null && mounted) {
        _bytes = Uint8List.fromList(response.data!);
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) return const SizedBox.shrink();
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image.memory(_bytes!, width: widget.size, height: widget.size, fit: BoxFit.contain),
    );
  }
}
