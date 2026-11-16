import 'package:flutter/foundation.dart';

bool get resultSharingSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

final resultShareFallbackUri = Uri.parse('https://vm.tiktok.com/ZN854AeaU/');

Uri parseTikTokVideoUrl(String input) {
  final value = input.trim();
  final uri = Uri.tryParse(value);
  if (!RegExp(r'^https://', caseSensitive: false).hasMatch(value) ||
      RegExp(r'[\s\\]').hasMatch(value) ||
      uri == null ||
      uri.scheme != 'https' ||
      (uri.host != 'www.tiktok.com' && uri.host != 'vm.tiktok.com') ||
      uri.userInfo.isNotEmpty ||
      (uri.hasPort && uri.port != 443) ||
      uri.path.isEmpty ||
      uri.path == '/') {
    throw const FormatException('Invalid TikTok video URL');
  }
  return uri;
}
