import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'global.dart';
import 'page/home.dart';
import 'page/settings.dart';

enum InitFlag { wait, ok, error }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StackTrace? _stackTrace;
  dynamic _error;

  InitFlag initFlag = InitFlag.wait;

  @override
  void initState() {
    super.initState();
    () async {
      try {
        await Global.init();
        initFlag = InitFlag.ok;
        setState(() {}); //刷新布局 initFlag 改变
      } catch (e, st) {
        _error = e;
        _stackTrace = st;
        initFlag = InitFlag.error;
        setState(() {});
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    switch (initFlag) {
      case InitFlag.ok:
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Audio Player',
            routes: {
              '/settings': (context) => const Settings(),
              '/home': (context) => const Home(),
            },
            home: const Scaffold(body: Home()));
      case InitFlag.error:
        return MaterialApp(
          darkTheme: ThemeData.dark(),
          home: ErrorApp(error: _error, stackTrace: _stackTrace),
        );
      default:
        return const MaterialApp(
          home: FirstPage(),
        );
    }
  }
}

class ErrorApp extends StatelessWidget {
  final error;
  final stackTrace;
  const ErrorApp({Key? key, this.error, this.stackTrace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            Text(
              "$error\n$stackTrace",
              style: const TextStyle(color: Color(0xFFF56C6C)),
            )
          ],
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: const [
            Text(
              "加载中...",
              style: TextStyle(color: Color(0xFFF56C6C)),
            )
          ],
        ),
      ),
    );
  }
}
