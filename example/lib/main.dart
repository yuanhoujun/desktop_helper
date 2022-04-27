import 'package:desktop_helper_example/screen/get_apps_for_file_screen.dart';
import 'package:desktop_helper_example/screen/open_file_screen.dart';
import 'package:desktop_helper_example/screen/open_file_with_app_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: App(),
  ));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Desktop Helper Sample'),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const OpenFileScreen();
                    }));
                  },
                  child: const Text("Open file or directory"),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size(200, 40))),
                ),
                margin: const EdgeInsets.only(top: 50),
                height: 40,
              ),
              Container(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const GetAppsForFileScreen();
                    }));
                  },
                  child: const Text("Get apps for file"),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size(200, 40))),
                ),
                margin: const EdgeInsets.only(top: 30),
                height: 40,
              ),
              Container(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const OpenFileWithAppScreen();
                    }));
                  },
                  child: const Text("Open file with app"),
                  style: ButtonStyle(
                      fixedSize:
                          MaterialStateProperty.all(const Size(200, 40))),
                ),
                margin: const EdgeInsets.only(top: 30),
                height: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
