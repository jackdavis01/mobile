import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import 'admobtest/admobtestpage.dart';
import 'ironsourcetest/ironsourcetestpage.dart';
import '../parameters/globals.dart';
import '../parameters/ads.dart';
import '../middleware/deviceinfoplus.dart';
import 'contributionpage.dart';
import '../widgets/globalwidgets.dart';
import '../widgets/rankrangelist.dart';

const String appUserId = '511399783462182';

class ResultPage extends StatefulWidget {
  final int speed;
  final Color color;
  final Color backgroundcolor;
  final int threads;
  final Duration elapsed;
  final String rankname;
  const ResultPage(
      {Key? key,
      required this.speed,
      required this.color,
      required this.backgroundcolor,
      required this.threads,
      required this.elapsed,
      required this.rankname})
      : super(key: key);
  @override
  ResultPageState createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> with ImpressionDataListener, IronSourceInitializationListener, LevelPlayInitListener {

  void _openContributionPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionPage()));

  void _openAdModTestPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdMobTestPage()));

  void _openIronSourceTestPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const IronSourceTestPage()));

  final LevelPlayBannerAdViewController _lpbavController = LevelPlayBannerAdViewController();

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leading: null,
          title: Row(children: <Widget>[
            Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                    icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
              ),
              const Padding(padding: EdgeInsets.only(right: 18), child: Text("Result")),
              const SizedBox(width: 36)
            ]))
          ]),
        ),
        backgroundColor: Colors.blue.shade50,
        body: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
          ListView(physics: const BouncingScrollPhysics(), controller: scrollController, children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        RoundedContainer(
                            width: double.infinity,
                            constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                            margin: const EdgeInsets.all(0.0),
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                padding: const EdgeInsets.only(top: 30, bottom: 30),
                                child: Column(children: <Widget>[
                                  const Padding(
                                      padding: EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        '8 Queens',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 32),
                                      )),
                                  const Padding(
                                      padding: EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        'Speed Result',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 24),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 22, bottom: 7, left: 15, right: 15),
                                      child: Text.rich(
                                                TextSpan(
                                                  text: 'Threads: ',
                                                  style: const TextStyle(fontSize: 20),
                                                  children: <InlineSpan> [
                                                    TextSpan(
                                                      text: widget.threads.toString(),
                                                      style: TextStyle(
                                                      fontSize: 28,
                                                      color: widget.color)
                                                    )
                                                  ]
                                                ),
                                                textAlign: TextAlign.justify,
                                      ),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 4, bottom: 7, left: 15, right: 15),
                                      child: Text('Time Elapsed',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(fontSize: 20))),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 4, bottom: 15, left: 15, right: 15),
                                      child: Text('Rank:',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(fontSize: 20))),
                                  Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: widget.backgroundcolor,
                                          borderRadius: BorderRadius.circular(6)),
                                      child: IntrinsicWidth(
                                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                                        Text(widget.elapsed.toString().substring(
                                                0, widget.elapsed.toString().indexOf('.') + 4),
                                            style: TextStyle(
                                                fontSize: 27.2,
                                                color: widget.color,
                                                backgroundColor: widget.backgroundcolor)),
                                        const Divider(thickness: 2, color: Colors.white),
                                        Center(child: Text(widget.rankname,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 27.2,
                                                color: widget.color,
                                                backgroundColor: widget.backgroundcolor)))
                                      ])))
                                ]))),
                        const SizedBox(height: 20),
                      ]),
                      (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
                      ? ElevatedButton(
                          child: const Padding(
                              padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                              child: Text("Contribution", style: TextStyle(fontSize: 20))),
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                          onPressed: _openContributionPage,
                      )
                      : const SizedBox.shrink(),
                      (GV.bDev && !kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
                      ? Padding(padding: const EdgeInsets.only(top: 20), child: ElevatedButton(
                          child: const Padding(
                              padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                              child: Text("Start Ad Test", style: TextStyle(fontSize: 20))),
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                          onPressed: _openAdModTestPage,
                      ))
                      : const SizedBox.shrink(),
                      (GV.bDev && !kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
                      ? Padding(padding: const EdgeInsets.only(top: 20), child: ElevatedButton(
                          child: const Padding(
                              padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                              child: Text("IronSource Test", style: TextStyle(fontSize: 20))),
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                          onPressed: _openIronSourceTestPage,
                      ))
                      : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                      const RankRangeListTitle(),
                      RankRangeList(),
                      const SizedBox(height: 64), // ad banner place
                    ]))
          ]),
          (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
          ? (_isAdMobLoaded)
            ? _getAdWidget()
            : SizedBox(width: double.infinity, height: 50, child: LevelPlayBannerAdViewSection(lpbavController: _lpbavController, fGetIsAdMobLoaded: () => _isAdMobLoaded))
          : const SizedBox.shrink(),
        ]));
  }

  BannerAd? _anchoredAdaptiveAd;
  bool _isAdMobLoaded = false;
  late Orientation _currentOrientation;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [testDeviceAndroid, testDeviceIOS, testDeviceAndroid2, testDeviceAndroid3]));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('ResultPage, initState(), getDeviceInfoModel: ${await getDeviceInfoModel()}');
      await initIronSource();
      await Future.delayed(const Duration(milliseconds: 5000));
      if (mounted) scrollController.animateTo(420, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
    });
  }

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
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

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

  /// Enables debug mode for IronSource adapters.
  /// Validates integration.
  Future<void> enableDebug() async {
    await IronSource.setAdaptersDebug(true);
    // this function doesn't have to be awaited
    IronSource.validateIntegration();
  }

  /// Sets regulation parameters for IronSource.
  Future<void> setRegulationParams() async {
    // GDPR
    await IronSource.setConsent(true);
    await IronSource.setMetaData({
      // CCPA
      'do_not_sell': ['false'],
      // COPPA
      'is_child_directed': ['false'],
      'is_test_suite': ['enable']
    });

    return;
  }

  /// Initialize iron source SDK.
  Future<void> initIronSource() async {
    final appKey = Platform.isAndroid
        ? "2032760fd"
        : Platform.isIOS
        ? "2032a866d"
        : throw Exception("Unsupported Platform");
    try {
      IronSource.setFlutterVersion('3.24.5');
      IronSource.addImpressionDataListener(this);
      await enableDebug();
      await IronSource.shouldTrackNetworkState(true);

      // GDPR, CCPA, COPPA etc
      await setRegulationParams();

      // Segment info
      // await setSegment();

      // GAID, IDFA, IDFV
      String id = await IronSource.getAdvertiserId();
      debugPrint('AdvertiserID: $id');

      // Do not use AdvertiserID for this.
      await IronSource.setUserId(appUserId);

      // Authorization Request for IDFA use
      if (Platform.isIOS) {
        await checkATT();
      }

      // Finally, initialize
      // LevelPlay Init
      List<AdFormat> legacyAdFormats = [AdFormat.BANNER, AdFormat.REWARDED, AdFormat.INTERSTITIAL, AdFormat.NATIVE_AD];
      final initRequest = LevelPlayInitRequest(appKey: appKey, legacyAdFormats: legacyAdFormats);
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } on PlatformException catch (e) {
      debugPrint("$e");
    }
  }

  /// ImpressionData listener --------------------------------------------------///
  @override
  void onImpressionSuccess(ImpressionData? impressionData) {
    debugPrint('Impression Data: $impressionData');
  }

  /// Initialization listener --------------------------------------------------///
  @override
  void onInitializationComplete() {
    debugPrint('onInitializationComplete');
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
    debugPrint("resultpage.dart, LevelPlayBannerAdViewSection, _createBannerAdView() Action triggered.");
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

  // void _loadBanner() { _loadISAd(); }

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