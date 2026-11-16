import 'dart:convert';

import 'package:eightqueens/apinetisolates/apilistmodelresultsisolatecontroller.dart';
import 'package:eightqueens/apinetisolates/apilistuserresultsisolatecontroller.dart';
import 'package:eightqueens/middleware/listslocalstorage.dart';
import 'package:eightqueens/middleware/localstorage.dart';
import 'package:eightqueens/widgets/modellistswidget.dart';
import 'package:eightqueens/widgets/userlistswidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    spGlobal = await SharedPreferences.getInstance();
    FlutterSecureStorage.setMockInitialValues({});
  });

  for (final userList in [false, true]) {
    testWidgets(
        '${userList ? 'user' : 'model'} periods request the new intervals and retain old caches',
        (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final storage = ListsLocalStorage();
      final requests = <(int, int)>[];
      final dateCache =
          userList ? storage.fssUserResultsDates : storage.fssModelResultsDates;
      final resultCache =
          userList ? storage.lslUserResults : storage.lslModelResults;
      final oldDates = List.generate(
          3, (_) => List.filled(4, DateTime.now().toUtc().toIso8601String()));
      await dateCache.set(storage.serializeURLoadDates(oldDates));

      ModelResultsAnswer modelResult(String name) => ModelResultsAnswer(
          modelName: name,
          runCount: 101,
          bestResult: 1000,
          averageResult: 1500,
          worstResult: 2000);

      List<UserResultsAnswer> userResults(String name) => List.generate(
          4,
          (index) => UserResultsAnswer(
              me: index == 3 ? 1 : 0,
              userName: '$name user $index',
              modelName: name,
              runCount: 101,
              bestResult: 1000,
              averageResult: 1500,
              worstResult: 2000,
              credit: 0));

      if (userList) {
        await resultCache.set(storage.serializeLlluraList(List.generate(
            3, (_) => List.generate(4, (_) => userResults('Legacy')))));
      } else {
        await resultCache.set(storage.serializeLllmraList(List.generate(
            3, (_) => List.generate(4, (_) => [modelResult('Legacy')]))));
      }

      Widget page() {
        if (userList) {
          return UserLists(
              pageTitle: 'User Stat',
              fssLslULLoadDates: dateCache,
              serializeULLoadDates: storage.serializeURLoadDates,
              deserializeULLoadDates: storage.deserializeURLoads,
              lslUser: resultCache,
              serializeLllura: storage.serializeLlluraList,
              deserializeLllura: storage.deserializeLlluList,
              callListUserRetryIsolateApi: (interval, threads) async {
                requests.add((interval, threads));
                return [
                  true,
                  <String, List<UserResultsAnswer>>{
                    'list': userResults('Period $interval thread $threads')
                  }
                ];
              });
        }
        return ModelLists(
            pageTitle: 'Model Stat',
            fssLslMLLoadDates: dateCache,
            serializeMLLoadDates: storage.serializeMRLoadDates,
            deserializeMLLoadDates: storage.deserializeMRLoads,
            lslModel: resultCache,
            serializeLllmra: storage.serializeLllmraList,
            deserializeLllmra: storage.deserializeLllmList,
            callListModelRetryIsolateApi: (interval, threads) async {
              requests.add((interval, threads));
              return [
                true,
                <String, List<ModelResultsAnswer>>{
                  'list': [modelResult('Period $interval thread $threads')]
                }
              ];
            });
      }

      Future<void> selectTab(String label) async {
        final tab = find.text(label).last;
        await tester.ensureVisible(tab);
        await tester.tap(tab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tester.pumpWidget(MaterialApp(home: page()));
      await tester.pumpAndSettle();
      expect(find.text('Legacy'), findsWidgets);
      expect(requests, isEmpty);
      for (final label in [
        'Weekly',
        'Monthly',
        'Quarterly',
        'Yearly',
        '3-yearly'
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      await selectTab('Yearly');
      expect(requests, contains((5, 1)));
      expect(find.text('Period 5 thread 1'), findsWidgets);
      await selectTab('8 Threads');
      expect(requests, contains((5, 8)));
      await selectTab('3-yearly');
      expect(requests, contains((6, 8)));
      expect(find.text('Period 6 thread 8'), findsWidgets);
      await selectTab('2 Threads');
      expect(requests, contains((6, 2)));
      expect(find.text('Period 6 thread 2'), findsWidgets);

      final serialized = await resultCache.get();
      expect(serialized, hasLength(5));
      final decoded = serialized.map((row) => jsonDecode(row) as List).toList();
      String cachedModel(int period, int thread) =>
          jsonDecode(decoded[period][thread][0])['model_name'] as String;
      expect(cachedModel(0, 0), 'Legacy');
      expect(cachedModel(2, 3), 'Legacy');
      expect(cachedModel(3, 0), 'Period 5 thread 1');
      expect(cachedModel(3, 3), 'Period 5 thread 8');
      expect(cachedModel(4, 3), 'Period 6 thread 8');
      expect(cachedModel(4, 1), 'Period 6 thread 2');
      expect(await dateCache.get(), hasLength(5));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(home: page()));
      await tester.pumpAndSettle();
      final requestCount = requests.length;
      await selectTab('Yearly');
      expect(find.text('Period 5 thread 1'), findsWidgets);
      expect(requests, hasLength(requestCount));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(minutes: 5));
    });
  }

  test('clearing list dates resets both new periods for every statistics list',
      () async {
    final storage = ListsLocalStorage();
    storage.clearLocalListDates();
    for (final dates in [
      storage.fssUserResultsDates,
      storage.fssModelResultsDates,
      storage.fssUserRunnersDates,
      storage.fssModelRunnersDates,
      storage.fssUserWorstResultsDates,
      storage.fssModelWorstResultsDates
    ]) {
      final serialized = await dates.get();
      expect(serialized, hasLength(5));
      for (final row in serialized) {
        expect(jsonDecode(row), List.filled(4, '1980-01-01T00:00:00.000Z'));
      }
    }
    expect(await storage.fssUserCrownsDates.get(), hasLength(1));
  });
}
