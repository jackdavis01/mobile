import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_levelplay_mediation/unity_levelplay_mediation.dart';
import '../parameters/ads.dart' as ads;
import '../middleware/deviceinfoplus.dart';

/// Space pages reserve below their content for a [_kDefaultBannerHeight] banner.
const double _kMinBannerSpace = 64;
const double _kDefaultBannerHeight = 50;

class AdBanner extends StatefulWidget {
  const AdBanner({Key? key}) : super(key: key);

  /// Height of the last loaded AdMob banner. Large anchored adaptive banners
  /// can be up to 150 dp tall, so layouts must follow it instead of a constant.
  static final ValueNotifier<double> height = ValueNotifier<double>(_kDefaultBannerHeight);

  /// Extra height needed beyond what pages reserve for a [_kDefaultBannerHeight] banner.
  static double _extraHeight(double bannerHeight) => math.max(0, bannerHeight - _kDefaultBannerHeight);

  @override
  State<StatefulWidget> createState()  => _AdBannerState();
}

/// Keeps the end of scrollable content clear of the bottom [AdBanner].
class AdBannerSpace extends StatelessWidget {
  const AdBannerSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
      valueListenable: AdBanner.height,
      builder: (context, bannerHeight, _) =>
          SizedBox(height: _kMinBannerSpace + AdBanner._extraHeight(bannerHeight)));
}

/// Lifts a floating action button above the bottom [AdBanner].
class AdBannerFabLift extends StatelessWidget {
  final Widget child;
  const AdBannerFabLift({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
      valueListenable: AdBanner.height,
      builder: (context, bannerHeight, child) =>
          Padding(padding: EdgeInsets.only(bottom: AdBanner._extraHeight(bannerHeight)), child: child),
      child: child);
}

class _AdBannerState extends State<AdBanner> with LevelPlayImpressionDataListener, LevelPlayInitListener {

  /// Ad Provider Systems Initialization Section -------------------------------------------///

  @override
  initState() {
    if (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [ads.testDeviceAndroid, ads.testDeviceIOS, ads.testDeviceAndroid2, ads.testDeviceAndroid3]));
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!kIsWeb) await initIronSource();
      });
    }
    super.initState();
  }

  /// AdMob Banner Ad Controller Section -------------------------------------------///

  BannerAd? _anchoredAdaptiveAd;
  bool _isAdMobLoaded = false;
  late Orientation _currentOrientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    if (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) _loadAd();
  }

  /// Load another ad, disposing of the current ad if there is one.
  Future<void> _loadAd() async {
    await _anchoredAdaptiveAd?.dispose();
    setState(() {
      _anchoredAdaptiveAd = null;
      _isAdMobLoaded = false;
    });

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
            MediaQuery.sizeOf(context).width.truncate());

    if (size == null) {
      debugPrint('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-4934899671581001/9878983386' // 'ca-app-pub- 3940256099942544/9214589741'
          : 'ca-app-pub-4934899671581001/9758308276',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isAdMobLoaded = true;
          });
          AdBanner.height.value = size.height.toDouble();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  /// Gets a widget containing the ad, if one is loaded.
  ///
  /// Returns an empty container if no ad is loaded, or the orientation
  /// has changed. Also loads a new ad if the orientation changes.
  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _anchoredAdaptiveAd != null &&
            _isAdMobLoaded) {
          return Container(
            color: Colors.green,
            width: _anchoredAdaptiveAd!.size.width.toDouble(),
            height: _anchoredAdaptiveAd!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredAdaptiveAd!),
          );
        }
        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
        }
        return Container();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _anchoredAdaptiveAd?.dispose();
  }

  /// LevelPlay Banner Ad Controller Section -------------------------------------------///

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
  Future<void> initIronSource() async {
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
        .withUserId(ads.appUserId)
        .build();
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } on PlatformException catch (e) {
      debugPrint("$e");
    }
  }

  final LevelPlayBannerAdViewController _lpbavController = LevelPlayBannerAdViewController();

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
    _lpbavController.doLoadActionInChild();
  }

  @override
  Widget build(BuildContext context) {
    return
      (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
      ? (_isAdMobLoaded)
        ? _getAdWidget()
        : SizedBox(width: double.infinity, height: 50, child: LevelPlayBannerAdViewSection(lpbavController: _lpbavController, fGetIsAdMobLoaded: () => _isAdMobLoaded))
      : const SizedBox.shrink();
  }

}

class LevelPlayBannerAdViewController {
  Future<void> Function()? _onLoad;

  void setOnLoad(Future<void> Function()? onLoad) { _onLoad = onLoad; }

  Future<void> doLoadActionInChild() async {
    if (null != _onLoad) {
      await _onLoad!();
    }
  }
}

/// LevelPlay Banner Ad View Section -------------------------------------------///
class LevelPlayBannerAdViewSection extends StatefulWidget {
  final LevelPlayBannerAdViewController lpbavController;
  final bool Function() fGetIsAdMobLoaded;

  const LevelPlayBannerAdViewSection({required this.lpbavController, required this.fGetIsAdMobLoaded, Key? key}) : super(key: key);

  @override
  _LevelPlayBannerAdViewSectionState createState() => _LevelPlayBannerAdViewSectionState();
}

class _LevelPlayBannerAdViewSectionState extends State<LevelPlayBannerAdViewSection> with LevelPlayBannerAdViewListener {
  LevelPlayBannerAdView? _bannerAdView;

  @override
  void initState() {
    super.initState();
    _createBannerAdView();
    widget.lpbavController.setOnLoad(_bannerAdView?.loadAd);
  }

  void _createBannerAdView() {
    debugPrint("infopage.dart, LevelPlayBannerAdViewSection, _createBannerAdView() Action triggered.");
    final _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
    _bannerAdView = LevelPlayBannerAdView(
      key: _bannerKey,
      adUnitId: Platform.isAndroid ? 'h9zn1wd15b3grnt7' : 'cg12hpgavcaqcub1',
      adSize: LevelPlayAdSize.BANNER,
      listener: this,
      placementName: 'Achievements',
      //onPlatformViewCreated: _loadBanner,
    );
  }

  //void _loadBanner() { _loadISAd(); }

  final headingStyle = const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(width: double.infinity, height: 50, child: _bannerAdView ?? Container()),
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
