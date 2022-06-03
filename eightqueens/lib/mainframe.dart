import 'dart:ui';
import 'package:flutter/material.dart';
import 'pages/homepage.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      scrollBehavior: DragPointerDeviceScrollBehavior(),
      title: '8 Queens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: GC.sTitle),
    );
  }
}

class GC {
  static const String sTitle = '8 Queens Performance Benchmark';
}

class DragPointerDeviceScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => { 
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
