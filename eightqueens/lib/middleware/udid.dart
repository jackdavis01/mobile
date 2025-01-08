import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';

class Udid {
  Future<String> get() async {
    String udid = 'Unknown';
    try {
      udid = await FlutterUdid.udid;
    } on PlatformException {
      udid = 'App: PlatformException';
    }
    return udid;
  }
}
