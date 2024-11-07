import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_size/window_size.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'parameters/globals.dart';
import '../parameters/global_device_info.dart';
import 'mainframe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      setWindowTitle(GV.sTitle);
      setWindowMaxSize(const Size(1120, 800));
      setWindowMinSize(const Size(560, 380));
    } else if (Platform.isAndroid) {
      double dAV = await loadAndroidVersion();
      if (10.0 <= dAV) {
        unawaited(MobileAds.instance.initialize());
      }
    }
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainFrame();
  }
}
