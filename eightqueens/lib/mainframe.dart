import 'dart:ui';
//import 'package:eightqueens/widgets/iframeview.dart';
import 'package:flutter/foundation.dart' as flutter_foundation;
import 'package:flutter/material.dart';
import '../parameters/globals.dart';
import '../widgets/webwidgets.dart';
import 'pages/homepage.dart';

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  @override
  Widget build(BuildContext context) {
    if (flutter_foundation.kReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
    return MaterialApp(
        //debugShowCheckedModeBanner: false,
        scrollBehavior: DragPointerDeviceScrollBehavior(),
        title: '8 Queens',
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blue,
        ),
        home: (flutter_foundation.kIsWeb)
            ? const WebPageWidget()
            : const HomePage(title: GV.sTitle, headerSize: 0));
  }
}

class DragPointerDeviceScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
