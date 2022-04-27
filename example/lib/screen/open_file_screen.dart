import 'dart:developer';

import 'package:desktop_helper/desktop_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class OpenFileScreen extends StatefulWidget {
  const OpenFileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OpenFileState();
  }
}

class _OpenFileState extends State<OpenFileScreen> {
  String? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Open file example"),
      ),
      body: Center(
          child: Column(
        children: [
          Container(
            child: Text("Current file: ${_selectedFile ?? ""}"),
            margin: const EdgeInsets.only(top: 50),
          ),
          Container(
            child: OutlinedButton(
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: false);
                final paths = result?.paths;
                if (paths != null && paths.isNotEmpty) {
                  setState(() {
                    _selectedFile = result?.paths.first;
                  });
                }
              },
              child: const Text("Select file or directory"),
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(const Size(200, 40))),
            ),
            margin: const EdgeInsets.only(top: 20),
          ),
          Visibility(
            child: Container(
              child: OutlinedButton(
                onPressed: () async {
                  bool isSuccess =
                      await DesktopHelper.openFile(path: _selectedFile!);
                  log("Open file result: $isSuccess");
                },
                child: const Text("Open"),
                style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(200, 40))),
              ),
              margin: const EdgeInsets.only(top: 20),
            ),
            visible: _selectedFile != null,
          )
        ],
      )),
    );
  }
}
