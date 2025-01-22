import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../parameters/ads.dart' as ads;
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/deviceinfoplus.dart';
import '../middleware/listslocalstorage.dart';
import '../middleware/customfloatingactionbuttonlocation.dart';

class ModelResultsPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  const ModelResultsPage({Key? key, required this.autoRegLocal, required this.lls}) : super(key: key);
  @override
  State<ModelResultsPage> createState() => _ModelResultsPageState();
}

class _ModelResultsPageState extends State<ModelResultsPage> with TickerProviderStateMixin, ImpressionDataListener, IronSourceInitializationListener, LevelPlayInitListener {
  late TabController _tabIntervalsController;
  late TabController _tabThreadsController;
  DioListModelResultsIsolate dlmri = DioListModelResultsIsolate();
  final int _iRefreshDelaySec = 300;
  bool _bRefreshDelayCompleted = true;
  List<List<String>> llsMRLoadDates = [["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                       ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]];
  bool _bHasMRLoadCompleted = false;
  List<List<List<ModelResultsAnswer>>> lllmraList = [
    [[], [], [], []],
    [[], [], [], []]
  ];
  List<List<ModelResultsDataTable>> llmrds = [
    [
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 1),
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 2),
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 4),
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 8),
    ],
    [
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 1),
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 2),
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 4),
      ModelResultsDataTable(listModelResultsAnswer: [], threads: 8),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _tabIntervalsController = TabController(length: 2, vsync: this);
    _tabIntervalsController.addListener(_handleTabSelection);
    _tabThreadsController = TabController(length: 4, vsync: this);
    _tabThreadsController.addListener(_handleTabSelection);
    if (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [ads.testDeviceAndroid, ads.testDeviceIOS, ads.testDeviceAndroid2, ads.testDeviceAndroid3]));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getLocalModelResultsDates();
      await _getListModelResults(0, 0);
      if (!kIsWeb) await initIronSource();
    });
  }

  @override
  void dispose() {
    _tabIntervalsController.removeListener(_handleTabSelection);
    _tabIntervalsController.dispose();
    _tabThreadsController.removeListener(_handleTabSelection);
    _tabThreadsController.dispose();
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }

  Future<void> _getLocalModelResultsDates() async {
    llsMRLoadDates = widget.lls.deserializeMRLoads(
      await widget.lls.fssModelResultsDates.get(), [["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                   ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
  }

  int _intervalTabToThreads(int iThreadTab) {
    switch (iThreadTab) {
      case 0: return 2; // Weekly
      case 1: return 3; // Monthly
      default: return 1;
    }
  }

  int _threadTabToThreads(int iThreadTab) {
    switch (iThreadTab) {
      case 0: return 1;
      case 1: return 2;
      case 2: return 4;
      case 3: return 8;
      default: return 1;
    }
  }

  bool _isTabLoadable() {
    DateTime dtLoadDatesUTC = (DateTime.tryParse(llsMRLoadDates[_tabIntervalsController.index][_tabThreadsController.index]) ?? DateTime.utc(1980,1,1,0,0,0)).toUtc();
    DateTime dtNow = DateTime.now().toUtc();
    Duration duDiff = dtNow.difference(dtLoadDatesUTC);
    bool isLoadable = (Duration(seconds: _iRefreshDelaySec - 1) < duDiff);
    return isLoadable;
  }

  void _handleTabSelection() => _refreshListModelResults();

  void _handleFloatingActionButtonPress() => _refreshListModelResults();

  void _refreshListModelResults()  => _getListModelResults(_tabIntervalsController.index, _tabThreadsController.index);

  Timer? _timer;
  Completer<void>? _completer;

  Future<void> _startOrResetRealoadTimer() async {
    _timer?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
    _completer = Completer<void>();
    _bRefreshDelayCompleted = false;

    _timer = Timer(Duration(seconds: _iRefreshDelaySec), () {
      if (mounted) {
        setState(() {
          _bRefreshDelayCompleted = true;
        });
      }
      if (_completer != null && !_completer!.isCompleted) {
        _completer!.complete();
      }
    });

    return _completer!.future;
  }

  Future<void> _getListModelResults(int iIntervalTab, int iThreadTab) async {

    _bHasMRLoadCompleted = false;

    List<List<List<ModelResultsAnswer>>> lllmraList0 = widget.lls.deserializeLllmList(await widget.lls.lslModelResults.get(), [[[], [], [], []],[[], [], [], []]]);
    if (mounted) {
      setState(() {
        lllmraList = lllmraList0;
      });
    }

    if (_isTabLoadable()) {
      List<dynamic> ldValue = await dlmri.callListModelResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), _intervalTabToThreads(iIntervalTab), _threadTabToThreads(iThreadTab), 100);
      bool success = ldValue[0];
      if (success) {
        Map<String, List<ModelResultsAnswer>> answer = ldValue[1];
        List<ModelResultsAnswer> list = answer['list'] ?? [];
        debugPrint("pages, modelresultspage, getListModelResults() list: ${list.map((e) => e.toMap()).toList()}");
        if (mounted) {
          setState(() {
            lllmraList[iIntervalTab][iThreadTab] = list;
          });
        }
        List<String> lsValue = widget.lls.serializeLllmraList(lllmraList);
        widget.lls.lslModelResults.set(lsValue);
      }
    }

    llsMRLoadDates[iIntervalTab][iThreadTab] = DateTime.now().toUtc().toIso8601String();
    List<String> lsValue = widget.lls.serializeMRLoadDates(llsMRLoadDates);
    widget.lls.fssModelResultsDates.set(lsValue);
  
    _startOrResetRealoadTimer();
    _bHasMRLoadCompleted = true;

  }

  Widget scrollableDataTable(int iIntervalTab, int iThreadTab) {
    ModelResultsDataTable mrdt = ModelResultsDataTable(
        listModelResultsAnswer: lllmraList[iIntervalTab][iThreadTab],
        threads: _threadTabToThreads(iThreadTab));
    llmrds[iIntervalTab][iThreadTab] = mrdt;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12.0,
          columns: kTableColumns,
          rows: llmrds[iIntervalTab][iThreadTab].getRows(),
        ),
      ),
    );
  }

  final ThemeData blueTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: blueTheme, // ThemeData.light(), // Apply light theme
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: const Padding(
                padding: EdgeInsets.only(top: 12.0), child: Text("Model Stat")),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: TabBar(
                padding: const EdgeInsets.only(bottom: 3.0),
                controller: _tabIntervalsController,
                isScrollable: true,
                tabs: const <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                    child: Text("Weekly", style: TextStyle(fontSize: 18.4), maxLines: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                    child: Text("Monthly", style: TextStyle(fontSize: 18.4), maxLines: 1),
                  ),
                ],
              ),
            ),
          ),
          body: Column(children: [
            Expanded(child: TabBarView(
              controller: _tabIntervalsController,
              children: <Widget>[
                DefaultTabController(
                  length: 4,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabThreadsController,
                        isScrollable: true,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("1 Thread", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("2 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("4 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("8 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabThreadsController,
                          children: <Widget>[
                            scrollableDataTable(0, 0),
                            scrollableDataTable(0, 1),
                            scrollableDataTable(0, 2),
                            scrollableDataTable(0, 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 4,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabThreadsController,
                        isScrollable: true,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("1 Thread", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("2 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("4 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("8 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabThreadsController,
                          children: <Widget>[
                            scrollableDataTable(1, 0),
                            scrollableDataTable(1, 1),
                            scrollableDataTable(1, 2),
                            scrollableDataTable(1, 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
            (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
            ? (_isAdMobLoaded)
              ? _getAdWidget()
              : SizedBox(width: double.infinity, height: 50, child: LevelPlayBannerAdViewSection(lpbavController: _lpbavController, fGetIsAdMobLoaded: () => _isAdMobLoaded))
            : const SizedBox.shrink(),
          ]),
          floatingActionButton: (_bRefreshDelayCompleted && _bHasMRLoadCompleted && _isTabLoadable())
            ? ElevatedButton(onPressed: _handleFloatingActionButtonPress, child: const Icon(Icons.refresh_rounded, size: 36))
            : null,
          floatingActionButtonLocation: CustomFloatingActionButtonLocation(0.0, -104.0),
        ),
      ),
    );
  }

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

  final LevelPlayBannerAdViewController _lpbavController = LevelPlayBannerAdViewController();

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

const List<DataColumn> kTableColumns = <DataColumn>[
  DataColumn(
    label: Padding(padding: EdgeInsets.only(right: 6), child: Text('No.', style: TextStyle(fontSize: 17.6))),
    numeric: true,
    tooltip: "Position in the list",
  ),
  DataColumn(
    label: Text('Model name', style: TextStyle(fontSize: 17.6)),
  ),
  DataColumn(
    label: Text('Runs', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Number of measurements",
  ),
  DataColumn(
    label: Text('Best', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Best results in second",
  ),
  DataColumn(
    label: Text('Average', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Average results in second",
  ),
  DataColumn(
    label: Text('Worst', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Worst results in second",
  ),
];

class _ModelResultsRow {
  _ModelResultsRow(this.modelName, this.runs, this.best, this.average, this.worst);
  final String modelName;
  final int runs;
  final double best;
  final double average;
  final double worst;
}

class ModelResultsDataTable {
  final List<ModelResultsAnswer> listModelResultsAnswer;
  final int threads;

  ModelResultsDataTable({required this.listModelResultsAnswer, required this.threads});

  _ModelResultsRow _convertModelResultsElementToDataTableRow(List<ModelResultsAnswer> lmra0, int row0) {
    _ModelResultsRow mrr = _ModelResultsRow(
      lmra0[row0].modelName,
      lmra0[row0].runCount,
      lmra0[row0].bestResult / 1000,
      lmra0[row0].averageResult / 1000,
      lmra0[row0].worstResult / 1000,
    );
    return mrr;
  }

  List<DataRow> getRows() {
    final int nRows = listModelResultsAnswer.length;
    final List<DataRow> ldr = [];
    for (int row = 0; row < nRows; row++) {
      _ModelResultsRow mrr = _convertModelResultsElementToDataTableRow(listModelResultsAnswer, row);
      ldr.add(
        DataRow(cells: [
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text('${row + 1}', style: const TextStyle(fontSize: 17)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text(mrr.modelName, style: const TextStyle(fontSize: 17)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 12), child: Text('${mrr.runs}', style: const TextStyle(fontSize: 17)))),
          DataCell(Text(mrr.best.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
          DataCell(Text(mrr.average.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
          DataCell(Text(mrr.worst.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
        ]));
    }
    return ldr;
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
