import 'dart:async';

import 'package:eightqueens/apinetisolates/apisendresultsisolatecontroller.dart';
import 'package:eightqueens/apinetisolates/appstatsapicontroller.dart';
import 'package:eightqueens/middleware/appstats.dart';
import 'package:eightqueens/middleware/autoregistration.dart';
import 'package:eightqueens/middleware/insertresultsorautoreg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_stats_test.dart' show summaryMap;

class _InsertApi extends DioInsertResultsIsolate {
  final Future<List<dynamic>> Function() send;
  int calls = 0;
  _InsertApi(this.send);

  @override
  Future<dynamic> callInsertResultsRetryIsolateApi(
      int userId0,
      String modelCode0,
      String os0,
      int build0,
      String udid0,
      int threads0,
      int result0) {
    calls++;
    return send();
  }
}

class _Registration extends AutoRegMiddleware {
  final Future<bool> Function() register;
  final List<int> recoveryModes = [];
  _Registration(AutoRegLocal local, this.register) : super(autoRegLocal: local);

  @override
  Future<bool> callAutoReg(String sModelCode, String os, int build, String udid,
      int iThreads, int iResult, int ls) {
    recoveryModes.add(ls);
    return register();
  }
}

List<dynamic> _storedResponse() => [
      true,
      Answer(userId: '-2', userName: 'Test', credit: 0),
      <String>[],
      {},
      1002,
      0
    ];

void main() {
  late SharedPreferences preferences;
  late AutoRegLocal local;
  final now = DateTime.utc(2026, 11, 15);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    local = AutoRegLocal(refreshCrown: () {});
    local.eAutoReged = EAutoReged.reged;
  });

  test('intermediate recovery success never confirms a failed registration',
      () async {
    var summaryRequests = 0;
    final store = AppStatsStore(
        storage: preferences,
        fetch: () async {
          summaryRequests++;
          return AppStatsSummary.fromMap(summaryMap(now));
        });
    final registration = Completer<bool>();
    final autoReg = _Registration(local, () => registration.future);
    final api = _InsertApi(() async => [
          true,
          null,
          ['unregedUserIdOrUdid'],
          {},
          1002,
          -101
        ]);
    final middleware = InsertResultsOrAutoRegMiddleware(
        autoRegLocal: local,
        autoRegMiddleware: autoReg,
        resultApi: api,
        appStats: store);
    final measurement = store.completeMeasurement(canSubmit: true);
    final upload = middleware.submitResultForDevice(
        3067, 1, 1000, 'test-model', 'a', 'test-device',
        measurement: measurement);
    await Future<void>.delayed(Duration.zero);
    expect(autoReg.recoveryModes, [2]);
    expect(measurement.status, AppStatsSubmission.uploading);
    expect(summaryRequests, 0);
    registration.complete(false);
    expect(await upload, isFalse);
    expect(measurement.status, AppStatsSubmission.failed);
    expect(measurement.refreshedSummary, isNull);
    expect(store.expired, isTrue);
    expect(summaryRequests, 0);
  });

  test(
      'automatic registration waits for final storage without requesting Stats',
      () async {
    local.eAutoReged = EAutoReged.unreged;
    var summaryRequests = 0;
    final store = AppStatsStore(
        storage: preferences,
        fetch: () async {
          summaryRequests++;
          return AppStatsSummary.fromMap(summaryMap(now));
        });
    final registration = Completer<bool>();
    final autoReg = _Registration(local, () => registration.future);
    final api = _InsertApi(() async => _storedResponse());
    final middleware = InsertResultsOrAutoRegMiddleware(
        autoRegLocal: local,
        autoRegMiddleware: autoReg,
        resultApi: api,
        appStats: store);
    final measurement = store.completeMeasurement(canSubmit: true);
    final upload = middleware.submitResultForDevice(
        3067, 4, 1000, 'test-model', 'i', 'test-device',
        measurement: measurement);
    await Future<void>.delayed(Duration.zero);
    expect(summaryRequests, 0);
    expect(api.calls, 0);
    expect(autoReg.recoveryModes, [1]);
    registration.complete(true);
    expect(await upload, isTrue);
    expect(summaryRequests, 0);
    expect(measurement.status, AppStatsSubmission.recorded);
    expect(measurement.baseline, isNull);
    expect(measurement.refreshedSummary, isNull);
    expect(store.expired, isTrue);
  });

  test(
      'failed uploads retry, repeated notifications coalesce, equal times remain distinct',
      () async {
    var succeed = false;
    var summaryRequests = 0;
    final store = AppStatsStore(
        storage: preferences,
        fetch: () async {
          summaryRequests++;
          return AppStatsSummary.fromMap(summaryMap(now));
        });
    final api = _InsertApi(() async => succeed
        ? _storedResponse()
        : [
            false,
            null,
            ['resultLogInsertFailed'],
            {},
            1002,
            0
          ]);
    final middleware = InsertResultsOrAutoRegMiddleware(
        autoRegLocal: local,
        autoRegMiddleware: _Registration(local, () async => false),
        resultApi: api,
        appStats: store);
    final measurement = store.completeMeasurement(canSubmit: true);
    Future<bool> upload(AppStatsMeasurement target) =>
        middleware.submitResultForDevice(
            3067, 1, 1000, 'test-model', 'a', 'test-device',
            measurement: target);
    expect(await upload(measurement), isFalse);
    expect(summaryRequests, 0);
    succeed = true;
    final retried = upload(measurement);
    expect(upload(measurement), same(retried));
    expect(await retried, isTrue);
    expect(await upload(measurement), isTrue);
    expect(api.calls, 2);
    expect(summaryRequests, 0);
    final next = store.completeMeasurement(canSubmit: true);
    expect(await upload(next), isTrue);
    expect(api.calls, 3);
    expect(summaryRequests, 0);
  });

  test('recorded upload never waits for a statistics request', () async {
    final summaryRequest = Completer<AppStatsSummary>();
    var summaryRequests = 0;
    final store = AppStatsStore(
        storage: preferences,
        fetch: () {
          summaryRequests++;
          return summaryRequest.future;
        });
    final middleware = InsertResultsOrAutoRegMiddleware(
        autoRegLocal: local,
        autoRegMiddleware: _Registration(local, () async => false),
        resultApi: _InsertApi(() async => _storedResponse()),
        appStats: store);
    final measurement = store.completeMeasurement(canSubmit: true);
    expect(
        await middleware.submitResultForDevice(
            3067, 1, 1000, 'test-model', 'a', 'test-device',
            measurement: measurement),
        isTrue);
    expect(measurement.status, AppStatsSubmission.recorded);
    expect(summaryRequests, 0);
    expect(measurement.refreshedSummary, isNull);
    expect(store.expired, isTrue);
  });
}
