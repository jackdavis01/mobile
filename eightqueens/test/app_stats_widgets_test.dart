import 'dart:async';

import 'package:eightqueens/apinetisolates/appstatsapicontroller.dart';
import 'package:eightqueens/middleware/appstats.dart';
import 'package:eightqueens/middleware/autoregistration.dart';
import 'package:eightqueens/middleware/deviceinfoplus.dart'
    show dAndroidVersion;
import 'package:eightqueens/middleware/listslocalstorage.dart';
import 'package:eightqueens/middleware/localstorage.dart';
import 'package:eightqueens/apinetisolates/apiprofilehandlerisolatecontroller.dart';
import 'package:eightqueens/pages/appstatspage.dart';
import 'package:eightqueens/pages/infopage.dart' show DataPackageInfo;
import 'package:eightqueens/widgets/featurediscovery.dart';
import 'package:eightqueens/widgets/homenavdrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_stats_test.dart' show summaryMap;

void main() {
  late SharedPreferences preferences;
  final now = DateTime.utc(2026, 11, 15);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    spGlobal = preferences;
    FlutterSecureStorage.setMockInitialValues({});
  });

  for (final platform in TargetPlatform.values) {
    testWidgets('App Stats drawer entry is mobile-only on ${platform.name}',
        (tester) async {
      final previousAndroidVersion = dAndroidVersion;
      dAndroidVersion = 10;
      addTearDown(() => dAndroidVersion = previousAndroidVersion);
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
        return PrimaryScrollController(
          controller: scrollController,
          automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
          child: HomeNavDrawer(
            wCrown: const Icon(Icons.star),
            dphi: DioProfileHandlerIsolate(),
            arl: AutoRegLocal(refreshCrown: () {}),
            lls: ListsLocalStorage(),
            getDpi: () => DataPackageInfo(
                appName: 'Test',
                packageName: 'test',
                version: 'test',
                buildNumber: '3067',
                buildMode: 'test'),
            hfd: HomeFeatureDiscovery(
                context: context, lskFeatureIds: [], getMounted: () => true),
            refreshParent: () async {},
          ),
        );
      })));
      await tester.pumpAndSettle();
      final mobile =
          platform == TargetPlatform.android || platform == TargetPlatform.iOS;
      expect(find.text('Top Performers'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Settings'), 200,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('App Stats'), mobile ? findsOneWidget : findsNothing);
      if (mobile) {
        expect(tester.getTopLeft(find.text('Collect')).dy,
            lessThan(tester.getTopLeft(find.text('App Stats')).dy));
        expect(tester.getTopLeft(find.text('App Stats')).dy,
            lessThan(tester.getTopLeft(find.text('Settings')).dy));
        expect(
            tester
                .widget<ListTile>(find.widgetWithText(ListTile, 'App Stats'))
                .minLeadingWidth,
            0);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }, variant: TargetPlatformVariant({platform}));
  }

  testWidgets(
      'narrow large-text screen has exact totals, definitions and no tabs',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final request = Completer<AppStatsSummary>();
    final store = AppStatsStore(
        storage: preferences, now: () => now, fetch: () => request.future);
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!),
        home: AppStatsPage(store: store)));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('0'), findsNothing);
    request.complete(AppStatsSummary.fromMap(summaryMap(now)));
    await tester.pumpAndSettle();
    expect(find.text('Recorded benchmark runs'), findsOneWidget);
    expect(find.text('Auto-registered users'), findsOneWidget);
    expect(find.text('Device models'), findsOneWidget);
    expect(find.text('31 161'), findsOneWidget);
    expect(find.text('5 059'), findsOneWidget);
    expect(find.text('1 045'), findsOneWidget);
    expect(find.text('All platforms'), findsOneWidget);
    expect(find.text('Weekly'), findsNothing);
    await tester.scrollUntilVisible(find.text('About these numbers'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('About these numbers'));
    await tester.pumpAndSettle();
    expect(find.textContaining('not distinct people'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('first failure retries; refresh failure keeps saved totals',
      (tester) async {
    var fail = true;
    final store = AppStatsStore(
        storage: preferences,
        now: () => now,
        fetch: () async {
          if (fail) {
            throw const AppStatsException('Statistics are unavailable.');
          }
          return AppStatsSummary.fromMap(summaryMap(now));
        });
    await tester.pumpWidget(MaterialApp(home: AppStatsPage(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('Statistics are unavailable right now.'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('31 161'), findsOneWidget);
    final timestamp = store.summary!.generatedAt;
    fail = true;
    store.completeMeasurement(canSubmit: false);
    await tester.pump();
    await tester.tap(find.byTooltip('Refresh statistics'));
    await tester.pumpAndSettle();
    expect(find.text('31 161'), findsOneWidget);
    expect(store.summary!.generatedAt, timestamp);
    expect(find.text('Could not refresh. Showing saved statistics.'),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'opening App Stats refreshes after upload with no text below the run total',
      (tester) async {
    var runs = 31161;
    final store = AppStatsStore(
        storage: preferences,
        now: () => now,
        fetch: () async =>
            AppStatsSummary.fromMap(summaryMap(now, runs: runs)));
    await store.refresh();
    final measurement = store.completeMeasurement(canSubmit: true);
    runs = 31162;
    await store.submissionRecorded(measurement);
    expect(store.summary!.recordedBenchmarkRuns, 31161);
    expect(store.expired, isTrue);
    await tester.pumpWidget(MaterialApp(home: AppStatsPage(store: store)));
    await tester.pumpAndSettle();
    expect(find.text('Auto-registered users'), findsOneWidget);
    expect(find.text('31 162'), findsOneWidget);
    final runsCard = find.ancestor(
        of: find.text('Recorded benchmark runs'), matching: find.byType(Card));
    expect(
        tester
            .widgetList<Text>(
                find.descendant(of: runsCard, matching: find.byType(Text)))
            .map((text) => text.data),
        ['Recorded benchmark runs', '31 162']);
    expect(find.textContaining('5 059 ->'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
