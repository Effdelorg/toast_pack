import 'package:flutter/services.dart';

/// Resolves the native launcher/app icon bytes from platform code.
class AppIconProvider {
  static const MethodChannel _channel =
      MethodChannel('toast_pack/app_icon');

  static Future<Uint8List?> load() async {
    try {
      return await _channel.invokeMethod<Uint8List>('getAppIcon');
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
