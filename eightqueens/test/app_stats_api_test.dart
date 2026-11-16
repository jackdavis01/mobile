import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eightqueens/apinetisolates/appstatsapicontroller.dart';
import 'package:eightqueens/parameters/globaldio.dart' show dioOptions;
import 'package:flutter_test/flutter_test.dart';

import 'app_stats_test.dart' show summaryMap;

class _Adapter implements HttpClientAdapter {
  final Map<String, dynamic> response;
  RequestOptions? request;
  bool closed = false;
  _Adapter(this.response);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    request = options;
    return ResponseBody.fromString(jsonEncode(response), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType]
    });
  }

  @override
  void close({bool force = false}) {
    closed = true;
  }
}

void main() {
  test(
      'summary uses the existing authenticated client for a bodyless global GET',
      () async {
    final answer = summaryMap(DateTime.utc(2026, 11, 15));
    final adapter = _Adapter({
      'success': true,
      'answer': answer,
      'errors': <String>[],
      'info': <String, dynamic>{},
    });
    final client = Dio(dioOptions)..httpClientAdapter = adapter;
    final summary = await AppStatsApi(client: client).fetch();
    expect(summary.recordedBenchmarkRuns, 31161);
    expect(adapter.request!.method, 'GET');
    expect(adapter.request!.uri.path, '/appStats6d4f8b2a1c0');
    expect(adapter.request!.uri.query, isEmpty);
    expect(adapter.request!.data, isNull);
    expect(adapter.request!.headers['x-api-key'] is String, isTrue);
    expect(
        (adapter.request!.headers['x-api-key'] as String).isNotEmpty, isTrue);
    expect(adapter.closed, isTrue);
  });

  test('malformed and backend-failure summaries surface as retrieval errors',
      () async {
    for (final answer in [
      {
        'success': false,
        'answer': {},
        'errors': ['appStatsUnavailable'],
        'info': {}
      },
      {
        'success': true,
        'answer': {
          ...summaryMap(DateTime.utc(2026, 11, 15)),
          'deviceModels': -1
        },
        'errors': <String>[],
        'info': <String, dynamic>{},
      }
    ]) {
      final adapter = _Adapter(answer);
      final client = Dio(dioOptions)..httpClientAdapter = adapter;
      await expectLater(AppStatsApi(client: client).fetch(),
          throwsA(isA<AppStatsException>()));
      expect(adapter.closed, isTrue);
    }
  });
}
