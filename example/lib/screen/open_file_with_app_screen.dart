import 'dart:developer';

import 'package:desktop_helper/desktop_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class OpenFileWithAppScreen extends StatefulWidget {
  const OpenFileWithAppScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OpenFileWithAppState();
  }
}

class _OpenFileWithAppState extends State<OpenFileWithAppScreen> {
  String? _selectedFile;
  List<ApplicationInfo> _availableApps = [];
  ApplicationInfo? _selectedApp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open file example"),
      ),
      body: Center(
          child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Text("Current file: ${_selectedFile ?? ""}"),
                margin: const EdgeInsets.only(top: 50),
              ),
              Container(
                child: OutlinedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: false);
                    final paths = result?.paths;
                    if (paths != null && paths.isNotEmpty) {
                      setState(() {
                        _selectedFile = result?.paths.first;
                      });
                    }
                  },
                  child: const Text("Select file or directory"),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size(200, 40))),
                ),
                margin: const EdgeInsets.only(top: 20),
              ),
              Visibility(
                child: Container(
                  child: OutlinedButton(
                    onPressed: () async {
                      final apps = await DesktopHelper.getAppsForFile(
                          path: _selectedFile!);
                      setState(() {
                        _availableApps = apps;
                      });
                    },
                    child: const Text("Get apps for file"),
                    style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all(const Size(200, 40))),
                  ),
                  margin: const EdgeInsets.only(top: 20),
                ),
                visible: _selectedFile != null,
              ),
              Container(
                child: const Text(
                  "Available apps",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                margin: const EdgeInsets.only(top: 30),
              ),
              ...List.generate(_availableApps.length, (index) {
                ApplicationInfo app = _availableApps[index];
                return ListTile(
                  title: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.memory(
                          app.icon,
                          width: 50,
                          height: 50,
                        ),
                        Container(
                          child: Text(
                            app.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          margin: const EdgeInsets.only(left: 8),
                        )
                      ],
                    ),
                    width: 300,
                    margin: const EdgeInsets.only(top: 10),
                  ),
                  leading: Radio<ApplicationInfo>(
                    value: app,
                    groupValue: _selectedApp,
                    onChanged: (value) {
                      setState(() {
                        _selectedApp = app;
                      });
                    },
                  ),
                );
              }),
              Visibility(
                child: Container(
                  child: OutlinedButton(
                    onPressed: () async {
                      bool isSuccess = await DesktopHelper.openFileWithApp(
                          filePath: _selectedFile!, appUrl: _selectedApp!.url);
                      log("openFileWithApp, result: $isSuccess");
                    },
                    child: const Text("Open file with app"),
                    style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all(const Size(200, 40))),
                  ),
                  margin: const EdgeInsets.only(top: 20, bottom: 30),
                ),
                visible: null != _selectedFile && null != _selectedApp,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
