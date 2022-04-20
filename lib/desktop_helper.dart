
import 'dart:async';

import 'package:flutter/services.dart';

class DesktopHelper {
  static const MethodChannel _channel = MethodChannel('desktop_helper');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
