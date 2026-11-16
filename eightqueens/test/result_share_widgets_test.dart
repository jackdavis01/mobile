import 'dart:async';
import 'dart:convert';

import 'package:eightqueens/apinetisolates/apiprofilehandlerisolatecontroller.dart';
import 'package:eightqueens/middleware/appstats.dart';
import 'package:eightqueens/middleware/autoregistration.dart';
import 'package:eightqueens/middleware/listslocalstorage.dart';
import 'package:eightqueens/middleware/localstorage.dart';
import 'package:eightqueens/middleware/resultshare.dart';
import 'package:eightqueens/pages/resultpage.dart';
import 'package:eightqueens/parameters/resultshare.dart';
import 'package:eightqueens/widgets/globalwidgets.dart';
import 'package:eightqueens/widgets/resultsharepanel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Local extends AutoRegLocal {
  final Completer<String>? laterRead;
  int reads = 0;
  _Local({this.laterRead}) : super(refreshCrown: () {});
  @override
  Future<String> getUserName() {
    reads++;
    return reads > 1 && laterRead != null
        ? laterRead!.future
        : Future.value('Blue Tiger');
  }
}

void main() {
  late SharedPreferences preferences;
  late ResultShareConfigStore config;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    SharedPreferences.setMockInitialValues({
      ResultShareConfigStore.cacheKey: jsonEncode({
        'url': resultShareFallbackUri.toString(),
        'fetchedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    });
    preferences = await SharedPreferences.getInstance();
    spGlobal = preferences;
    config = ResultShareConfigStore(storage: preferences);
  });
  tearDown(() {
    config.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> clean(WidgetTester tester, {bool resetPlatform = true}) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
    if (resetPlatform) debugDefaultTargetPlatformOverride = null;
  }

  Widget panel({
    Future<String> Function()? username,
    AppStatsMeasurement? measurement,
    ResultShareActions? actions,
    bool completed = true,
    int threads = 4,
    Duration elapsed = const Duration(milliseconds: 12345),
    VoidCallback? onInteraction,
    double scale = 1,
  }) =>
      MaterialApp(
        theme: ThemeData(useMaterial3: false, primarySwatch: Colors.blue),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
            body: LayoutBuilder(
                builder: (context, constraints) => Column(children: [
                      ResultSharePanel(
                        threads: threads,
                        elapsed: elapsed,
                        completed: completed,
                        availableHeight: constraints.maxHeight,
                        readUsername: username ?? () async => 'Blue Tiger',
                        onInteraction: onInteraction ?? () {},
                        measurement: measurement,
                        config: config,
                        actions: actions,
                      ),
                      Expanded(
                          child: ListView(
                              children: const [SizedBox(height: 2000)])),
                    ]))),
      );

  testWidgets(
      'first registration unlocks actions only after the actual username is available',
      (tester) async {
    var username = 'Me';
    final stats = AppStatsStore(storage: preferences);
    final measurement = stats.completeMeasurement(canSubmit: true);
    await tester.pumpWidget(
        panel(username: () async => username, measurement: measurement));
    await tester.pump();
    expect(find.text('Preparing username...'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    username = 'Blue Tiger';
    await stats.submissionRecorded(measurement);
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    expect(find.textContaining('Blue Tiger'), findsOneWidget);
    await clean(tester);
    stats.dispose();
    measurement.dispose();
  });

  testWidgets(
      'rapid taps produce one native text share with a nonempty button anchor',
      (tester) async {
    final done = Completer<ShareResult>();
    var requests = 0;
    var interactions = 0;
    ShareParams? shared;
    final actions = ResultShareActions(share: (params) {
      requests++;
      shared = params;
      return done.future;
    });
    await tester.pumpWidget(panel(
        actions: actions,
        onInteraction: () {
          interactions++;
        }));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(requests, 1);
    expect(interactions, 1);
    expect(shared!.text, '8 Queens | Blue Tiger | 4 threads | 12.345 s');
    expect(shared!.sharePositionOrigin!.isEmpty, isFalse);
    done.complete(const ShareResult('', ShareResultStatus.dismissed));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
    await clean(tester);
  });

  testWidgets(
      'small portrait and landscape layouts preserve both actions and scrolling space at 2x text',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(panel(scale: 2));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Copy & open\nTikTok'), findsOneWidget);
      expect(find.text('Share\nresult'), findsOneWidget);
      expect(tester.getSize(find.byType(ListView)).height, greaterThan(48));
      expect(tester.getSize(find.byType(FilledButton)).height,
          greaterThanOrEqualTo(48));
      await clean(tester, resetPlatform: false);
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('two-line share buttons match Contribution styling and rank text',
      (tester) async {
    await tester.pumpWidget(panel());
    await tester.pump();
    final copyLabel = find.text('Copy & open\nTikTok');
    final shareLabel = find.text('Share\nresult');
    final preview = find.text('8 Queens | Blue Tiger\n4 threads | 12.345 s');
    for (final label in [copyLabel, shareLabel]) {
      final text = tester.widget<Text>(label);
      expect(text.style!.fontSize, 20);
      expect(text.textAlign, TextAlign.center);
    }
    final previewText = tester.widget<Text>(preview);
    expect(previewText.style!.fontSize, 17);
    expect(previewText.textAlign, TextAlign.center);
    for (final button in [
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)),
      tester.widget<FilledButton>(find.byType(FilledButton)),
    ]) {
      expect(
          button.style!.shape!.resolve({}),
          isA<RoundedRectangleBorder>().having((shape) => shape.borderRadius,
              'Contribution corner radius', BorderRadius.circular(18)));
    }
    final outlined = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(outlined.style!.side!.resolve({})!.width, 2);
    expect(tester.getSize(find.byType(OutlinedButton)).height,
        greaterThanOrEqualTo(tester.getSize(copyLabel).height + 32));
    await clean(tester);
  });

  testWidgets('TikTok border is painted visibly against the actual app panel',
      (tester) async {
    await tester.pumpWidget(panel());
    await tester.pump();
    final material = tester.widget<Material>(find.descendant(
        of: find.byType(OutlinedButton), matching: find.byType(Material)));
    final shape = material.shape;
    if (shape is! RoundedRectangleBorder) {
      fail('The TikTok button must paint a rounded border.');
    }
    final border = shape.side;
    final background = tester
        .widget<RoundedContainer>(find.byType(RoundedContainer))
        .backgroundcolor;
    final borderLuminance =
        Color.alphaBlend(border.color, background).computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final contrast = backgroundLuminance >= borderLuminance
        ? (backgroundLuminance + .05) / (borderLuminance + .05)
        : (borderLuminance + .05) / (backgroundLuminance + .05);
    expect(border.style, BorderStyle.solid);
    expect(border.width, 2);
    expect(contrast, greaterThanOrEqualTo(3),
        reason: 'The border must be visible on the white sharing card.');
    await clean(tester);
  });

  testWidgets(
      'two-line result preview keeps the TikTok clipboard text one line',
      (tester) async {
    String? copied;
    final actions = ResultShareActions(
        copy: (text) async => copied = text, open: (_) async => true);
    await tester.pumpWidget(panel(
      username: () async => 'Radiant Park',
      threads: 2,
      elapsed: const Duration(milliseconds: 4103),
      actions: actions,
    ));
    await tester.pump();
    expect(find.text('8 Queens | Radiant Park\n2 threads | 4.103 s'),
        findsOneWidget);
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();
    expect(copied, '8 Queens | Radiant Park | 2 threads | 4.103 s');
    await clean(tester);
  });

  testWidgets(
      'desktop variants perform no username read or configuration request',
      (tester) async {
    var reads = 0;
    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(panel(username: () async {
        reads++;
        return 'Blue Tiger';
      }));
      await tester.pump();
      expect(find.byType(FilledButton), findsNothing);
      await clean(tester, resetPlatform: false);
    }
    expect(reads, 0);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
      'incomplete results remain disabled and missing names offer a local-only retry',
      (tester) async {
    await tester.pumpWidget(panel(completed: false));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    await clean(tester, resetPlatform: false);
    var name = 'Me';
    var interactions = 0;
    await tester.pumpWidget(
        panel(username: () async => name, onInteraction: () => interactions++));
    await tester.pump();
    expect(find.byTooltip('Retry reading username'), findsOneWidget);
    expect(interactions, 0);
    name = 'Blue Tiger';
    await tester.tap(find.byTooltip('Retry reading username'));
    await tester.pump();
    expect(interactions, 1);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    await clean(tester);
  });

  testWidgets(
      'configuration errors do not claim that an unsaved link was saved',
      (tester) async {
    const error = 'The TikTok link could not be saved on this device.';
    config.errorMessage = error;
    await tester.pumpWidget(panel());
    await tester.pump();
    expect(find.text(error), findsOneWidget);
    expect(find.text('Using saved video'), findsNothing);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    await clean(tester);
  });

  Widget result(AutoRegLocal local) => MaterialApp(
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.blue),
      home: ResultPage(
        speed: 1,
        color: Colors.blue,
        backgroundcolor: Colors.white,
        threads: 4,
        elapsed: const Duration(milliseconds: 12345),
        rankname: 'Fast',
        wCrown: const SizedBox.shrink(),
        dphi: DioProfileHandlerIsolate(),
        arl: local,
        lls: ListsLocalStorage(),
        refreshParent: () async {},
        completed: true,
      ));

  testWidgets(
      'the actual Result page keeps the sharing panel fixed while the result list scrolls',
      (tester) async {
    await tester.pumpWidget(result(_Local()));
    await tester.pump();
    final before = tester.getTopLeft(find.byType(ResultSharePanel));
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(ResultSharePanel)), before);
    expect(tester.takeException(), isNull);
    await clean(tester);
  });

  testWidgets('starting a share suppresses the Result page delayed auto-scroll',
      (tester) async {
    final username = Completer<String>();
    await tester.pumpWidget(result(_Local(laterRead: username)));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump(const Duration(seconds: 6));
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.controller!.offset, 0);
    username.complete('Me');
    await tester.pump();
    await clean(tester);
  });
}
