import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../parameters/globals.dart';
import 'globalwidgets.dart';
import '../pages/homepage.dart';

class GVW {
  static const double dWebWidgetHeaderHeight = 56;
  static Uri uriGooglePlayApp = Uri.parse(
      "https://play.app.goo.gl/?link=https://play.google.com/store/apps/details?id=com.benchmark.eightqueens");
  static Uri uriAppStoreApp = Uri.parse("https://apps.apple.com/app/id1621191695");
  static Uri uriWindowsApp = Uri.parse("https://is.gd/8Queens");
  static Uri uriSnapStoreApp = Uri.parse("https://snapcraft.io/eightqueens");
}

class WebPageWidget extends StatefulWidget {
  const WebPageWidget({Key? key}) : super(key: key);
  @override
  _WebPageWidgetState createState() => _WebPageWidgetState();
}

class _WebPageWidgetState extends State<WebPageWidget> {
  double expansionPanelHeight = 209;
  final double minHomePageWidth = 286;
  final double minHomePageHeight = 320;
  GlobalKey expansionPanelKey = GlobalKey();
  bool bIsExpanded = true;
  final _expansionPanelBodyScrollController = ScrollController();

  bool _onNotification(SizeChangedLayoutNotification notification) {
    _asyncOnNotification();
    return false;
  }

