import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as _foundation;
import '../parameters/globals.dart';
import '../middleware/deviceinfoplus.dart';
import '../middleware/adhandler.dart';
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

class _InfoPageState extends State<InfoPage> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String buildMode = "";
  final String platform = 'Flutter 3.29.0';
  final String platformPrerelease = '-';
  final String platformChannel = 'stable';
  final String author = 'Jack Davis';

  @override
  initState() {
    loadPackageInfo();
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
          const AdBanner(),
    ]));
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
