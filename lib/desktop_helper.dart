
import 'dart:async';

import 'package:flutter/services.dart';

/// DesktopHelper is a desktop plugin for Flutter, use this plugin can call some useful native APIs on desktop.
class DesktopHelper {
  static const MethodChannel _channel = MethodChannel('com.youngfeng.desktop/desktop_helper');
  
  // ignore: slash_for_doc_comments
  /**
   * Open a file or directory located [path], it'll be return true if opening success.
   * 
   * [isDir] is a redundant parameter to tell plugin whether the current file is a directory.
   * 
   * Return the open state.
   */
  static Future<bool> openFile({
    required String path,
    bool isDir = true
  }) async {
    bool isSuccess = await _channel.invokeMethod("openFile", { "path" : path, "isDir" : isDir });
    return isSuccess;
  }
}
 