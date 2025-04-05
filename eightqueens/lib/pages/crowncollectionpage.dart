import 'dart:io';
import 'package:eightqueens/parameters/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../parameters/ads.dart' as ads;
import '../parameters/themedata.dart';
import '../apinetisolates/apiprofilehandlerisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/deviceinfoplus.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/messagedialogs.dart';

class CrownCollectionPage extends StatefulWidget {

  final Widget wCrown;
  final DioProfileHandlerIsolate dphi;
  final AutoRegLocal arl;
  final ListsLocalStorage lls;
  final int iInterval;
  final Future<void> Function() refreshParent;

  const CrownCollectionPage({Key? key, required this.wCrown, required this.dphi, required this.arl, required this.lls, required this.iInterval, required this.refreshParent}): super(key: key);

  @override
  _CrownCollectionPageState createState() => _CrownCollectionPageState();
}

class _CrownCollectionPageState extends State<CrownCollectionPage> with ImpressionDataListener, IronSourceInitializationListener, LevelPlayInitListener {

  final int maxFailedLoadAttempts = 3;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  final LevelPlayRewardedAdViewController _lpravController = LevelPlayRewardedAdViewController();

  int iUserCrown = 0;
  String sUserCrown = "";

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [ads.testDeviceAndroid, ads.testDeviceIOS, ads.testDeviceAndroid2, ads.testDeviceAndroid3]));
      _createRewardedAd();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _refreshCrown();
        if (GV.bFirstCrownCollectionMessage) {
          if (1 > widget.iInterval) {
            GV.bFirstCrownCollectionMessage = false;
            _showAdQuestion(context);
          } else {
            _showIntevalListsAdQuestion(context, widget.iInterval);
          }
        }
        await initIronSource();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _rewardedAd?.dispose();
  }

  _showRewardedAdMobOrIronSourceAd() {
    if (null != _rewardedAd) {
      _showRewardedAd();
    } else {
      _lpravController.doShowActionInChild();
    }
  }

  Future<void> _showAdQuestion(BuildContext context) async {
    if (context.mounted) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        await info2ButtonDialog(
          context,
          false,
          MainAxisAlignment.spaceBetween,
          "Crown Collection",
          "If you would like to collect crowns, please watch an ad. You will get 1 crown for 1 Ad and you will get surprises later for them.",
          "Later",
          "Collect crown",
          () {},
          () { _showRewardedAdMobOrIronSourceAd(); },
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        );
      }
    }
  }

  Future<void> _showIntevalListsAdQuestion(BuildContext context, int iInterval) async {
    if (context.mounted) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        String sInterval = (1 == iInterval) ? "Monthy" : (2 == iInterval) ? "Quarterly" : "Yearly";
        await info2ButtonDialog(
          context,
          false,
          MainAxisAlignment.spaceBetween,
          (1 == iInterval) ? "Monthy List" : (2 == iInterval) ? "Quarterly List" : "Crown Collection",
          "Would you like to be included in the " + sInterval + " Top List? Then watch an Ad.",
          "Later",
          "Inclusion",
          () { GV.bFirstIntervalCrownCollectionMessage = false; },
          () { _showRewardedAdMobOrIronSourceAd(); },
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        );
      }
    }
  }

  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

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
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) { _onUserEarnedReward(reward); });
    _rewardedAd = null;
  }

  Future<void> _onUserEarnedReward(RewardItem reward) async {
    debugPrint('User earned reward: ${reward.amount} ${reward.type}');
    _sendAdjustCrown();
    showRewardedTextDialog(context, 1);
  }

  bool _bSentAdjustCrown = false;

  Future<void> _sendAdjustCrown() async {
    if (!_bSentAdjustCrown) {
      _bSentAdjustCrown = true;
      Future.delayed(const Duration(seconds: 10), () { _bSentAdjustCrown = false; });
      List<dynamic> ldValue = await widget.dphi.callProfileHandlerRetryIsolateApi(4, widget.arl.getUserId(), "");
      int iCrown = await widget.arl.getUserCrown();
      try { iCrown = ldValue[2].credit; } catch (e) { debugPrint('_sendAdjustCrown(), $e'); }
      await widget.arl.saveUserCrownLocal(iCrown);
      _refreshCrown();
      widget.lls.clearLocalListDates();
      debugPrint('_sendAdjustCrown(), ldValue: $ldValue');
      debugPrint('_sendAdjustCrown(), ldValue[1], ldValue[2]: ${ldValue[1].toMap()}, ${ldValue[2].toMap()}');
    }
  }

  Future<void> _refreshCrown() async {
    iUserCrown = await widget.arl.getUserCrown();
    String sCrown = '$iUserCrown';
    setState(() {
      sUserCrown = sCrown;
    });
    widget.refreshParent();
  }

  // --- Ironsource
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
      IronSource.setFlutterVersion('3.29.0');
      IronSource.addImpressionDataListener(this);
      await enableDebug();
      await IronSource.shouldTrackNetworkState(true);

      // GDPR, CCPA, COPPA etc
      await setRegulationParams();

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
      List<AdFormat> legacyAdFormats = [AdFormat.REWARDED];
      final initRequest = LevelPlayInitRequest.builder(appKey)
        .withLegacyAdFormats(legacyAdFormats)
        .withUserId(ads.appUserId)
        .build();
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } on PlatformException catch (e) {
      debugPrint('$e');
    }
  }

  /// ImpressionData listener --------------------------------------------------///
  @override
  void onImpressionSuccess(ImpressionData? impressionData) {
    debugPrint('Impression Data: $impressionData');
  }

  /// LevelPlay Init listener --------------------------------------------------///
  @override
  void onInitFailed(LevelPlayInitError error) {
    debugPrint('onInitFailed ${error.errorMessage}');
  }

  /// Initialization listener --------------------------------------------------///
  @override
  void onInitializationComplete() {
    debugPrint('onInitializationComplete');
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    debugPrint('onInitSuccess isAdQualityEnabled=${configuration.isAdQualityEnabled}');
    _lpravController.doLoadActionInChild();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: blueTheme, child: Scaffold(
      appBar: AppBar(
        title: const Text("Crown Collection"),
        centerTitle: true,
        backgroundColor: blueTheme.colorScheme.inversePrimary,
      ),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 5), child: SizedBox(width: 28, height: 28, child: widget.wCrown)),
            const SizedBox(width: 8),
            Text((2 > iUserCrown) ? 'Crown: ' : 'Crowns: ', style: const TextStyle(fontSize: 22)),
            Text(sUserCrown, style: const TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.info, size: 24),
          label: const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text("Rules", style: TextStyle(fontSize: 20))),
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
          onPressed: () async { _showAdQuestion(context); },
        ),
        const SizedBox(height: 16),
        Expanded(flex: 4, child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                    child: Text("Collect crown", style: TextStyle(fontSize: 20))),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                  onPressed: _showRewardedAdMobOrIronSourceAd,
                ),
                LevelPlayRewardedAdSection(lpravController: _lpravController, onAdRewarded: _sendAdjustCrown),
            ])),
        )),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ])),
    ));
  }
}

