import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apinetisolates/resultshareconfigapicontroller.dart';
import '../parameters/resultshare.dart';
import 'autoregistration.dart';
import 'localstorage.dart';

String formatResultShare({
  required String username,
  required int threads,
  required Duration elapsed,
  bool multiline = false,
}) {
  final name = username.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (name.isEmpty ||
      name == AutoRegLocal.sMe ||
      threads <= 0 ||
      elapsed <= Duration.zero) {
    throw const FormatException(
        'A completed result and actual username are required.');
  }
  final milliseconds = elapsed.inMilliseconds;
  final seconds =
      '${milliseconds ~/ 1000}.${(milliseconds % 1000).toString().padLeft(3, '0')}';
  return '8 Queens | $name${multiline ? '\n' : ' | '}$threads ${threads == 1 ? 'thread' : 'threads'} | $seconds s';
}

class ResultShareConfigStore extends ChangeNotifier {
  static const cacheKey = 'resultShareConfig';
  static const refreshInterval = Duration(hours: 24);
  static const maxCacheAge = Duration(days: 7);
  static final instance = ResultShareConfigStore(storage: spGlobal);

  final SharedPreferences storage;
  final Future<Uri> Function() _fetch;
  final DateTime Function() _now;
  Uri? _uri;
  DateTime? _fetchedAt;
  Future<void>? _request;
  bool _disposed = false;
  String? errorMessage;

  ResultShareConfigStore({
    required this.storage,
    Future<Uri> Function()? fetch,
    DateTime Function()? now,
  })  : _fetch = fetch ?? ResultShareConfigApi().fetch,
        _now = now ?? DateTime.now {
    final saved = storage.get(cacheKey);
    if (saved == null) {
      debugPrint('Result sharing: no cached link; using bundled fallback.');
      return;
    }
    try {
      if (saved is! String) {
        throw const FormatException('Invalid sharing cache');
      }
      final data = jsonDecode(saved);
      if (data is! Map<String, dynamic> ||
          data['url'] is! String ||
          data['fetchedAt'] is! String) {
        throw const FormatException('Invalid sharing cache');
      }
      final uri = parseTikTokVideoUrl(data['url'] as String);
      final date = DateTime.tryParse(data['fetchedAt'] as String);
      if (date == null ||
          !date.isUtc ||
          date.toIso8601String() != data['fetchedAt'] ||
          date.isAfter(_now().toUtc())) {
        throw const FormatException('Invalid sharing cache timestamp');
      }
      _uri = uri;
      _fetchedAt = date;
    } on FormatException {
      debugPrint('Result sharing: invalid saved link; using bundled fallback.');
      errorMessage = 'The saved TikTok link could not be read.';
    }
  }

  Duration? get _cacheAge =>
      _fetchedAt == null ? null : _now().toUtc().difference(_fetchedAt!);
  bool get usingFallback =>
      _uri == null ||
      _cacheAge == null ||
      _cacheAge! < Duration.zero ||
      _cacheAge! > maxCacheAge;
  Uri get selectedUri => usingFallback ? resultShareFallbackUri : _uri!;
  bool get loading => _request != null;

  Future<void> refreshIfNeeded() {
    if (_request != null) return _request!;
    if (!usingFallback && _cacheAge! < refreshInterval) return Future.value();
    final request = _load().whenComplete(() {
      _request = null;
      if (!_disposed) notifyListeners();
    });
    _request = request;
    notifyListeners();
    return request;
  }

  Future<void> _load() async {
    try {
      final uri = parseTikTokVideoUrl((await _fetch()).toString());
      if (_disposed) return;
      _uri = uri;
      _fetchedAt = _now().toUtc();
      errorMessage = null;
      final saved = await storage.setString(
          cacheKey,
          jsonEncode({
            'url': uri.toString(),
            'fetchedAt': _fetchedAt!.toIso8601String(),
          }));
      if (!saved) {
        debugPrint('Result sharing: link cache could not be saved.');
        errorMessage = 'The TikTok link could not be saved on this device.';
      }
    } on ResultShareConfigException catch (error) {
      debugPrint(
          'Result sharing: ${error.message} Using cached or bundled link.');
      errorMessage = error.message;
    } on FormatException {
      debugPrint(
          'Result sharing: invalid link response; retaining cached or bundled link.');
      errorMessage = 'The TikTok link could not be retrieved.';
    } on PlatformException {
      debugPrint('Result sharing: link cache storage failed.');
      errorMessage = 'The TikTok link could not be saved on this device.';
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class ResultShareException implements Exception {
  final String message;
  const ResultShareException(this.message);
}

class ResultShareActions {
  final Future<void> Function(String) _copy;
  final Future<bool> Function(Uri) _open;
  final Future<ShareResult> Function(ShareParams) _share;

  ResultShareActions({
    Future<void> Function(String)? copy,
    Future<bool> Function(Uri)? open,
    Future<ShareResult> Function(ShareParams)? share,
  })  : _copy =
            copy ?? ((text) => Clipboard.setData(ClipboardData(text: text))),
        _open = open ??
            ((uri) => launchUrl(uri, mode: LaunchMode.externalApplication)),
        _share = share ?? ((params) => SharePlus.instance.share(params));

  Future<bool> copyAndOpenTikTok(String text, Uri uri,
      {required bool Function() canProceed}) async {
    try {
      await _copy(text);
    } on PlatformException {
      debugPrint('Result sharing: clipboard write failed.');
      throw const ResultShareException(
          'The result could not be copied. Please try again.');
    } on MissingPluginException {
      debugPrint('Result sharing: clipboard is unavailable.');
      throw const ResultShareException(
          'The clipboard is unavailable on this device.');
    }
    if (!canProceed()) return false;
    if (await _launch(uri)) return true;
    if (uri != resultShareFallbackUri &&
        canProceed() &&
        await _launch(resultShareFallbackUri)) {
      return true;
    }
    throw const ResultShareException(
        'Result copied, but TikTok could not be opened. Try Share result instead.');
  }

  Future<bool> _launch(Uri uri) async {
    try {
      final opened = await _open(uri);
      if (!opened) {
        debugPrint('Result sharing: external video launch was rejected.');
      }
      return opened;
    } on PlatformException {
      debugPrint('Result sharing: external video launch failed.');
      return false;
    } on MissingPluginException {
      debugPrint('Result sharing: external video launch is unavailable.');
      return false;
    }
  }

  Future<void> shareText(String text, Rect origin) async {
    try {
      await _share(ShareParams(text: text, sharePositionOrigin: origin));
    } on PlatformException {
      debugPrint('Result sharing: native share sheet failed.');
      throw const ResultShareException(
          'The share sheet could not be opened. Please try again.');
    } on MissingPluginException {
      debugPrint('Result sharing: native share sheet is unavailable.');
      throw const ResultShareException(
          'Sharing is unavailable on this device.');
    }
  }
}