  Future<void> _asyncOnNotification() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      expansionPanelHeight = expansionPanelKey.currentContext?.size?.height ?? 0;
    });
  }

  Future<void> _launchAndroidUrl() async {
    if (await canLaunchUrl(GVW.uriGooglePlayApp)) {
      await launchUrl(GVW.uriGooglePlayApp);
    } else {
      debugPrint('Could not launch ${GVW.uriGooglePlayApp}');
    }
  }

  Future<void> _launchiOSmacOSUrl() async {
    if (await canLaunchUrl(GVW.uriAppStoreApp)) {
      await launchUrl(GVW.uriAppStoreApp);
    } else {
      debugPrint('Could not launch ${GVW.uriAppStoreApp}');
    }
  }

  Future<void> _launchWindowsUrl() async {
    if (await canLaunchUrl(GVW.uriWindowsApp)) {
      await launchUrl(GVW.uriWindowsApp);
    } else {
      debugPrint('Could not launch ${GVW.uriAppStoreApp}');
    }
  }

  Future<void> _launchLinuxUrl() async {
    if (await canLaunchUrl(GVW.uriSnapStoreApp)) {
      await launchUrl(GVW.uriSnapStoreApp);
    } else {
      debugPrint('Could not launch ${GVW.uriSnapStoreApp}');
    }
  }

  @override
  void initState() {
    _asyncOnNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          left: 0,
          top: 0,
          child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Theme(
                  data: Theme.of(context).copyWith(
                      hoverColor: Colors.blue.shade200,
                      highlightColor: Colors.blue.shade300,
                      splashColor: Colors.blue.shade400),
                  child: NotificationListener<SizeChangedLayoutNotification>(
                      key: expansionPanelKey,
                      onNotification: _onNotification,
                      child: SizeChangedLayoutNotifier(
                          child: ExpansionPanelList(
                        expandedHeaderPadding: EdgeInsets.zero,
                        expansionCallback: ((panelIndex, isExpanded) {
                          setState(() {
                            bIsExpanded = isExpanded;
                          });
                        }),
                        children: [
                          ExpansionPanel(
                              headerBuilder: (context, isExpanded) => Container(
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: const Padding(
                                      padding: EdgeInsets.only(left: 62),
                                      child: Text("8 Queens Web",
                                          style:
                                              TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
                              isExpanded: bIsExpanded,
                              canTapOnHeader: true,
                              backgroundColor: Colors.blue.shade100,
                              body: Container(
                                  color: Colors.blue.shade50,
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width,
                                      maxHeight: max(
                                          (MediaQuery.of(context).size.height -
                                                  GVW.dWebWidgetHeaderHeight) /
                                              2,
                                          0)),
                                  child: Scrollbar(
                                      controller: _expansionPanelBodyScrollController,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                          controller: _expansionPanelBodyScrollController,
                                          physics: const BouncingScrollPhysics(),
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment: Alignment.center,
                                                  child: const Padding(
                                                      padding: EdgeInsets.only(top: 12, bottom: 24),
                                                      child: Text("Performance Benchmark",
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold)))),
                                              Wrap(
                                                children: [
                                                  RoundedContainer(
                                                      width: 208,
                                                      margin: const EdgeInsets.all(8),
                                                      padding:
                                                          const EdgeInsets.only(top: 8, bottom: 4),
                                                      constraints:
                                                          const BoxConstraints(maxWidth: 260),
                                                      child: Column(children: [
                                                        const Padding(
                                                            padding:
                                                                EdgeInsets.only(top: 4, bottom: 4),
                                                            child: Text("Android:",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold))),
                                                        InkWell(
                                                            onTap: _launchAndroidUrl,
                                                            child:
                                                                // ignore: avoid_unnecessary_containers
                                                                SizedBox(
                                                                    child: Image.asset(
                                                                        'assets/images/google-play-badge.png',
                                                                        width: 200)))
                                                      ])),
                                                  RoundedContainer(
                                                      width: 208,
                                                      margin: const EdgeInsets.all(8),
                                                      padding: const EdgeInsets.only(bottom: 12),
                                                      constraints:
                                                          const BoxConstraints(maxWidth: 260),
                                                      child: Column(children: [
                                                        const Padding(
                                                            padding:
                                                                EdgeInsets.only(top: 12, bottom: 14),
                                                            child: Text("iOS, macOS:",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold))),
                                                        InkWell(
                                                            onTap: _launchiOSmacOSUrl,
                                                            child:
                                                                // ignore: avoid_unnecessary_containers
                                                                Container(
                                                                    child: Image.asset(
                                                                        'assets/images/app_store_badge.png',
                                                                        width: 176)))
                                                      ])),
                                                  RoundedContainer(
                                                      width: 208,
                                                      margin: const EdgeInsets.all(8),
                                                      padding: const EdgeInsets.only(bottom: 13),
                                                      constraints:
                                                          const BoxConstraints(maxWidth: 260),
                                                      child: Column(children: [
                                                        const Padding(
                                                            padding:
                                                                EdgeInsets.only(top: 12, bottom: 16),
                                                            child: Text("Windows:",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold))),
                                                        InkWell(
                                                            onTap: _launchWindowsUrl,
                                                            child:
                                                                // ignore: avoid_unnecessary_containers
                                                                Container(
                                                                    child: Image.asset(
                                                                        'assets/images/get-it-on-windows-badge-black.png',
                                                                        width: 176)))
                                                      ])),
                                                  RoundedContainer(
                                                      width: 208,
                                                      margin: const EdgeInsets.all(8),
                                                      padding:
                                                          const EdgeInsets.only(top: 8, bottom: 13),
                                                      constraints:
                                                          const BoxConstraints(maxWidth: 260),
                                                      child: Column(children: [
                                                        const Padding(
                                                            padding:
                                                                EdgeInsets.only(top: 4, bottom: 14),
                                                            child: Text("Linux:",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold))),
                                                        InkWell(
                                                            onTap: _launchLinuxUrl,
                                                            child:
                                                                // ignore: avoid_unnecessary_containers
                                                                SizedBox(
                                                                    child: Image.asset(
                                                                        'assets/images/snap-store-black.png',
                                                                        width: 180)))
                                                      ])),
                                                ],
                                              ),
                                              const SizedBox(height: 16)
                                            ],
                                          )))))
                        ],
                      )))))),
      Positioned(
          left: 0,
          top: expansionPanelHeight,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                          constraints: BoxConstraints(
                              minWidth: minHomePageWidth,
                              minHeight: minHomePageHeight,
                              maxWidth: max(MediaQuery.of(context).size.width, minHomePageWidth),
                              maxHeight: max(
                                  MediaQuery.of(context).size.height - expansionPanelHeight,
                                  minHomePageHeight)),
                          child: HomePage(title: GV.sTitle, headerSize: expansionPanelHeight))
                    ],
                  ))))
    ]);
  }
}
