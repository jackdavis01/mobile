import 'package:flutter/foundation.dart' as flutter_foundation show kReleaseMode;

// ignore: // unused_element // remove the second "//"
const bool _bReleaseMode = flutter_foundation.kReleaseMode;

// ignore: dead_code
// const bool bReleaseMode = false; // test code for release mode debug, to be commented out

// test code for no debugPrint in debug mode, the "; || true;" to be commented out
const bool bReleaseMode = _bReleaseMode; // || true;

class GV {
  static const String sTitle = '8 Queens Performance Benchmark';
  static const List<String> lsWebRenderers = ['Auto', 'HTML', 'CanvasKit'];

  static bool bDev = !(flutter_foundation.kReleaseMode);
  static bool bFirstCrownCollectionMessage = true;
  static bool bFirstIntervalCrownCollectionMessage = true;
}
