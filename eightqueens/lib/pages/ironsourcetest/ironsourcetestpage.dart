import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import './utils.dart';
import './horizontal_buttons.dart';

const String appUserId = '511399783462182';

class IronSourceTestPage extends StatefulWidget {
  const IronSourceTestPage({Key? key}) : super(key: key);

  @override
  State<IronSourceTestPage> createState() => _IronSourceTestPageState();
}

class _IronSourceTestPageState extends State<IronSourceTestPage> with LevelPlayImpressionDataListener, LevelPlayInitListener{

  @override
  void initState() {
    // Wait until all listeners are set in the child widgets.
    // instance is always initialized when this is called since it's only called in runApp.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
    super.initState();
  }

  // For iOS14 IDFA access
  // Must be called when the app is in the state UIApplicationStateActive
  Future<void> checkATT() async {
    final currentStatus =
    await ATTrackingManager.getTrackingAuthorizationStatus();
    debugPrint('ATTStatus: $currentStatus');
    if (currentStatus == ATTStatus.NotDetermined) {
      final returnedStatus =
      await ATTrackingManager.requestTrackingAuthorization();
      debugPrint('ATTStatus returned: $returnedStatus');
    }
    return;
  }

  /// Enables debug mode for LevelPlay adapters.
  /// Validates integration.
  Future<void> enableDebug() async {
    await LevelPlay.setAdaptersDebug(true);
    // this function doesn't have to be awaited
    LevelPlay.validateIntegration();
  }

  /// Sets user segment params sample information for LevelPlay.
  /*Future<void> setSegment() async {
    final segment = LevelPlaySegment();
    segment.level = 3;
    segment.isPaying = false;
    segment.userCreationDate = DateTime.now().millisecondsSinceEpoch;
    segment.iapTotal = 1000;
    segment.setCustom(key: 'DemoCustomKey', value: 'DemoCustomVal');
    await LevelPlay.setSegment(segment);
  }*/

  /// Sets regulation parameters for LevelPlay.
  Future<void> setRegulationParams() async {
    // GDPR
    await LevelPlayPrivacySettings.setGDPRConsent(true);
    // CCPA (true = user opted out of sale)
    await LevelPlayPrivacySettings.setCCPA(false);
    // COPPA (true = child-directed)
    await LevelPlayPrivacySettings.setCOPPA(false);
    await LevelPlay.setMetaData({
      'is_test_suite': ['enable']
    });

    return;
  }

  /// Initialize LevelPlay (ironSource) SDK.
  Future<void> init() async {
    final appKey = Platform.isAndroid
        ? "2032760fd"
        : Platform.isIOS
        ? "2032a866d"
        : throw Exception("Unsupported Platform");
    try {
      LevelPlay.setFlutterVersion('3.47.9');
      LevelPlay.addImpressionDataListener(this);
      await enableDebug();

      // GDPR, CCPA, COPPA etc
      await setRegulationParams();

      // Segment info
      // await setSegment();

      // Authorization Request for IDFA use
      if (Platform.isIOS) {
        await checkATT();
      }

      // Finally, initialize
      // LevelPlay Init
      final initRequest = LevelPlayInitRequest.builder(appKey)
        .withUserId(appUserId)
        .build();
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } on PlatformException catch (e) {
      debugPrint("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("IS Test")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Image.asset('assets/images/is/iS_logo.png'),
              Utils.spacerLarge,
              const LevelPlayRewardedVideoSection(),
              Utils.spacerLarge,
              const LevelPlayInterstitialAdSection(),
              Utils.spacerLarge,
              const LevelPlayBannerAdViewSection(),
              Utils.spacerLarge,
              const LevelPlayNativeAdViewSection(),
              Utils.spacerLarge,
              const TestSuiteSection()
            ],
          ),
        ),
      ),
    );
  }

  /// ImpressionData listener --------------------------------------------------///
  @override
  void onImpressionSuccess(LevelPlayImpressionData impressionData) {
    debugPrint('Impression Data: $impressionData');
  }

  /// LevelPlay Init listener --------------------------------------------------///
  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('onInitFailed ${error.errorMessage}');
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('onInitSuccess isAdQualityEnabled=${configuration.isAdQualityEnabled}');
  }
}

/// LevelPlay Rewarded Video Section -------------------------------------------///
class LevelPlayRewardedVideoSection extends StatefulWidget {
  const LevelPlayRewardedVideoSection({Key? key}) : super(key: key);

