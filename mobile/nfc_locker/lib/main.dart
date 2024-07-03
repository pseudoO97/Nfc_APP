import 'package:flutter/material.dart';
import 'views/loading.dart';
import 'views/scan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoadingPage(),
      routes: {
        '/loading': (context) => LoadingPage(),
        '/scan': (context) => ScanPage(),
      },
    );
  }
}
