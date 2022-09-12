import 'package:flutter/material.dart';
import '../widgets/globalwidgets.dart';

class ResultPage extends StatefulWidget {
  final int speed;
  final Color color;
  final Color backgroundcolor;
  final int threads;
  final Duration elapsed;
  const ResultPage(
      {Key? key,
      required this.speed,
      required this.color,
      required this.backgroundcolor,
      required this.threads,
      required this.elapsed})
      : super(key: key);
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final List<String> lsRank = [
    'Very slow',
    'Slow',
    'Slower than average',
    'Average',
    'Better than Average',
    'Fast',
    'Very fast',
    'Crazy fast',
    'Light speed'
  ];
  String _sRank = "";
  @override
  Widget build(BuildContext context) {
    _sRank = lsRank[widget.speed - 1];
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
              const Padding(padding: EdgeInsets.only(right: 18), child: Text("Result"))
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
                                const Padding(
                                    padding: EdgeInsets.only(top: 22, bottom: 7, left: 15, right: 15),
                                    child: Text('Threads, Time Elapsed',
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
                                      Text(
                                          widget.threads.toString() +
                                              "t: " +
                                              widget.elapsed.toString().substring(
                                                  0, widget.elapsed.toString().indexOf('.') + 4),
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: widget.color,
                                              backgroundColor: widget.backgroundcolor)),
                                      const Divider(thickness: 2, color: Colors.white),
                                      Text(_sRank,
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: widget.color,
                                              backgroundColor: widget.backgroundcolor))
                                    ])))
                              ]))),
                      const SizedBox(height: 20),
                    ]),
                  ]))
        ]));
  }
}
