
import 'dart:async';
import 'dart:typed_data';

import 'package:desktop_helper/src/model/application_info.dart';
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

  /// Get applications that can open the file, which path is [path].
  static Future<List<ApplicationInfo>> getAppsForFile({required String path}) async {
    List<dynamic>? apps = await _channel.invokeListMethod("getAppsForFile", { "path" : path });
    List<ApplicationInfo> result = [];

    apps?.forEach((app) { 
      final map = app as Map<dynamic, dynamic>;
      String url = map["url"];
      String name = map["name"];
      String bundleId = map["bundleId"];

      List<dynamic> iconData = map["icon"];

      Uint8List icon = Uint8List.fromList(iconData.map((data) => data as int).toList());
      
      ApplicationInfo appInfo = ApplicationInfo(url, name, icon, bundleId);
      result.add(appInfo);
    });

    return result;
  }

  /// Use the app that its url is [appUrl] to open the file which path is [filePath].
  static Future<bool> openFileWithApp({required String filePath, required String appUrl}) async {
    bool isSuccess = await _channel.invokeMethod("openFileWithApp", { "filePath" : filePath, "appUrl" : appUrl });
    return isSuccess;
  }
}