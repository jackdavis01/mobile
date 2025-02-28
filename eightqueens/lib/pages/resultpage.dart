import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'admobtest/admobtestpage.dart';
import 'ironsourcetest/ironsourcetestpage.dart';
import '../parameters/globals.dart';
import '../middleware/deviceinfoplus.dart';
import '../widgets/adhandler.dart';
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

  void _openContributionPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const ContributionPage()));

  void _openAdModTestPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdMobTestPage()));

  void _openIronSourceTestPage() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => const IronSourceTestPage()));

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 5000));
      if (mounted) scrollController.animateTo(420, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
    });
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
          const AdBanner(),
        ]));
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
