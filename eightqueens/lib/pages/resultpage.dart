import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'admobtest/admobtestpage.dart';
import '../parameters/globals.dart';
import '../parameters/global_device_info.dart';
import '../parameters/ads.dart';
import 'contributionpage.dart';
import '../widgets/globalwidgets.dart';
import '../widgets/rankrangelist.dart';

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

class ResultPageState extends State<ResultPage> {

  _openAdModTestPage() => () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdMobTestPage()));

  /*final List<String> lsRank = [
    'Very slow',
    'Slow',
    'Slower than average',
    'Average',
    'Better than Average',
    'Fast',
    'Very fast',
    'Crazy fast',
    'Light speed'
  ];*/
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
          ListView(physics: const BouncingScrollPhysics(), children: <Widget>[
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
                          onPressed: _openContributionPage(),
                      )
                      : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                      (GV.bDev && !kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
                      ? ElevatedButton(
                          child: const Padding(
                              padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                              child: Text("Start Ad Test", style: TextStyle(fontSize: 20))),
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                          onPressed: _openAdModTestPage(),
                      )
                      : const SizedBox.shrink(),
                      const SizedBox(height: 10),
                      const RankRangeListTitle(),
                      RankRangeList(),
                      const SizedBox(height: 64), // ad banner place
                    ]))
          ]),
          (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) ? _getAdWidget() : const SizedBox.shrink(),
        ]));
  }

  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;
  late Orientation _currentOrientation;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion)) {
      MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [testDeviceAndroid, testDeviceIOS, testDeviceAndroid2, testDeviceAndroid3]));
    }
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
      _isLoaded = false;
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
            _isLoaded = true;
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
            _isLoaded) {
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

  _openContributionPage() => () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionPage()));

}
