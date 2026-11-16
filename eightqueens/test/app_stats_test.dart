import 'dart:async';
import 'dart:convert';

import 'package:eightqueens/apinetisolates/appstatsapicontroller.dart';
import 'package:eightqueens/middleware/appstats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> summaryMap(DateTime time, {int runs = 31161}) => {
      'autoRegisteredUsers': 5059,
      'recordedBenchmarkRuns': runs,
      'deviceModels': 1045,
      'generatedAt': time.toUtc().toIso8601String(),
    };

void main() {
  late SharedPreferences preferences;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    now = DateTime.utc(2026, 11, 15);
  });

  test('summary rejects failed responses, invalid counts and timestamps', () {
    Map<String, dynamic> response() => {
          'success': true,
          'answer': summaryMap(now),
          'errors': <String>[],
          'info': <String, dynamic>{},
        };

    expect(
        AppStatsSummary.fromResponse(response()).recordedBenchmarkRuns, 31161);
    for (final invalid in [null, -1, 1.5, 1.0, true, '100', 9007199254740992]) {
      final input = response();
      (input['answer'] as Map<String, dynamic>)['recordedBenchmarkRuns'] =
          invalid;
      expect(() => AppStatsSummary.fromResponse(input), throwsFormatException);
    }
    for (final timestamp in [
      '',
      'not a date',
      '2026-02-31T00:00:00.000Z',
      '2026-11-15T00:00:00.000',
    ]) {
      final input = response();
      (input['answer'] as Map<String, dynamic>)['generatedAt'] = timestamp;
      expect(() => AppStatsSummary.fromResponse(input), throwsFormatException);
    }
    expect(
        () => AppStatsSummary.fromResponse({...response(), 'success': false}),
        throwsFormatException);
    expect(
        () => AppStatsSummary.fromResponse({
              ...response(),
              'errors': ['appStatsUnavailable']
            }),
        throwsFormatException);
    expect(
        AppStatsSummary.fromMap({...summaryMap(now), 'deviceModels': 0})
            .deviceModels,
        0);
    expect(formatAppStatsCount(1000000), '1 000 000');
  });

  test('five-minute cache survives reopening and expires without deleting data',
      () async {
    var requests = 0;
    Future<AppStatsSummary> fetch() async {
      requests++;
      return AppStatsSummary.fromMap(summaryMap(now));
    }

    final store =
        AppStatsStore(storage: preferences, fetch: fetch, now: () => now);
    await store.refresh();
    final reopened =
        AppStatsStore(storage: preferences, fetch: fetch, now: () => now);
    await reopened.refresh();
    expect(requests, 1);
    now = now.add(const Duration(minutes: 5));
    expect(reopened.expired, isTrue);
    await reopened.refresh();
    expect(requests, 2);
    final previous = reopened.summary;
    reopened.completeMeasurement(canSubmit: false);
    await reopened.flush();
    expect(reopened.summary, same(previous));
    final dirty =
        AppStatsStore(storage: preferences, fetch: fetch, now: () => now);
    expect(dirty.expired, isTrue);
    expect(dirty.summary!.generatedAt, previous!.generatedAt);
    expect(
        dirty.summary!.recordedBenchmarkRuns, previous.recordedBenchmarkRuns);
  });

  test('failed refresh preserves values, timestamp and persistent expiry',
      () async {
    var fail = false;
    final store = AppStatsStore(
        storage: preferences,
        now: () => now,
        fetch: () async {
          if (fail) {
            throw const AppStatsException('Statistics are unavailable.');
          }
          return AppStatsSummary.fromMap(summaryMap(now));
        });
    await store.refresh();
    final previous = store.summary;
    final measurement = store.completeMeasurement(canSubmit: true);
    await store.submissionRecorded(measurement);
    fail = true;
    expect(await store.refresh(), isFalse);
    expect(measurement.status, AppStatsSubmission.recorded);
    expect(measurement.refreshedSummary, isNull);
    expect(store.summary, same(previous));
    expect(store.expired, isTrue);
    expect(store.errorMessage, isNotNull);
    final saved =
        jsonDecode(preferences.getString(AppStatsStore.cacheKey)!) as Map;
    expect(saved['expired'], isTrue);
    fail = false;
    now = now.add(const Duration(seconds: 1));
    expect(await store.refresh(), isTrue);
    expect(measurement.refreshedSummary, same(store.summary));
  });

  test(
      'storage leaves cache expired and ignores stale reads until a requested refresh',
      () async {
    final requests = <Completer<AppStatsSummary>>[];
    final store = AppStatsStore(
        storage: preferences,
        now: () => now,
        fetch: () {
          final request = Completer<AppStatsSummary>();
          requests.add(request);
          return request.future;
        });
    final first = store.refresh();
    requests[0].complete(AppStatsSummary.fromMap(summaryMap(now)));
    await first;
    final oldTimestamp = store.summary!.generatedAt;
    now = now.add(const Duration(minutes: 5));
    final stale = store.refresh();
    final measurement = store.completeMeasurement(canSubmit: true);
    final confirmed = store.submissionRecorded(measurement);
    expect(store.submissionRecorded(measurement), same(confirmed));
    expect(await confirmed, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(requests, hasLength(2));
    requests[1].complete(AppStatsSummary.fromMap(summaryMap(now, runs: 99999)));
    expect(await stale, isFalse);
    await Future<void>.delayed(Duration.zero);
    expect(store.summary!.generatedAt, oldTimestamp);
    expect(store.expired, isTrue);
    expect(requests, hasLength(2));
    final refreshed = store.refresh();
    expect(store.refresh(), same(refreshed));
    expect(requests, hasLength(3));
    requests[2].complete(AppStatsSummary.fromMap(summaryMap(now, runs: 31162)));
    expect(await refreshed, isTrue);
    expect(store.expired, isFalse);
    expect(measurement.baseline!.recordedBenchmarkRuns, 31161);
    expect(measurement.refreshedSummary!.recordedBenchmarkRuns, 31162);
  });

  test(
      'pre-storage reads stay dirty; failed and local-only tests invent no delta',
      () async {
    var runs = 31161;
    var requests = 0;
    final store = AppStatsStore(
        storage: preferences,
        now: () => now,
        fetch: () async {
          requests++;
          return AppStatsSummary.fromMap(summaryMap(now, runs: runs));
        });
    await store.refresh();
    final measurement = store.completeMeasurement(canSubmit: true);
    await store.refresh();
    expect(store.expired, isTrue);
    expect(measurement.refreshedSummary, isNull);
    store.submissionFailed(measurement);
    expect(store.expired, isTrue);
    expect(measurement.refreshedSummary, isNull);
    runs++;
    expect(await store.submissionRecorded(measurement), isTrue);
    expect(store.expired, isTrue);
    expect(requests, 2);
    await store.refresh();
    expect(store.expired, isFalse);
    expect(requests, 3);
    final local = store.completeMeasurement(canSubmit: false);
    await store.flush();
    expect(local.status, AppStatsSubmission.localOnly);
    expect(local.refreshedSummary, isNull);
    expect(store.expired, isTrue);
    expect(requests, 3);
  });

  test('a confirmed submission without a baseline makes no summary request',
      () async {
    var requests = 0;
    final store = AppStatsStore(
        storage: preferences,
        now: () => now,
        fetch: () async {
          requests++;
          return AppStatsSummary.fromMap(summaryMap(now));
        });
    final measurement = store.completeMeasurement(canSubmit: true);
    await store.submissionRecorded(measurement);
    expect(requests, 0);
    expect(store.expired, isTrue);
    expect(measurement.refreshedSummary, isNull);
    await store.refresh();
    expect(measurement.baseline, isNull);
    expect(measurement.refreshedSummary!.recordedBenchmarkRuns, 31161);
  });
}
