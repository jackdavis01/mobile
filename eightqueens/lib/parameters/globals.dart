import 'package:renderer_switcher/renderer_switcher.dart';
import 'package:flutter/foundation.dart' as flutter_foundation show kReleaseMode;

WebRenderer wrGlobalSwitch = WebRenderer.auto;

class GV {
  static const String sTitle = '8 Queens Performance Benchmark';
  static const List<String> lsWebRenderers = ['Auto', 'HTML', 'CanvasKit'];

  static bool bDev = !(flutter_foundation.kReleaseMode);
}
