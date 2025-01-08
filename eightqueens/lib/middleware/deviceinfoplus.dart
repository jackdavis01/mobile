import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

double dAndroidVersion = -1.0;

Future<AndroidDeviceInfo> loadAndroidDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  return androidInfo;
}

Future<double> loadAndroidVersion() async {
  String sAndroidVersionRelease = (await loadAndroidDeviceInfo()).version.release;
  dAndroidVersion = double.tryParse(sAndroidVersionRelease) ?? 0;
  return dAndroidVersion;
}

Future<String> getDeviceInfoModel() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String _deviceModel = 'unknown';
  if (!kIsWeb) {
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceModel = iosInfo.utsname.machine;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceModel = androidInfo.model;
    }
  }
  return _deviceModel;
}
