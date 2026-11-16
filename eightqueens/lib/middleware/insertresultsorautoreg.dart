import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import '../middleware/deviceinfoplus.dart';
import '../middleware/autoregistration.dart';
import '../apinetisolates/apisendresultsisolatecontroller.dart';
import 'appstats.dart';

class InsertResultsOrAutoRegMiddleware {
  final AutoRegLocal autoRegLocal;
  final AutoRegMiddleware autoRegMiddleware;
  final DioInsertResultsIsolate diri;
  final AppStatsStore? appStats;
  final Map<AppStatsMeasurement, Future<bool>> _uploads = {};

  InsertResultsOrAutoRegMiddleware({
    required this.autoRegLocal,
    required this.autoRegMiddleware,
    DioInsertResultsIsolate? resultApi,
    this.appStats,
  }) : diri = resultApi ?? DioInsertResultsIsolate();

  Future<bool> insertResultOrAutoReg(
      int iBuild, int iThreads, Duration duResult,
      {AppStatsMeasurement? measurement}) async {
    String os = '';
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        os = 'a';
      } else if (Platform.isIOS) {
        os = 'i';
      }
    }
    if (os.isEmpty) return false;
    try {
      final modelCode = await getDeviceInfoModel();
      final udid = await autoRegLocal.oUdid.get();
      return await submitResultForDevice(
          iBuild, iThreads, duResult.inMilliseconds, modelCode, os, udid,
          measurement: measurement);
    } on PlatformException {
      debugPrint('Benchmark upload: device information could not be read.');
      if (measurement != null) {
        (appStats ?? AppStatsStore.instance).submissionFailed(measurement);
      }
      return false;
    }
  }

  Future<bool> submitResultForDevice(int build, int threads, int result,
      String modelCode, String os, String udid,
      {AppStatsMeasurement? measurement}) {
    if (measurement == null) {
      return _submit(build, threads, result, modelCode, os, udid, null);
    }
    if (measurement.status == AppStatsSubmission.recorded) {
      return Future.value(true);
    }
    return _uploads.putIfAbsent(
        measurement,
        () => _submit(build, threads, result, modelCode, os, udid, measurement)
                .whenComplete(() {
              _uploads.remove(measurement);
            }));
  }

  Future<bool> _submit(int build, int threads, int result, String modelCode,
      String os, String udid, AppStatsMeasurement? measurement) async {
    final stats =
        measurement == null ? null : appStats ?? AppStatsStore.instance;
    if (measurement != null) stats!.submissionStarted(measurement);
    bool success = false;
    try {
      if (EAutoReged.reged == autoRegLocal.eAutoReged) {
        final List<dynamic> response =
            await diri.callInsertResultsRetryIsolateApi(
                autoRegLocal.getUserId(),
                modelCode,
                os,
                build,
                udid,
                threads,
                result);
        success = response[0] == true &&
            response[2] is List &&
            (response[2] as List).isEmpty &&
            response[5] == 0;
        if (response[5] == -101) {
          success = await autoRegMiddleware.callAutoReg(
              modelCode, os, build, udid, threads, result, 2);
        }
      } else if (EAutoReged.unreged == autoRegLocal.eAutoReged) {
        success = await autoRegMiddleware.callAutoReg(
            modelCode, os, build, udid, threads, result, 1);
      }
      if (success && measurement != null) {
        await stats!.submissionRecorded(measurement);
      }
      return success;
    } finally {
      if (!success && measurement != null) stats!.submissionFailed(measurement);
    }
  }
}
