import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as _foundation;
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../parameters/globals.dart';
import '../parameters/ads.dart' as ads;
import '../middleware/deviceinfoplus.dart';
import '../widgets/globalwidgets.dart';
import 'admobtest/admobtestpage.dart';
import 'ironsourcetest/ironsourcetestpage.dart';
import 'contributionpage.dart';

class InfoPage extends StatefulWidget {

  final DataPackageInfo dpi;

  const InfoPage({Key? key, required this.dpi}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with ImpressionDataListener, IronSourceInitializationListener, LevelPlayInitListener {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String buildMode = "";
  final String platform = 'Flutter 3.27.3';
  final String platformPrerelease = '-';
  final String platformChannel = 'stable';
  final String author = 'Jack Davis';

  final LevelPlayBannerAdViewController _lpbavController = LevelPlayBannerAdViewController();

  @override
  initState() {
    loadPackageInfo();
    if (!_foundation.kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [ads.testDeviceAndroid, ads.testDeviceIOS, ads.testDeviceAndroid2, ads.testDeviceAndroid3]));
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!_foundation.kIsWeb) await initIronSource();
      });
    }
    super.initState();
  }

  void loadPackageInfo() {
    appName = widget.dpi.appName;
    packageName = widget.dpi.packageName;
    version = widget.dpi.version;
    buildNumber = widget.dpi.buildNumber;
    buildMode = widget.dpi.buildMode;
  }

  void switchDev() {
    setState(() {
      GV.bDev = !GV.bDev;
    });
  }

  @override
  Widget build(BuildContext context) {

    void _openContributionPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionPage()));

    void _openAdModTestPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdMobTestPage()));

    void _openIronSourceTestPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const IronSourceTestPage()));

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
              const Padding(padding: EdgeInsets.only(right: 18), child: Text("Info")),
              const SizedBox(width: 36)
            ]))
          ]),
        ),
        backgroundColor: Colors.blue.shade50,
        body: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[ ListView(physics: const BouncingScrollPhysics(), children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  RoundedContainer(
                      width: double.infinity,
                      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                      margin: const EdgeInsets.all(0.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(bottom: 5.0),
                                    child: Center(
                                        child: Text(
                                      '8 Queens: Instructions',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 22),
                                    ))),
                                Padding(
                                  padding: EdgeInsets.only(top: 22, bottom: 7, left: 15, right: 15),
                                  child: Text(
                                      '8 Queens Performance Benchmark Test '
                                      'And Meter App is a Visual CPU Performance App. '
                                      "You can meter your smart mobile device's speed "
                                      'with the Eight Queens Chess Problem solving.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 6, bottom: 0, left: 15, right: 15),
                                  child: Text('The App runs on 6 platforms:',
                                      textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text('1. Android.',
                                      textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      '2.\u{00A0}iOS: iPhones, iPads, '
                                      'on M1, M2, M3, M4 Macintosh desktops, '
                                      'and on M1, M2, M3, M4 MacBook notebooks.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text('3. Windows desktop.',
                                      textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text('4. MacOS desktop.',
                                      textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text('5. Linux desktop.',
                                      textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text('6. Web version on any platform.',
                                      textAlign: TextAlign.left, style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Center(
                                        child: Text(
                                      '8 Queens Problem:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20, color: Color(0xFF0000A0)),
                                    ))),
                                Padding(
                                  padding: EdgeInsets.only(top: 16, bottom: 7, left: 15, right: 15),
                                  child: Text(
                                      'The App finds the 92 right solutions from the 16 million '
                                      "variations where the eight queens don't threaten "
                                      'each other on the 8x8 chessboard.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17, color: Color(0xFF0000A0))),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 22, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      'Finding the 92 right solutions with an '
                                      'up-to-date, decent smart mobile phone lasts '
                                      'less than a half minute.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      'If you would like to see the right solutions, '
                                      "please choose '1 sec' or '5 sec' wait at 'No Wait'.",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      "If you would like to check your smart phone's multithreaded "
                                      "CPU performance please, choose 2 or 4 or '8 Threads'.",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      'The App uses brute force method to find the right '
                                      'solutions. Since this App is a Performance Benchmark, '
                                      'it was not intended to use an algorithm faster than the '
                                      'brute force method. Any more efficient algorithm would run '
                                      'too fast on a flagship device.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      'Not all iterations are displayed. Only about every 5000th '
                                      'iteration is displayed. Therefore, outputing to the display '
                                      'slows down max. 10% on the algorithm.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      'The Web version is not suitable for comparative speed '
                                      'testing, so download the App for the platform. The Web '
                                      'version runs at different speeds in different browsers. '
                                      "For example, in Firefox it's extremely slow and Chrome can "
                                      'produce surprising results even on slow devices in '
                                      'multi-threaded mode.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 15),
                                  child: Text(
                                      'For higher browser compatibility, the rendering type of the '
                                      'Web version can be set on the Config page to Auto, HTML or '
                                      'CanvasKit. To open the Config page, tap the cogwheel icon in '
                                      'the top right corner. HTML rendering is compatible with more '
                                      'browsers than CanvasKit, while the latter rendering '
                                      'results in a faster runtime.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                )
                              ]))),
                  const SizedBox(height: 20),
                  GestureDetector(
                          onLongPress: switchDev,
                          child: RoundedContainer(
                      width: double.infinity,
                      margin: const EdgeInsets.all(0.0),
                      padding: const EdgeInsets.all(8.0),
                      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                      boxshadow: GV.bDev,
                      child: Container(
                          padding: const EdgeInsets.only(top: 30, bottom: 30),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  'Application Information',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Application name: ',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  appName,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold),
                                ),
                                ("" != packageName)
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text(
                                          'Package name:',
                                          style: TextStyle(fontSize: 18),
                                        ))
                                    : const SizedBox.shrink(),
                                ("" != packageName)
                                    ? FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          packageName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context).primaryColorDark,
                                              fontWeight: FontWeight.bold),
                                        ))
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 5),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Version number: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    version,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Build number: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    buildNumber,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Build mode: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    buildMode,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Platform: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    platform,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Prerelease: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    platformPrerelease,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Channel: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    platformChannel,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                Row(children: <Widget>[
                                  const Expanded(child: SizedBox.shrink()),
                                  const Text(
                                    'Author: ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    author,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                              ])))),
                  const SizedBox(height: 20),
                  (!_foundation.kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
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
                  (GV.bDev && !_foundation.kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
                  ? Padding(padding: const EdgeInsets.only(top: 20), child: ElevatedButton(
                      child: const Padding(
                          padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                          child: Text("AdMob Test", style: TextStyle(fontSize: 20))),
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                      onPressed: _openAdModTestPage,
                  ))
                  : const SizedBox.shrink(),
                  (GV.bDev && !_foundation.kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
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
                  const SizedBox(height: 64), // ad banner place
                ]),
              ]))
          ]),
          (!_foundation.kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    if (!_foundation.kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) _loadAd();
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
      await IronSource.setUserId(ads.appUserId);

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

class DataPackageInfo {
  String appName, packageName, version, buildNumber, buildMode;
  DataPackageInfo(
      {required this.appName,
      required this.packageName,
      required this.version,
      required this.buildNumber,
      required this.buildMode});
  factory DataPackageInfo.fromList(Map<String, dynamic> ldInput) {
    return DataPackageInfo(
        appName: ldInput['appName'],
        packageName: ldInput['packageName'],
        version: ldInput['version'],
        buildNumber: ldInput['buildNumber'],
        buildMode: ldInput['buildMode']);
  }
}
