import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wepei_module/commons/themes/template/wpy_theme_data.dart';
import 'package:wepei_module/commons/themes/wpy_theme.dart';
import 'package:wepei_module/commons/util/text_util.dart';
import 'package:wepei_module/commons/widgets/SpoilerMask.dart';
import 'package:wepei_module/commons/widgets/loading.dart';

/// 统一Button样式
/// 千万别改!!!!千万别改!!!改了就崩溃
class WpyPic extends StatefulWidget {
  WpyPic(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.withHolder = true,
    this.holderHeight = 40,
    this.withCache = true,
    this.alignment = Alignment.center,
    this.reduce = false,
    this.hide = false,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;
  final double holderHeight;
  final BoxFit fit;
  final bool withHolder;
  final bool withCache;
  final Alignment alignment;
  final bool reduce;

  final bool hide;

  static get errorPlaceHolder => Builder(builder: (context) {
        return ColoredBox(
          color: WpyTheme.of(context).get(WpyColorKey.secondaryBackgroundColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_sharp,
                color: WpyTheme.of(context).get(WpyColorKey.infoTextColor),
              ),
              SizedBox(height: 4),
              Center(
                child: Text('加载失败',
                    style: TextUtil.base.infoText(context).w400.sp(12)),
              ),
            ],
          ),
        );
      });

  static Future<void> clearAllCache() async {
    try {
      final cacheDir = Directory('${Directory.systemTemp.path}/libCachedImageData');
      if (await cacheDir.exists()) {
        await for (final FileSystemEntity entity in cacheDir.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {}
  }

  @override
  _WpyPicState createState() => _WpyPicState();
}

class _WpyPicState extends State<WpyPic> {
  Widget get asset {
    if (widget.imageUrl.endsWith('.svg')) {
      return SvgPicture.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    } else {
      return Image.asset(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
      );
    }
  }

  Widget get network {
    if (widget.imageUrl.endsWith('.svg')) {
      return SvgPicture.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        placeholderBuilder: widget.withHolder ? (_) => Loading() : null,
      );
    } else {
      final imageWidget = Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: widget.withHolder
            ? (context, url, progress) {
                return Container(
                  width: widget.width ?? widget.holderHeight,
                  height: widget.height ?? widget.holderHeight,
                  color: WpyTheme.of(context).get(WpyColorKey.dislikeSecondary),
                  child: Center(
                    child: SizedBox(
                        width: widget.width == null ? 20 : widget.width! * 0.25,
                        height:
                            widget.width == null ? 20 : widget.width! * 0.25,
                        child: CircularProgressIndicator(
                          value: progress?.expectedTotalBytes != null
                              ? progress!.cumulativeBytesLoaded /
                                  progress!.expectedTotalBytes!
                              : null,
                          color: WpyTheme.of(context).primary,
                        )),
                  ),
                );
              }
            : null,
        errorBuilder: widget.withHolder
            ? (context, exception, stacktrace) {
                return WpyPic.errorPlaceHolder;
              }
            : null,
      );

      final imageBuilder = () {
        if (widget.reduce && WpyTheme.of(context).brightness == Brightness.dark)
          return ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
            child: imageWidget,
          );
        return imageWidget;
      };

      // xxx.jpg#tag1,tag2,tag3 or xxx.jpg
      if (!widget.imageUrl.contains('#')) {
        return imageBuilder();
      }

      final tags = widget.imageUrl.split('#')[1].split(',');
      if (tags.contains("masked")) {
        return SizedBox(
            height: widget.height,
            width: widget.width,
            child: SpoilerMaskImage(child: imageBuilder()));
      }
      return imageBuilder();
    }
  }

  Widget get cachedNetwork => SizedBox(
        width: widget.width,
        height: widget.height,
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          placeholder: (context, url) => CupertinoActivityIndicator(),
          errorWidget: (context, url, error) {
            print('v_image error: $error');
            return Icon(Icons.error);
          },
          fit: widget.fit,
        ),
      );

  int? _cachePixelDimension(double? logicalValue) {
    if (logicalValue == null || !logicalValue.isFinite || logicalValue <= 0) {
      return null;
    }
    final mediaQuery = MediaQuery.maybeOf(context);
    final devicePixelRatio = mediaQuery?.devicePixelRatio ??
        // ignore: deprecated_member_use
        WidgetsBinding.instance.window.devicePixelRatio;
    return (logicalValue * devicePixelRatio).round();
  }

  static final Map<String, Uint8List> _ohosImageCache = {};
  Future<Uint8List>? _ohosFuture;

  @override
  void didUpdateWidget(WpyPic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _ohosFuture = null;
    }
  }

  Widget get _ohosNetwork {
    // Immediate render from cache
    final cachedBytes = _ohosImageCache[widget.imageUrl];
    if (cachedBytes != null) {
      return Image.memory(cachedBytes,
        width: widget.width, height: widget.height, fit: widget.fit);
    }

    // Start download once per widget lifecycle
    _ohosFuture ??= _downloadImage(widget.imageUrl);

    return FutureBuilder<Uint8List>(
      future: _ohosFuture!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            _ohosImageCache[widget.imageUrl] = snapshot.data!;
            return Image.memory(snapshot.data!,
              width: widget.width, height: widget.height, fit: widget.fit);
          }
          return WpyPic.errorPlaceHolder;
        }
        return Loading();
      },
    );
  }

  Future<Uint8List> _downloadImage(String url) async {
    final cached = _ohosImageCache[url];
    if (cached != null) return cached;

    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await response.fold<Uint8List>(
      Uint8List(0),
      (prev, chunk) {
        final combined = Uint8List(prev.length + chunk.length);
        combined.setRange(0, prev.length, prev);
        combined.setRange(prev.length, combined.length, chunk);
        return combined;
      },
    );
    client.close();
    _ohosImageCache[url] = bytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.startsWith('assets')) {
      return Container(child: asset);
    }
    // CachedNetworkImage depends on path_provider -> MissingPluginException on OHOS
    if (widget.withCache && (Platform.isAndroid || Platform.isIOS)) {
      return Container(child: cachedNetwork);
    }
    // OHOS: TWT API certificates not trusted by system — use HttpClient with SSL bypass
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Container(child: _ohosNetwork);
    }
    return Container(child: network);
  }
}
