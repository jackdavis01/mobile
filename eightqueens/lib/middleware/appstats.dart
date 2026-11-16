import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apinetisolates/appstatsapicontroller.dart';
import 'localstorage.dart';

bool get appStatsSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

enum AppStatsSubmission { pending, uploading, failed, localOnly, recorded }

class AppStatsMeasurement extends ChangeNotifier {
  final AppStatsSummary? baseline;
  final bool canSubmit;
  AppStatsSubmission _status;
  AppStatsSummary? _refreshedSummary;
  Future<bool>? _confirmation;

  AppStatsMeasurement._(this.baseline, this.canSubmit)
      : _status = canSubmit
            ? AppStatsSubmission.pending
            : AppStatsSubmission.localOnly;

  AppStatsSubmission get status => _status;
  AppStatsSummary? get refreshedSummary => _refreshedSummary;
}

class AppStatsStore extends ChangeNotifier {
  static const cacheKey = 'appStatsSummary';
  static const refreshInterval = Duration(minutes: 5);
  static final instance = AppStatsStore(storage: spGlobal);

  final SharedPreferences storage;
  final Future<AppStatsSummary> Function() _fetch;
  final DateTime Function() _now;
  final Set<AppStatsMeasurement> _pendingWrites = {};
  AppStatsSummary? _summary;
  AppStatsMeasurement? lastMeasurement;
  bool _dirty = true;
  bool _loading = false;
  int _generation = 0;
  int? _requestGeneration;
  Future<bool>? _request;
  Future<bool> _saving = Future.value(true);
  String? errorMessage;

  AppStatsStore({
    required this.storage,
    Future<AppStatsSummary> Function()? fetch,
    DateTime Function()? now,
  })  : _fetch = fetch ?? AppStatsApi().fetch,
        _now = now ?? DateTime.now {
    final saved = storage.get(cacheKey);
    if (saved == null) return;
    try {
      if (saved is! String) {
        throw const FormatException('Invalid saved App Stats');
      }
      final decoded = jsonDecode(saved);
      if (decoded is! Map<String, dynamic> ||
          decoded['expired'] is! bool ||
          (decoded['summary'] == null && decoded['expired'] != true) ||
          (decoded['summary'] != null &&
              decoded['summary'] is! Map<String, dynamic>)) {
        throw const FormatException('Invalid saved App Stats');
      }
      if (decoded['summary'] != null) {
        _summary =
            AppStatsSummary.fromMap(decoded['summary'] as Map<String, dynamic>);
      }
      _dirty = decoded['expired'] as bool;
    } on FormatException {
      debugPrint('App Stats: saved statistics could not be read.');
      errorMessage = 'Saved statistics could not be read.';
    }
  }

  AppStatsSummary? get summary => _summary;
  bool get loading => _loading;
  bool get expired =>
      _dirty ||
      _summary == null ||
      !_now().toUtc().isBefore(_summary!.generatedAt.add(refreshInterval));
  bool get canRefresh => !_loading && expired;
  Duration get cooldownRemaining => expired
      ? Duration.zero
      : _summary!.generatedAt.add(refreshInterval).difference(_now().toUtc());

  AppStatsMeasurement completeMeasurement({required bool canSubmit}) {
    final measurement = AppStatsMeasurement._(_summary, canSubmit);
    lastMeasurement = measurement;
    if (canSubmit) _pendingWrites.add(measurement);
    _generation++;
    _dirty = true;
    unawaited(_persist());
    notifyListeners();
    return measurement;
  }

  void submissionStarted(AppStatsMeasurement measurement) {
    _pendingWrites.add(measurement);
    measurement._status = AppStatsSubmission.uploading;
    measurement.notifyListeners();
  }

  void submissionFailed(AppStatsMeasurement measurement) {
    _pendingWrites.remove(measurement);
    measurement._status = AppStatsSubmission.failed;
    _generation++;
    _dirty = true;
    unawaited(_persist());
    measurement.notifyListeners();
    notifyListeners();
  }

  Future<bool> submissionRecorded(AppStatsMeasurement measurement) {
    if (!measurement.canSubmit) {
      throw StateError(
          'A local-only benchmark cannot confirm backend storage.');
    }
    return measurement._confirmation ??= _afterStorage(measurement);
  }

  Future<bool> _afterStorage(AppStatsMeasurement measurement) async {
    _pendingWrites.remove(measurement);
    measurement._status = AppStatsSubmission.recorded;
    _generation++;
    _dirty = true;
    measurement.notifyListeners();
    notifyListeners();
    return _persist();
  }

  Future<bool> refresh({bool force = false}) {
    final running = _request;
    if (running != null) {
      if (_requestGeneration == _generation) return running;
      // A pre-storage request must finish before starting the required new read.
      return running.then((_) => refresh(force: force));
    }
    if (!force && !expired) return Future.value(true);
    _loading = true;
    _requestGeneration = _generation;
    final request = _load(_generation).whenComplete(() {
      _request = null;
      _loading = false;
      notifyListeners();
    });
    _request = request;
    notifyListeners();
    return request;
  }

  Future<bool> _load(int generation) async {
    try {
      final latest = await _fetch();
      if (generation != _generation) return false;
      _summary = latest;
      _dirty = _pendingWrites.isNotEmpty;
      errorMessage = null;
      final saved = await _persist();
      if (generation != _generation || !saved) return false;
      final measurement = lastMeasurement;
      if (measurement?.status == AppStatsSubmission.recorded) {
        measurement!._refreshedSummary = latest;
        measurement.notifyListeners();
      }
      return true;
    } on AppStatsException catch (error) {
      if (generation != _generation) return false;
      debugPrint('App Stats: ${error.message}');
      _dirty = true;
      errorMessage = 'Could not refresh. Showing saved statistics.';
      await _persist();
      return false;
    }
  }

  Future<bool> _persist() {
    _saving = _saving.then((_) async {
      try {
        final saved = await storage.setString(
            cacheKey,
            jsonEncode({
              'summary': _summary?.toMap(),
              'expired': _dirty,
            }));
        if (saved) return true;
      } on PlatformException {
        debugPrint('App Stats: local storage could not be written.');
      }
      _dirty = true;
      errorMessage = 'Statistics could not be saved on this device.';
      debugPrint(
          'App Stats: retaining expired state after a cache save failure.');
      notifyListeners();
      return false;
    });
    return _saving;
  }

  Future<void> flush() async {
    await _saving;
  }
}
