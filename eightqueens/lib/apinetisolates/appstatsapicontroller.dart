import 'package:flutter/foundation.dart';

import '../parameters/globaldio.dart'
    if (dart.library.html) '../parameters/noglobaldio.dart';
import '../parameters/net.dart'
    if (dart.library.html) '../parameters/nonet.dart';

class AppStatsSummary {
  final int autoRegisteredUsers;
  final int recordedBenchmarkRuns;
  final int deviceModels;
  final DateTime generatedAt;

  const AppStatsSummary({
    required this.autoRegisteredUsers,
    required this.recordedBenchmarkRuns,
    required this.deviceModels,
    required this.generatedAt,
  });

  factory AppStatsSummary.fromResponse(Object? response) {
    if (response is! Map<String, dynamic> ||
        response['success'] != true ||
        response['errors'] is! List ||
        (response['errors'] as List).isNotEmpty ||
        response['info'] is! Map ||
        response['answer'] is! Map<String, dynamic>) {
      throw const FormatException('Unsuccessful App Stats response');
    }
    return AppStatsSummary.fromMap(response['answer'] as Map<String, dynamic>);
  }

  factory AppStatsSummary.fromMap(Map<String, dynamic> map) {
    int count(String field) {
      final value = map[field];
      if (value is! int || value < 0 || value > 9007199254740991) {
        throw FormatException('Invalid App Stats count: $field');
      }
      return value;
    }

    final rawDate = map['generatedAt'];
    final date = rawDate is String ? DateTime.tryParse(rawDate) : null;
    if (date == null || !date.isUtc || date.toIso8601String() != rawDate) {
      throw const FormatException('Invalid App Stats timestamp');
    }
    return AppStatsSummary(
      autoRegisteredUsers: count('autoRegisteredUsers'),
      recordedBenchmarkRuns: count('recordedBenchmarkRuns'),
      deviceModels: count('deviceModels'),
      generatedAt: date,
    );
  }

  Map<String, dynamic> toMap() => {
        'autoRegisteredUsers': autoRegisteredUsers,
        'recordedBenchmarkRuns': recordedBenchmarkRuns,
        'deviceModels': deviceModels,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
      };
}

class AppStatsException implements Exception {
  final String message;
  const AppStatsException(this.message);
}

class AppStatsApi {
  final DioHttp? client;
  AppStatsApi({this.client});

  Future<AppStatsSummary> fetch() async {
    if (kIsWeb) {
      throw const AppStatsException(
          'App Stats is available only in the mobile app.');
    }
    final dio = client ?? DioHttp(dioOptions);
    try {
      final response = await dio
          .getUri(GNet.uriInsertResults.replace(path: '/appStats6d4f8b2a1c0'));
      if (response.statusCode != 200) {
        throw const AppStatsException('Statistics are unavailable right now.');
      }
      return AppStatsSummary.fromResponse(response.data);
    } on FormatException {
      debugPrint('App Stats: the backend returned an invalid summary.');
      throw const AppStatsException('Statistics are unavailable right now.');
    } on DioException catch (error) {
      debugPrint('App Stats: request failed (${error.type}).');
      throw const AppStatsException('Statistics are unavailable right now.');
    } finally {
      dio.close(force: true);
    }
  }
}

String formatAppStatsCount(int value) => value
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