  @override
  _LevelPlayRewardedVideoSectionState createState() =>
      _LevelPlayRewardedVideoSectionState();
}

class _LevelPlayRewardedVideoSectionState extends State<LevelPlayRewardedVideoSection> with LevelPlayRewardedAdListener {
  final LevelPlayRewardedAd _rewardedAd = LevelPlayRewardedAd(adUnitId: Platform.isAndroid ? 'wi4iag4j3ki34clu' : 'gpwcxtrm9gscd82n');

  @override
  void initState() {
    super.initState();
    _rewardedAd.setListener(this);
  }

  void _loadAd() async {
    _rewardedAd.loadAd();
  }

  Future<void> _showAd() async {
    if (await _rewardedAd.isAdReady()) {
      _rewardedAd.showAd(placementName: 'Default');
    }
  }

  void showTextDialog(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Rewarded Ad", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      HorizontalButtons([
        ButtonInfo("Load Ad", _loadAd),
        ButtonInfo("Show Ad", _showAd),
      ]),
    ]);
  }

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdRewarded: $adInfo");
    showTextDialog(context, 'Rewarded', reward.toString());
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdClicked: $adInfo");
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdClosed: $adInfo");
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdDisplayFailed: adInfo - $adInfo, error - $error");
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdDisplayed: $adInfo");
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdInfoChanged: $adInfo");
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    debugPrint("Rewarded Ad - onAdLoadFailed: $error");
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdLoaded: $adInfo");
  }

}

/// LevelPlay Interstitial Ad Section ------------------------------------------///
class LevelPlayInterstitialAdSection extends StatefulWidget {
  const LevelPlayInterstitialAdSection({Key? key}) : super(key: key);

  @override
  _LevelPlayInterstitialAdSectionState createState() => _LevelPlayInterstitialAdSectionState();
}

class _LevelPlayInterstitialAdSectionState extends State<LevelPlayInterstitialAdSection> with LevelPlayInterstitialAdListener {
  LevelPlayInterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  void _createInterstitialAd() {
    _interstitialAd = LevelPlayInterstitialAd(adUnitId: Platform.isAndroid ? 'mc9r5y8eg4w4lxz5' : 'l94310761slwpxhz');
    _interstitialAd!.setListener(this);
  }

  Future<void> _showAd() async {
    if (_interstitialAd != null && await _interstitialAd!.isAdReady()) {
      _interstitialAd!.showAd(placementName: 'Default');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Interstitial Ad", style: Utils.headingStyle),
      HorizontalButtons([
        ButtonInfo("Load Ad", () => _interstitialAd?.loadAd()),
        ButtonInfo("Show Ad", _showAd),
      ]),
    ]);
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint("Interstitial Ad - onAdClicked: $adInfo");
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    debugPrint("Interstitial Ad - onAdClosed: $adInfo");
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    debugPrint("Interstitial Ad - onAdDisplayFailed: adInfo - $adInfo, error - $error");
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint("Interstitial Ad - onAdDisplayed: $adInfo");
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    debugPrint("Interstitial Ad - onAdInfoChanged: $adInfo");
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    debugPrint("Interstitial Ad - onAdLoadFailed: $error");
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    debugPrint("Interstitial Ad - onAdLoaded: $adInfo");
  }
}

/// LevelPlay Banner Ad View Section -------------------------------------------///
class LevelPlayBannerAdViewSection extends StatefulWidget {
  const LevelPlayBannerAdViewSection({Key? key}) : super(key: key);

  @override
  _LevelPlayBannerAdViewSectionState createState() => _LevelPlayBannerAdViewSectionState();
}

class _LevelPlayBannerAdViewSectionState extends State<LevelPlayBannerAdViewSection> with LevelPlayBannerAdViewListener {
  LevelPlayBannerAdView? _bannerAdView;

  @override
  void initState() {
    super.initState();
    _createBannerAdView();
  }

  void _createBannerAdView() {
    final _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
    _bannerAdView = LevelPlayBannerAdView(
      key: _bannerKey,
      adUnitId: Platform.isAndroid ? 'h9zn1wd15b3grnt7' : 'cg12hpgavcaqcub1',
      adSize: LevelPlayAdSize.BANNER,
      listener: this,
      placementName: 'Achievements',
    );
  }

