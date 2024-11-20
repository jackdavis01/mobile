import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

import 'anchored_adaptive_example.dart';
import 'fluid_example.dart';
import 'inline_adaptive_example.dart';
import 'native_template_example.dart';
import 'reusable_inline_example.dart';
import 'webview_example.dart';

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String _testDeviceAndroid = '73E7637649AE0B651EEC22FC4B4EE31A'; // 'YOUR_DEVICE_ID';
const String _testDeviceIOS = 'b14afd9e26b6af7d3e448ec4b3fa0817';
const String _testDeviceAndroid2 = '08620CC7B9E1A138DBA1EFBAD7AB748A';
const String _testDeviceAndroid3 = '9A8E66BF5ED524684357387404D023BA';
const int maxFailedLoadAttempts = 3;

class AdMobTestPage extends StatefulWidget {
  const AdMobTestPage({Key? key}) : super(key: key);

  @override
  _AdMobTestPageState createState() => _AdMobTestPageState();
}

class _AdMobTestPageState extends State<AdMobTestPage> {
  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  static const interstitialButtonText = 'InterstitialAd';
  static const rewardedButtonText = 'RewardedAd';
  static const rewardedInterstitialButtonText = 'RewardedInterstitialAd';
  static const fluidButtonText = 'Fluid';
  static const inlineAdaptiveButtonText = 'Inline adaptive';
  static const anchoredAdaptiveButtonText = 'Anchored adaptive';
  static const nativeTemplateButtonText = 'Native template';
  static const webviewExampleButtonText = 'Register WebView';
  static const adInspectorButtonText = 'Ad Inspector';

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  @override
  void initState() {
    super.initState();
    MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [_testDeviceAndroid, _testDeviceIOS, _testDeviceAndroid2, _testDeviceAndroid3]));
    _createInterstitialAd();
    _createRewardedAd();
    _createRewardedInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-4934899671581001/5660939728' // 'ca-app-pub- 3940256099942544/1033173712'
            : 'ca-app-pub-4934899671581001/7435397266',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-4934899671581001/9766973170'
            : 'ca-app-pub-4934899671581001/4398170386',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-4934899671581001/4826240326' // 'ca-app-pub- 3940256099942544/5354046379'
            : 'ca-app-pub-4934899671581001/8636928176',
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            debugPrint('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      debugPrint('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Plugin example page'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case interstitialButtonText:
                  _showInterstitialAd();
                  break;
                case rewardedButtonText:
                  _showRewardedAd();
                  break;
                case rewardedInterstitialButtonText:
                  _showRewardedInterstitialAd();
                  break;
                case fluidButtonText:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FluidExample()),
                  );
                  break;
                case inlineAdaptiveButtonText:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InlineAdaptiveExample()),
                  );
                  break;
                case anchoredAdaptiveButtonText:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnchoredAdaptiveExample()),
                  );
                  break;
                case nativeTemplateButtonText:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NativeTemplateExample()),
                  );
                  break;
                case webviewExampleButtonText:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WebViewExample()),
                  );
                  break;
                case adInspectorButtonText:
                  MobileAds.instance.openAdInspector((error) => log(
                      'Ad Inspector ' +
                          (error == null
                              ? 'opened.'
                              : 'error: ' + (error.message ?? ''))));
                  break;
                default:
                  throw AssertionError('unexpected button: $result');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: interstitialButtonText,
                child: const Text(interstitialButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: rewardedButtonText,
                child: const Text(rewardedButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: rewardedInterstitialButtonText,
                child: const Text(rewardedInterstitialButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: fluidButtonText,
                child: const Text(fluidButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: inlineAdaptiveButtonText,
                child: const Text(inlineAdaptiveButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: anchoredAdaptiveButtonText,
                child: const Text(anchoredAdaptiveButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: nativeTemplateButtonText,
                child: const Text(nativeTemplateButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: webviewExampleButtonText,
                child: const Text(webviewExampleButtonText),
              ),
              // ignore: prefer_const_constructors
              PopupMenuItem<String>(
                value: adInspectorButtonText,
                child: const Text(adInspectorButtonText),
              ),
            ],
          ),
        ],
      ),
      body: const SafeArea(child: ReusableInlineExample()),
    );
  }
}
