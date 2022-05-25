import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as _foundation;
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/globalwidgets.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  DataPackageInfo dpi =
      DataPackageInfo(appName: "", packageName: "", version: "", buildNumber: "", buildMode: "");
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String buildMode = "";
  final String platform = 'Flutter 3.0.1';
  final String platformPrerelease = '-';
  final String platformChannel = 'stable';
  final String author = 'Jack Davis';

  @override
  initState() {
    loadPackageInfo();
    super.initState();
  }

  Future<void> loadPackageInfo() async {
    dpi = await loadLocalPackageInfo();
    setState(() {
      appName = dpi.appName;
      packageName = dpi.packageName;
      version = dpi.version;
      buildNumber = dpi.buildNumber;
      buildMode = dpi.buildMode;
    });
  }

  Future<DataPackageInfo> loadLocalPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> msdPI = <String, dynamic>{};
    msdPI['appName'] = packageInfo.appName;
    msdPI['packageName'] = packageInfo.packageName;
    msdPI['version'] = packageInfo.version;
    msdPI['buildNumber'] = packageInfo.buildNumber;
    msdPI['buildMode'] = (_foundation.kReleaseMode)
        ? "Release"
        : (_foundation.kProfileMode)
            ? "Profile"
            : (_foundation.kDebugMode)
                ? "Debug"
                : "Unknown";
    return DataPackageInfo.fromList(msdPI);
  }

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
              const Padding(padding: EdgeInsets.only(right: 18), child: Text("Info"))
            ]))
          ]),
        ),
        backgroundColor: Colors.blue.shade50,
        body: ListView(physics: const BouncingScrollPhysics(), children: <Widget>[
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
                              child: Column(children: const <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                      '8 Queens: Instructions',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 22),
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(top: 22, bottom: 7, left: 15, right: 15),
                                  child: Text(
                                      '8 Queens Performance Benchmark Test '
                                      'And Meter App is a Visual CPU Performance App. '
                                      "You can meter your smart mobile device's speed "
                                      'with the Eight Queens Chess Problem solving. '
                                      'The App runs on Android, on iPhones, on iPads, '
                                      'on latest M1 Macintosh desktops, '
                                      'and on M1 MacBook notebooks.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Text(
                                      '8 Queens Problem:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20, color: Color(0xFF0000A0)),
                                    )),
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
                                  padding: EdgeInsets.only(top: 22, bottom: 7, left: 15, right: 15),
                                  child: Text(
                                      'Finding the 92 right solutions with an '
                                      'up-to-date, decent smart mobile phone lasts '
                                      'less than a half minute.\n'
                                      'If you would like to see the right solutions, '
                                      "please choose '1 sec' or '5 sec' wait at 'No Wait'.\n"
                                      "If you would like to check your smart phone's multithreaded "
                                      "CPU performance please, choose 2 or '4 Threads'.\n\n"
                                      'The App uses brute force method to find the right '
                                      'solutions. Since this App is a Performace Benchmark, '
                                      'it was not intended to use an algorithm faster than the '
                                      'brute force method. Any more efficient algorithm would run '
                                      'too fast on a flagship device.\n\n'
                                      'Not all iterations are displayed. Only about every 5000th '
                                      'iteration is displayed. Therefore, outputing to the display '
                                      'slows down max. 10% on the algorithm.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 17)),
                                )
                              ]))),
                      const SizedBox(height: 20),
                      RoundedContainer(
                          width: double.infinity,
                          margin: const EdgeInsets.all(0.0),
                          padding: const EdgeInsets.all(8.0),
                          constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
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
                                  ]))),
                      const SizedBox(height: 20),
                    ]),
                  ]))
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
