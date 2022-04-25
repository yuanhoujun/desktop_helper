import 'dart:developer';

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
  String? _apps;

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
                await DesktopHelper.openFile(path: "/Users/ouyangfeng/Library/Containers/com.youngfeng.MacAppSample/Data/a.png");
              }, child: const Text("Open file"))
            ],
          ),
        ),
      ),
    );
  }
}
