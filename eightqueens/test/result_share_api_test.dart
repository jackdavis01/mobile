import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eightqueens/apinetisolates/resultshareconfigapicontroller.dart';
import 'package:eightqueens/parameters/globaldio.dart' show dioOptions;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Adapter implements HttpClientAdapter {
  final Object response;
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
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test(
      'configuration uses existing authenticated headers and a bodyless, query-free GET',
      () async {
    final adapter = _Adapter({
      'success': true,
      'answer': {'tiktokVideoUrl': 'https://vm.tiktok.com/ZN854AeaU/'},
      'errors': [],
      'info': {},
    });
    final client = Dio(dioOptions)..httpClientAdapter = adapter;
    expect((await ResultShareConfigApi(client: client).fetch()).host,
        'vm.tiktok.com');
    expect(adapter.request!.method, 'GET');
    expect(adapter.request!.uri.path, '/resultShareConfig4e8c2a7b0d1');
    expect(adapter.request!.uri.query, isEmpty);
    expect(adapter.request!.data, isNull);
    expect(adapter.request!.headers['x-api-key'] is String, isTrue);
    expect(adapter.closed, isTrue);
  });

  test(
      'failed, malformed and hostile configuration never becomes a successful URL',
      () async {
    for (final response in [
      {
        'success': false,
        'answer': {},
        'errors': ['missingTikTokVideoUrl'],
        'info': {}
      },
      {
        'success': true,
        'answer': {'tiktokVideoUrl': 'https://evil.example/video'},
        'errors': [],
        'info': {}
      },
      {
        'success': true,
        'answer': {'tiktokVideoUrl': 'https://vm.tiktok.com/video'},
        'errors': ['error'],
        'info': {}
      },
      {
        'success': true,
        'answer': {'tiktokVideoUrl': 123},
        'errors': [],
        'info': {}
      },
    ]) {
      final adapter = _Adapter(response);
      final client = Dio(dioOptions)..httpClientAdapter = adapter;
      await expectLater(ResultShareConfigApi(client: client).fetch(),
          throwsA(isA<ResultShareConfigException>()));
      expect(adapter.closed, isTrue);
    }
  });
}
