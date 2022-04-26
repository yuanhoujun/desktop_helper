import 'dart:developer';
import 'dart:typed_data';

import 'package:desktop_helper/desktop_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ApplicationInfo> _apps = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              OutlinedButton(onPressed: () async {
                await DesktopHelper.openFile(path: "/Users/ouyangfeng/Library/Containers/com.youngfeng.plugin.desktopHelperExample/Data");
              }, child: const Text("Open file")),

              OutlinedButton(onPressed: () async {
                final apps = await DesktopHelper.getAppsForFile(path: "/Users/ouyangfeng/Downloads/a.mp4");
                log("apps: $apps");
                setState(() {
                  if (apps.isNotEmpty) {
                    _apps = apps;
                  }
                });
              }, child: const Text("Get available apps")),

              OutlinedButton(onPressed: () async {
                bool result = await DesktopHelper.openFileWithApp(filePath: "/Users/ouyangfeng/Library/Containers/com.youngfeng.plugin.desktopHelperExample/Data/a.jpg",
                                                    appUrl: "/System/Applications/Preview.app/");
                                                    
                                log("result: $result");
              }, child: const Text("Open file with app")),

              Column(
                children: List.generate(_apps.length, (index) {
                  final app = _apps[index];

                  return Row(
                    children: [
                      Image.memory(Uint8List.fromList(app.icon)),

                      Container(
                        child: Text(
                          app.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                          ),
                          ),
                        margin: const EdgeInsets.only(
                          left: 10,
                          right: 10
                        ),
                      ),

                      Text("${app.bundleId}")
                    ],
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
