import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageSave {
  static const _channel = MethodChannel('com.twt.service/saveImg');
  static const _pickerChannel = MethodChannel('com.twt.service/saveImg');

  /// Save image bytes.
  /// If [album] is true, tries to save to system album via MethodChannel,
  /// then falls back to documents/微北洋/.
  static Future<String> saveImageFromBytes(
    Uint8List data,
    String name, {
    bool album = false,
  }) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/$name');
    await tempFile.writeAsBytes(data);

    if (album) {
      // Try system album via MethodChannel
      try {
        final result = await _channel.invokeMethod<Map>('savePictureToAlbum', {
          'path': tempFile.absolute.path,
        }).timeout(const Duration(seconds: 15));
        final saved = result?['saved'] == true;
        final toAlbum = result?['album'] == true;
        if (saved) {
          debugPrint('[ImageSave] save ${toAlbum ? "album" : "filesDir"} success');
          return tempFile.absolute.path;
        }
      } catch (e) {
        debugPrint('[ImageSave] album channel failed: $e');
      }
    }

    // Fallback: save to documents/微北洋/
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final saveDir = Directory('${docDir.path}/微北洋');
      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }
      final file = File('${saveDir.path}/$name');
      await file.writeAsBytes(data);
      debugPrint('[ImageSave] saved to documents: ${file.path}');
      return file.absolute.path;
    } catch (e) {
      debugPrint('[ImageSave] documents save failed: $e');
      return tempFile.absolute.path;
    }
  }

  /// Pick images from gallery via OHOS PhotoViewPicker (harmonyos only).
  /// Returns list of content URIs, or empty list on failure.
  static Future<List<String>> pickImagesFromGallery() async {
    debugPrint('[ImageSave] pickImagesFromGallery called, channel: com.twt.service/saveImg');
    try {
      final result = await _pickerChannel.invokeMethod<List<dynamic>>('pickImages');
      debugPrint('[ImageSave] pickImagesFromGallery result: $result');
      if (result == null) return [];
      return result.cast<String>();
    } catch (e) {
      debugPrint('[ImageSave] pickImages failed: $e');
      return [];
    }
  }

  /// Read clipboard text via OHOS system pasteboard (harmonyos native).
  /// Returns null if clipboard is empty or read fails.
  static Future<String?> getClipboardText() async {
    try {
      final result = await _channel.invokeMethod<String>('getClipboardText');
      return result;
    } catch (e) {
      debugPrint('[ImageSave] getClipboardText failed: $e');
      return null;
    }
  }

  /// Copy text to system clipboard via OHOS native pasteboard (harmonyos only).
  static Future<bool> copyToClipboard(String text) async {
    try {
      final result = await _channel.invokeMethod<bool>('copyToClipboard', text);
      return result ?? false;
    } catch (e) {
      debugPrint('[ImageSave] copyToClipboard failed: $e');
      return false;
    }
  }

  /// Open a URL in the system browser (harmonyos only).
  static Future<bool> openWebView(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>('openWebView', url);
      return result ?? false;
    } catch (e) {
      debugPrint('[ImageSave] openWebView failed: $e');
      return false;
    }
  }

  /// Open system settings for this app (so user can manually grant permissions).
  static Future<bool> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
      return true;
    } catch (e) {
      debugPrint('[ImageSave] openAppSettings failed: $e');
      return false;
    }
  }

  /// Download image from [url] and save.
  static Future<String?> saveImageFromUrl(
    String url,
    String fileName, {
    bool album = false,
  }) async {
    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      final request = await client.getUrl(uri);
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
      return await saveImageFromBytes(bytes, fileName, album: album);
    } catch (e) {
      debugPrint('[ImageSave] saveImageFromUrl failed: $e');
      return null;
    }
  }
}
