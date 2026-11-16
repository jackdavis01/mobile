import 'dart:async';
import 'package:flutter/foundation.dart';

import '../parameters/globaldio.dart'
    if (dart.library.html) '../parameters/noglobaldio.dart';
import '../parameters/net.dart'
    if (dart.library.html) '../parameters/nonet.dart';
import '../parameters/resultshare.dart';

class ResultShareConfigException implements Exception {
  final String message;
  const ResultShareConfigException(this.message);
}

class ResultShareConfigApi {
  final DioHttp? client;
  ResultShareConfigApi({this.client});

  Future<Uri> fetch() async {
    if (!resultSharingSupported) {
      throw const ResultShareConfigException(
          'Result sharing is available only in the mobile app.');
    }
    final dio = client ?? DioHttp(dioOptions);
    try {
      final response = await dio
          .getUri(GNet.uriInsertResults
              .replace(path: '/resultShareConfig4e8c2a7b0d1'))
          .timeout(const Duration(seconds: 5));
      final data = response.data;
      if (response.statusCode != 200 ||
          data is! Map<String, dynamic> ||
          data['success'] != true ||
          data['errors'] is! List ||
          (data['errors'] as List).isNotEmpty ||
          data['info'] is! Map ||
          data['answer'] is! Map<String, dynamic>) {
        throw const FormatException('Unsuccessful sharing configuration');
      }
      final value = (data['answer'] as Map<String, dynamic>)['tiktokVideoUrl'];
      if (value is! String) {
        throw const FormatException('Missing TikTok video URL');
      }
      return parseTikTokVideoUrl(value);
    } on FormatException {
      debugPrint('Result sharing: invalid backend configuration.');
      throw const ResultShareConfigException(
          'The TikTok link could not be retrieved.');
    } on DioException catch (error) {
      debugPrint(
          'Result sharing: configuration request failed (${error.type}).');
      throw const ResultShareConfigException(
          'The TikTok link could not be retrieved.');
    } on TimeoutException {
      debugPrint('Result sharing: configuration request timed out.');
      throw const ResultShareConfigException(
          'The TikTok link request timed out.');
    } finally {
      dio.close(force: true);
    }
  }
}
