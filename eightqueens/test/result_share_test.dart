import 'dart:async';
import 'dart:convert';

import 'package:eightqueens/apinetisolates/resultshareconfigapicontroller.dart';
import 'package:eightqueens/middleware/resultshare.dart';
import 'package:eightqueens/parameters/resultshare.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime.utc(2026, 11, 15, 12);
  final mainUri = Uri.parse('https://www.tiktok.com/@test/video/123');
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test(
      'short text uses the actual name, singular threads and total milliseconds',
      () {
    expect(
        formatResultShare(
            username: ' Blue\n Tiger ',
            threads: 1,
            elapsed: const Duration(
                minutes: 1, milliseconds: 123, microseconds: 999)),
        '8 Queens | Blue Tiger | 1 thread | 60.123 s');
    expect(
        formatResultShare(
            username: 'Tiger', threads: 4, elapsed: const Duration(hours: 1)),
        '8 Queens | Tiger | 4 threads | 3600.000 s');
    for (final name in ['', ' ', 'Me']) {
      expect(
          () => formatResultShare(
              username: name, threads: 1, elapsed: const Duration(seconds: 1)),
          throwsFormatException);
    }
    expect(
        () => formatResultShare(
            username: 'Tiger', threads: 0, elapsed: Duration.zero),
        throwsFormatException);
  });

  test(
      'TikTok URLs reject hostile hosts, credentials, bad ports and malformed paths',
      () {
    for (final value in [
      'https://vm.tiktok.com.evil.example/video',
      'http://vm.tiktok.com/video',
      'https://user:password@vm.tiktok.com/video',
      'https://vm.tiktok.com:444/video',
      'https://www.tiktok.com/',
      'https:vm.tiktok.com/video',
      'https://vm.tik\ntok.com/video',
      'https://vm.tiktok.com\\video',
    ]) {
      expect(() => parseTikTokVideoUrl(value), throwsFormatException);
    }
    expect(parseTikTokVideoUrl(' https://vm.tiktok.com:443/video/ ').host,
        'vm.tiktok.com');
  });

  test(
      'cache is fresh for 24 hours, stale for seven days, with coalesced background refresh',
      () async {
    await preferences.setString(
        ResultShareConfigStore.cacheKey,
        jsonEncode({
          'url': mainUri.toString(),
          'fetchedAt': now.toIso8601String(),
        }));
    var clock = now.add(const Duration(hours: 23));
    var requests = 0;
    final response = Completer<Uri>();
    final store = ResultShareConfigStore(
        storage: preferences,
        now: () => clock,
        fetch: () {
          requests++;
          return response.future;
        });
    addTearDown(store.dispose);
    await store.refreshIfNeeded();
    expect(requests, 0);
    clock = now.add(const Duration(hours: 24));
    final first = store.refreshIfNeeded();
    expect(store.refreshIfNeeded(), same(first));
    expect(store.selectedUri, mainUri);
    expect(requests, 1);
    response.complete(resultShareFallbackUri);
    await first;
    expect(store.usingFallback, isFalse);
    final reopened =
        ResultShareConfigStore(storage: preferences, now: () => clock);
    addTearDown(reopened.dispose);
    expect(reopened.selectedUri, resultShareFallbackUri);
    expect(reopened.usingFallback, isFalse);
  });

  test('fetch failure retains only a validated cache no older than seven days',
      () async {
    await preferences.setString(
        ResultShareConfigStore.cacheKey,
        jsonEncode({
          'url': mainUri.toString(),
          'fetchedAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        }));
    var clock = now;
    final store = ResultShareConfigStore(
        storage: preferences,
        now: () => clock,
        fetch: () async {
          throw const ResultShareConfigException('Network unavailable.');
        });
    addTearDown(store.dispose);
    await store.refreshIfNeeded();
    expect(store.selectedUri, mainUri);
    expect(store.errorMessage, isNotNull);
    clock = now.add(const Duration(milliseconds: 1));
    expect(store.selectedUri, resultShareFallbackUri);
    expect(store.usingFallback, isTrue);
  });

  test('corrupt and future cache entries cannot replace the bundled fallback',
      () async {
    for (final saved in [
      'invalid JSON',
      jsonEncode({
        'url': 'https://evil.example/video',
        'fetchedAt': now.toIso8601String()
      }),
      jsonEncode({
        'url': mainUri.toString(),
        'fetchedAt': now.add(const Duration(seconds: 1)).toIso8601String()
      }),
    ]) {
      await preferences.setString(ResultShareConfigStore.cacheKey, saved);
      final store =
          ResultShareConfigStore(storage: preferences, now: () => now);
      expect(store.usingFallback, isTrue);
      expect(store.errorMessage, isNotNull);
      store.dispose();
    }
  });

  test('TikTok copies before launching, tries a distinct fallback only once',
      () async {
    final events = <String>[];
    final actions = ResultShareActions(copy: (text) async {
      events.add('copy:$text');
    }, open: (uri) async {
      events.add('open:$uri');
      return uri == resultShareFallbackUri;
    });
    expect(
        await actions.copyAndOpenTikTok('result', mainUri,
            canProceed: () => true),
        isTrue);
    expect(events,
        ['copy:result', 'open:$mainUri', 'open:$resultShareFallbackUri']);
    var launches = 0;
    final failing = ResultShareActions(
        copy: (_) async {},
        open: (_) async {
          launches++;
          return false;
        });
    await expectLater(
        failing.copyAndOpenTikTok('result', resultShareFallbackUri,
            canProceed: () => true),
        throwsA(isA<ResultShareException>()));
    expect(launches, 1);
  });

  test('clipboard failure or leaving the route prevents external launch',
      () async {
    var launches = 0;
    final failed = ResultShareActions(copy: (_) async {
      throw PlatformException(code: 'clipboard-failed');
    }, open: (_) async {
      launches++;
      return true;
    });
    await expectLater(
        failed.copyAndOpenTikTok('result', mainUri, canProceed: () => true),
        throwsA(isA<ResultShareException>()));
    final cancelled = ResultShareActions(
        copy: (_) async {},
        open: (_) async {
          launches++;
          return true;
        });
    expect(
        await cancelled.copyAndOpenTikTok('result', mainUri,
            canProceed: () => false),
        isFalse);
    expect(launches, 0);
  });

  test(
      'native sharing passes text only and the exact iPad origin, without claiming delivery',
      () async {
    ShareParams? params;
    final actions = ResultShareActions(share: (value) async {
      params = value;
      return const ShareResult('', ShareResultStatus.dismissed);
    });
    const origin = Rect.fromLTWH(10, 20, 120, 48);
    await actions.shareText('result', origin);
    expect(params!.text, 'result');
    expect(params!.files, isNull);
    expect(params!.uri, isNull);
    expect(params!.sharePositionOrigin, origin);
  });
}
