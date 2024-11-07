import 'package:device_info_plus/device_info_plus.dart';

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