void showRewardedTextDialog(BuildContext context, int iReward) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Rewarded"),
        content: Text((1 < iReward) ? "You got $iReward crowns." : "You got $iReward crown.", style: const TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK', style: TextStyle(fontSize: 18)))
        ],
      );
    });
}

void showRunTestFirstTextDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Run test first"),
        content: const Text("If you want to collect crowns, first run a test, for example on 2 threads.", style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK', style: TextStyle(fontSize: 18)))
        ],
      );
    });
}

class LevelPlayRewardedAdViewController {
  Future<void> Function()? _onLoad;
  Future<void> Function()? _onShow;

  void setOnLoad(Future<void> Function()? onLoad) { _onLoad = onLoad; }
  void setOnShow(Future<void> Function()? onShow) { _onShow = onShow; }

  Future<void> doLoadActionInChild() async {
    if (null != _onLoad) {
      await _onLoad!();
    }
  }

  Future<void> doShowActionInChild() async {
    if (null != _onShow) {
      await _onShow!();
    }
  }

}

/// LevelPlay Rewarded Video Section -------------------------------------------///
class LevelPlayRewardedAdSection extends StatefulWidget {
  final LevelPlayRewardedAdViewController lpravController;
  final Function onAdRewarded;

  const LevelPlayRewardedAdSection({Key? key, required this.lpravController, required this.onAdRewarded}) : super(key: key);

  @override
  _LevelPlayRewardedAdSectionState createState() =>
      _LevelPlayRewardedAdSectionState();
}

class _LevelPlayRewardedAdSectionState extends State<LevelPlayRewardedAdSection> with LevelPlayRewardedAdListener {
  LevelPlayRewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    widget.lpravController.setOnLoad(_createAndLoadRewardedAd);
    widget.lpravController.setOnShow(_showAd);
  }

  Future<void> _createAndLoadRewardedAd() async {
    _rewardedAd = LevelPlayRewardedAd(adUnitId: Platform.isAndroid ? 'wi4iag4j3ki34clu' : 'gpwcxtrm9gscd82n');

    _rewardedAd!.setListener(this);
    _loadAd();
  }

  void _loadAd() async {
    _rewardedAd?.loadAd();
  }

  Future<void> _showAd() async {
    if (_rewardedAd != null && await _rewardedAd!.isAdReady()) {
      _rewardedAd!.showAd(placementName: 'Achievements');
    } else {
      for (int i = 0; i < 5; i++) {
        if (0 == i) await Future.delayed(const Duration(seconds: 1));
        await Future.delayed(Duration(seconds: i));
        if (_rewardedAd != null && await _rewardedAd!.isAdReady()) {
          _rewardedAd!.showAd(placementName: 'Achievements');
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
    debugPrint("Rewarded Ad - onAdRewarded: $adInfo");
    widget.onAdRewarded();
    showRewardedTextDialog(context, 1);
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