  void _destroyAdAndCreateNew() {
    if (_bannerAdView == null) return;

    _bannerAdView!.destroy();
    setState(() {
      _createBannerAdView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Banner Ad View", style: Utils.headingStyle),
      HorizontalButtons([
        ButtonInfo("Load Ad", () => _bannerAdView?.loadAd()),
        ButtonInfo("Destroy Ad", _destroyAdAndCreateNew)
      ]),
      HorizontalButtons([
        ButtonInfo("Pause Auto Refresh", () => _bannerAdView?.pauseAutoRefresh() ),
        ButtonInfo("Resume Auto Refresh", () => _bannerAdView?.resumeAutoRefresh() ),
      ]),
      SizedBox(
        width: 320,
        height: 50,
        child: _bannerAdView ?? Container(),
      )
    ]);
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    debugPrint("Banner Ad View - onAdClicked: $adInfo");
  }

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {
    debugPrint("Banner Ad View - onAdCollapsed: $adInfo");
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    debugPrint("Banner Ad View - onAdDisplayFailed: adInfo - $adInfo, error - $error");
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    debugPrint("Banner Ad View - onAdDisplayed: $adInfo");
  }

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {
    debugPrint("Banner Ad View - onAdExpanded: $adInfo");
  }

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {
    debugPrint("Banner Ad View - onAdLeftApplication: $adInfo");
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    debugPrint("Banner Ad View - onAdLoadFailed: $error");
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    debugPrint("Banner Ad View - onAdLoaded: $adInfo");
  }
}

/// LevelPlay Native Ad View Section -------------------------------------------///
class LevelPlayNativeAdViewSection extends StatefulWidget {

  const LevelPlayNativeAdViewSection({Key? key}) : super(key: key);

  @override
  _LevelPlayNativeAdsSection createState() =>
      _LevelPlayNativeAdsSection();
}

class _LevelPlayNativeAdsSection extends State<LevelPlayNativeAdViewSection> with LevelPlayNativeAdListener {
  LevelPlayNativeAd? _nativeAd;
  LevelPlayNativeAdView? _nativeAdView;

  @override
  void initState() {
    super.initState();
    _createNativeAd();
    _createNativeAdView();
  }

  /// Initialize native ad object
  void _createNativeAd() {
    _nativeAd = LevelPlayNativeAd.builder()
        .withPlacementName('') // Your placement name string
        .withListener(this) // Your level play native ad listener
        .build();
  }

  /// Initialize native ad view widget with native ad
  void _createNativeAdView() {
    _nativeAdView = LevelPlayNativeAdView(
        key: GlobalKey(), // Unique key to force recreation of widget
        height: 150, // Your chosen height
        width: double.infinity, // Your chosen width
        nativeAd: _nativeAd, // Native ad object
        templateType: LevelPlayTemplateType.SMALL // Built-in native ad template(not required when implementing custom template),
    );
  }

  /// Destroy current native ad and create new instances of LevelPlayNativeAd and LevelPlayNativeAdView.
  void _destroyAdAndCreateNew() {
    if (_nativeAd == null) return;

    _nativeAd!.destroyAd();
    setState(() {
      _createNativeAd();
      _createNativeAdView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Native Ad", style: Utils.headingStyle),
      HorizontalButtons([
        ButtonInfo("Load Ad", () => _nativeAd?.loadAd()),
        ButtonInfo("Destroy Ad", _destroyAdAndCreateNew),
      ]),
      _nativeAdView ?? Container()
    ],
    );
  }

  // LevelPlay NativeAd listener

  @override
  void onAdClicked(LevelPlayNativeAd nativeAd, AdInfo adInfo) {
    debugPrint('onAdClicked - adInfo: $adInfo');
  }

  @override
  void onAdImpression(LevelPlayNativeAd nativeAd, AdInfo adInfo) {
    debugPrint('onAdImpression - adInfo: $adInfo');
  }

  @override
  void onAdLoadFailed(LevelPlayNativeAd nativeAd, IronSourceError error) {
    debugPrint('onAdLoadFailed - error: $error');
  }

  @override
  void onAdLoaded(LevelPlayNativeAd nativeAd, AdInfo adInfo) {
    debugPrint('onAdLoaded - nativeAd: $_nativeAd, adInfo: $adInfo');
    setState(() {
      _nativeAd = nativeAd;
    });
  }
}

/// Test Suite Section ---------------------------------------------------------///
class TestSuiteSection extends StatelessWidget {
  const TestSuiteSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Integration Test Suite", style: Utils.headingStyle),
      // Requires the 'is_test_suite' metadata set before init and a successful init.
      HorizontalButtons([ButtonInfo("Launch Test Suite", () => LevelPlay.launchTestSuite())]),
    ]);
  }
}