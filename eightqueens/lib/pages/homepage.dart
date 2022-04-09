import 'dart:isolate';
import 'dart:math';
import "package:async/async.dart";
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../isolates/findsolutions.dart';
import '../isolates/multithreadedfindsolutions.dart';
import '../widgets/boxwidgets.dart';
import 'infopage.dart';
import 'resultpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FindSolutions findSolution = FindSolutions();
  final MultiTreadedFindSolution multiThreadedFindSolution = MultiTreadedFindSolution();
  bool _bStart = false;
  bool _bPaused = false;
  int _stepCounter = 0;
  int _solutionCounter = 0;
  bool _bCheckQueensNoAttack = false;
  int _waitms = 0;
  int _iddThreads = 1;
  int _iThreadsStarted = 1;
  DateTime _dtStart = DateTime.now();
  DateTime _dtProgress = DateTime.now();
  Duration _dElapsed = const Duration(days: 0);
  Duration _dFirstFrame = const Duration(days: 0);
  int _iFrameCount = 0;
  int _iFPS = 0;
  List<int> _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
  final List<int> liMultiStepCounter = <int>[];
  final List<int> liMultiSolutionCounter = <int>[];
  int _n24Threads = 2;
  final List<bool> _lbStart = <bool>[];
  String _ddWaitValue = 'No Wait';
  final List<String> _lsWaitItems = ['No Wait', '1 sec', '5 sec'];
  String _ddMultiThreadValue = '1 Thread';
  final List<String> _lsMultiThreadItems = ['1 Thread', '2 Threads', '4 Threads'];
  final String assetQueenName = 'assets/images/chess_queen_blue.svg';
  double _dFontSizeScalePortrait = 1;
  double _dFontSizeScaleLandscape = 1;
  final Color cNumbers = Colors.blue.shade800;
  Widget wQueenImage = const SizedBox.shrink();
  int _iPort = 0;
  late SendPort _sendPort;
  late StreamQueue<dynamic> _sqdEvents;
  final List<SendPort> _lsendPort = <SendPort>[];
  final List<StreamQueue<dynamic>> _lsqdEvents = <StreamQueue<dynamic>>[];

  final Color cVeryFast = Colors.lightGreen.shade100;
  int iSpeed = 0;
  final int imsLimitVeryFast1 = 18000;
  final int imsLimitVeryFast2 = 13500;
  final int imsLimitVeryFast4 = 10000;
  final Color cFast =
      Color.alphaBlend(Colors.yellow.shade100.withAlpha(255 ~/ 3), Colors.lightGreen.shade100);
  final int imsLimitFast1 = 22000;
  final int imsLimitFast2 = 16500;
  final int imsLimitFast4 = 12000;
  final Color cBetterThanAverage =
      Color.alphaBlend(Colors.yellow.shade100.withAlpha(255 ~/ 3 * 2), Colors.lightGreen.shade100);
  final int imsLimitBetterThanAverage1 = 27000;
  final int imsLimitBetterThanAverage2 = 20000;
  final int imsLimitBetterThanAverage4 = 14000;
  final Color cAverage = Colors.yellow.shade100;
  final int imsLimitAverage1 = 33000;
  final int imsLimitAverage2 = 25000;
  final int imsLimitAverage4 = 17000;
  final Color cSlowerThanAverage =
      Color.alphaBlend(Colors.yellow.shade100.withAlpha(255 ~/ 2), Colors.orange.shade100);
  final int imsLimitSlowerThanAverage1 = 64000;
  final int imsLimitSlowerThanAverage2 = 40000;
  final int imsLimitSlowerThanAverage4 = 20000;
  final Color cSlow = Colors.orange.shade100;
  final int imsLimitSlow1 = 100000;
  final int imsLimitSlow2 = 60000;
  final int imsLimitSlow4 = 26000;
  final Color cVerySlow = Colors.red.shade100;

  @override
  initState() {
    super.initState();
    wQueenImage = SvgPicture.asset(assetQueenName, semanticsLabel: 'Queen :)');
  }

  Future<void> _startCounter() async {
    if (1 == _iddThreads) {
      _iThreadsStarted = 1;
      await _startCounterOneThreaded();
    } else if (2 == _iddThreads) {
      _iThreadsStarted = 2;
      _n24Threads = 2;
      await _startCounterMultiThreaded();
    } else if (4 == _iddThreads) {
      _iThreadsStarted = 4;
      _n24Threads = 4;
      await _startCounterMultiThreaded();
    }
  }

  Future<void> _startCounterOneThreaded() async {
    setState(() {
      _bStart = true;
      _bPaused = false;
      _stepCounter = 0;
      _solutionCounter = 0;
    });
    List<dynamic> ldSqdLd = await findSolution.startIsolateInBackground();
    _sendPort = ldSqdLd[0];
    _sqdEvents = ldSqdLd[1];
    _dtStart = DateTime.now();
    _dtProgress = DateTime.now();
    _dFirstFrame = const Duration(days: 0);
    _iFrameCount = 0;
    _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    do {
      await _frameDisplay();
      await Future.delayed(const Duration(milliseconds: 8));
    } while (_bStart);
    findSolution.stopIsolateInBackground();
    setState(() {});
  }

  Future<void> _startCounterMultiThreaded() async {
    for (int i = 0; i < _n24Threads; i++) {
      if (liMultiStepCounter.asMap().containsKey(i)) {
        liMultiStepCounter[i] = 0;
      } else {
        liMultiStepCounter.add(0);
      }
      if (liMultiSolutionCounter.asMap().containsKey(i)) {
        liMultiSolutionCounter[i] = 0;
      } else {
        liMultiSolutionCounter.add(0);
      }
      if (_lbStart.asMap().containsKey(i)) {
        _lbStart[i] = true;
      } else {
        _lbStart.add(true);
      }
    }
    setState(() {
      _bStart = true;
      _bPaused = false;
      _stepCounter = 0;
      _solutionCounter = 0;
    });
    _lsendPort.clear();
    _lsqdEvents.clear();
    List<dynamic> ldSqdLd =
        await multiThreadedFindSolution.startMultiIsolatesInBackground(_n24Threads);
    for (int i = 0; i < _n24Threads; i++) {
      _lsendPort.add(ldSqdLd[0][i]);
      _lsqdEvents.add(ldSqdLd[1][i]);
    }
    _dtStart = DateTime.now();
    _dtProgress = DateTime.now();
    _dFirstFrame = const Duration(days: 0);
    _iFrameCount = 0;
    _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    _iPort = 0;
    do {
      await _frameDisplayForMultiThreads();
      await Future.delayed(const Duration(milliseconds: 8));
    } while (_bStart);
    multiThreadedFindSolution.stopAllIsolatesInBackground();
    setState(() {});
  }

  void _stopCounter() {
    setState(() {
      _bStart = false;
    });
    if (1 == _iThreadsStarted) {
      findSolution.stopIsolateInBackground();
    } else {
      multiThreadedFindSolution.stopAllIsolatesInBackground();
    }
    setState(() {});
  }

  void _resetCounter() {
    setState(() {
      _bStart = false;
      _stepCounter = 0;
      _solutionCounter = 0;
      _dtStart = DateTime.now();
      _dtProgress = DateTime.now();
      _dElapsed = const Duration(days: 0);
      _dFirstFrame = const Duration(days: 0);
      _iFrameCount = 0;
      _iFPS = 0;
      _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    });
    setState(() {});
  }

  void _pauseCounter() {
    if (1 == _iThreadsStarted) {
      findSolution.pause();
    } else {
      multiThreadedFindSolution.pause();
    }
    setState(() {
      _bPaused = true;
    });
  }

  void _resumeCounter() {
    if (1 == _iThreadsStarted) {
      findSolution.resume();
    } else {
      multiThreadedFindSolution.resume();
    }
    setState(() {
      _bPaused = false;
    });
  }

  Future<void> _frameDisplay() async {
    _dtProgress = DateTime.now();
    _dElapsed = _dtProgress.difference(_dtStart);
    _sendPort.send(_waitms);
    try {
      var vLD = await _sqdEvents.next;
      if (vLD is List) {
        setState(() {
          _liPos = vLD[0];
          _stepCounter = vLD[1] + 1;
          _solutionCounter = vLD[2];
          _bCheckQueensNoAttack = vLD[3];
        });
      } else if (null == vLD) {
        _bStart = false;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    if (_bCheckQueensNoAttack) {
      if (0 != _waitms) {
        findSolution.pause();
        setState(() {});
        await Future.delayed(Duration(milliseconds: _waitms));
        findSolution.resume();
      }
    }
    setState(() {});
    await Future.delayed(Duration.zero);
  }

  Future<void> _frameDisplayForMultiThreads() async {
    //debugPrint(".");
    _dtProgress = DateTime.now();
    _dElapsed = _dtProgress.difference(_dtStart);
    _iPort++;
    if (_iPort >= _n24Threads) _iPort = 0;
    _lsendPort[_iPort].send([_waitms, _iFPS]);
    try {
      var vLD = await _lsqdEvents[_iPort].next;
      if (vLD is List) {
        liMultiStepCounter[_iPort] = vLD[1];
        liMultiSolutionCounter[_iPort] = vLD[2];
        int iSumMultiStepCounter = 0;
        int iSumMultiSolutionCounter = 0;
        for (int i = 0; i < _n24Threads; i++) {
          iSumMultiStepCounter += liMultiStepCounter[i] + 1;
          iSumMultiSolutionCounter += liMultiSolutionCounter[i];
        }
        setState(() {
          _liPos = vLD[0];
          _stepCounter = iSumMultiStepCounter;
          _solutionCounter = iSumMultiSolutionCounter;
          _bCheckQueensNoAttack = vLD[3];
        });
      } else if (null == vLD) {
        _lbStart[_iPort] = false;
        int iStart = 0;
        for (int i = 0; i < _n24Threads; i++) {
          if (_lbStart[i]) iStart++;
        }
        if (0 == iStart) _bStart = false;
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    if (_bCheckQueensNoAttack) {
      if (0 != _waitms) {
        multiThreadedFindSolution.pause();
        setState(() {});
        await Future.delayed(Duration(milliseconds: _waitms));
        multiThreadedFindSolution.resume();
      }
    }
    setState(() {});
    await Future.delayed(Duration.zero);
  }

  void onChangedDDWait(dynamic newValue) {
    int iWaitms = 0;
    _ddWaitValue = newValue as String;
    if (_lsWaitItems[0] == _ddWaitValue) {
      iWaitms = 0;
    } else if (_lsWaitItems[1] == _ddWaitValue) {
      iWaitms = 1000;
    } else if (_lsWaitItems[2] == _ddWaitValue) {
      iWaitms = 5000;
    }
    setState(() {
      _waitms = iWaitms;
    });
  }

  Widget wddWaitType(double dFontSizeScale0) {
    final List<DropdownMenuItem<dynamic>>? lddItems = _lsWaitItems.map((String items) {
      return DropdownMenuItem(
        value: items,
        child: Text(items, style: TextStyle(fontSize: 22 * dFontSizeScale0)),
      );
    }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton(
            items: lddItems,
            value: _ddWaitValue,
            itemHeight: 7 * dFontSizeScale0 + kMinInteractiveDimension,
            onChanged: onChangedDDWait),
        Tooltip(
            message:
                "If you want to see the right solutions for the 8 Queens problem choose '1 sec' or '5 sec' at 'No Wait'.",
            preferBelow: false,
            triggerMode: TooltipTriggerMode.tap,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(left: 60, right: 60),
            decoration:
                BoxDecoration(color: const Color(0xE04090FF), borderRadius: BorderRadius.circular(6)),
            textStyle: const TextStyle(color: Colors.white, fontSize: 20),
            showDuration: const Duration(seconds: 10),
            child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 4, left: 12, top: 4),
                child: Transform.scale(
                    scale: dFontSizeScale0 * 1.36,
                    child: const Icon(Icons.info_outline, color: Colors.blue))))
      ],
    );
  }

  Widget wDisplayNumbers(double dFontSizeScale0) {
    return Column(
      children: [
        Text('Combinations checked:', style: TextStyle(fontSize: 20 * dFontSizeScale0)),
        Text(
          '$_stepCounter',
          style: TextStyle(fontSize: 32 * dFontSizeScale0, color: cNumbers),
        ),
        Text('Right solutions:', style: TextStyle(fontSize: 20 * dFontSizeScale0)),
        Text(
          '$_solutionCounter',
          style: TextStyle(fontSize: 32 * dFontSizeScale0, color: cNumbers),
        ),
        Text('Time elapsed:', style: TextStyle(fontSize: 20 * dFontSizeScale0)),
      ],
    );
  }

  void onChangedDDMultiThread(dynamic newValue) {
    int iddThreads = 1;
    _ddMultiThreadValue = newValue as String;
    if (_lsMultiThreadItems[0] == _ddMultiThreadValue) {
      iddThreads = 1;
    } else if (_lsMultiThreadItems[1] == _ddMultiThreadValue) {
      iddThreads = 2;
    } else if (_lsMultiThreadItems[2] == _ddMultiThreadValue) {
      iddThreads = 4;
    }
    setState(() {
      _iddThreads = iddThreads;
    });
  }

  Widget ddMultiThread(double dFontSizeScale0) {
    final List<DropdownMenuItem<dynamic>>? lddItems = _lsMultiThreadItems.map((String items) {
      return DropdownMenuItem(
        value: items,
        child: Text(items, style: TextStyle(fontSize: 22 * dFontSizeScale0)),
      );
    }).toList();
    return DropdownButton(
        items: lddItems,
        value: _ddMultiThreadValue,
        itemHeight: 7 * dFontSizeScale0 + kMinInteractiveDimension,
        onChanged: onChangedDDMultiThread);
  }

  Widget wTooltipThreads(double dFontSizeScale0) {
    return Tooltip(
        message:
            "You can test the MultiThreaded speed of your device by choosing the '2 Threads' or '4 Threads'.",
        preferBelow: false,
        triggerMode: TooltipTriggerMode.tap,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(left: 60, right: 60),
        decoration:
            BoxDecoration(color: const Color(0xE04090FF), borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(color: Colors.white, fontSize: 20),
        showDuration: const Duration(seconds: 10),
        child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 4, left: 4, top: 4),
            child: Transform.scale(
                scale: dFontSizeScale0 * 1.36,
                child: const Icon(Icons.info_outline, color: Colors.blue))));
  }

  @override
  Widget build(BuildContext context) {
    if (1000000 > (_dElapsed.inMicroseconds - _dFirstFrame.inMicroseconds)) {
      _iFrameCount++;
      if ((_iFPS < _iFrameCount) && _bStart) _iFPS = _iFrameCount;
    } else {
      _dFirstFrame = _dElapsed;
      _iFPS = _iFrameCount;
      _iFrameCount = 0;
    }
    double dScreenWidth = MediaQuery.of(context).size.width;
    double dScreenHeight = MediaQuery.of(context).size.height;
    // Height (without SafeArea: without status and toolbar)
    EdgeInsets dHeightPadding = MediaQuery.of(context).padding; // .viewPadding;
    dScreenHeight = dScreenHeight - dHeightPadding.top - kToolbarHeight - dHeightPadding.bottom;
    double dScreenSizePortrait = 0;
    double dScreenSizeLandscape = 0;
    Widget wQueenScaledPortrait = const SizedBox.shrink();
    Widget wTimeElapsedPortrait = const SizedBox.shrink();
    Widget wQueenScaledLandscape = const SizedBox.shrink();
    Widget wTimeElapsedLandscape = const SizedBox.shrink();

    Orientation currentOrientation = MediaQuery.of(context).orientation;
    if (Orientation.portrait == currentOrientation) {
      dScreenSizePortrait = max(min(dScreenWidth, (dScreenHeight - 100) / 1.54), 200);
      _dFontSizeScalePortrait = dScreenSizePortrait / 420;
      wQueenScaledPortrait = Padding(
          padding: EdgeInsets.only(bottom: dScreenSizePortrait / 320),
          child: Transform.scale(scale: 380 / dScreenSizePortrait, child: wQueenImage));
      wTimeElapsedPortrait = Text(
        _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
        style: TextStyle(fontSize: 32 * _dFontSizeScalePortrait, color: cNumbers),
      );
    } else {
      dScreenSizeLandscape = min(dScreenWidth / 2.2, dScreenHeight);
      _dFontSizeScaleLandscape = dScreenSizeLandscape / 320;
      wQueenScaledLandscape = Padding(
          padding: EdgeInsets.only(bottom: dScreenSizeLandscape / 220),
          child: Transform.scale(scale: 380 / dScreenSizeLandscape, child: wQueenImage));
      wTimeElapsedLandscape = Text(
          _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
          style: TextStyle(fontSize: 32 * _dFontSizeScaleLandscape, color: cNumbers));
    }
    if (pow(8, 8) == _stepCounter) {
      Color cResult = cVeryFast;
      if (1 == _iThreadsStarted) {
        if (Duration(milliseconds: imsLimitVeryFast1) > _dElapsed) {
          iSpeed = 7;
          cResult = cVeryFast;
        } else if (Duration(milliseconds: imsLimitFast1) > _dElapsed) {
          iSpeed = 6;
          cResult = cFast;
        } else if (Duration(milliseconds: imsLimitBetterThanAverage1) > _dElapsed) {
          iSpeed = 5;
          cResult = cBetterThanAverage;
        } else if (Duration(milliseconds: imsLimitAverage1) > _dElapsed) {
          iSpeed = 4;
          cResult = cAverage;
        } else if (Duration(milliseconds: imsLimitSlowerThanAverage1) > _dElapsed) {
          iSpeed = 3;
          cResult = cSlowerThanAverage;
        } else if (Duration(milliseconds: imsLimitSlow1) > _dElapsed) {
          iSpeed = 2;
          cResult = cSlow;
        } else {
          iSpeed = 1;
          cResult = cVerySlow;
        }
      }
      if (2 == _iThreadsStarted) {
        if (Duration(milliseconds: imsLimitVeryFast2) > _dElapsed) {
          iSpeed = 7;
          cResult = cVeryFast;
        } else if (Duration(milliseconds: imsLimitFast2) > _dElapsed) {
          iSpeed = 6;
          cResult = cFast;
        } else if (Duration(milliseconds: imsLimitBetterThanAverage2) > _dElapsed) {
          iSpeed = 5;
          cResult = cBetterThanAverage;
        } else if (Duration(milliseconds: imsLimitAverage2) > _dElapsed) {
          iSpeed = 4;
          cResult = cAverage;
        } else if (Duration(milliseconds: imsLimitSlowerThanAverage2) > _dElapsed) {
          iSpeed = 3;
          cResult = cSlowerThanAverage;
        } else if (Duration(milliseconds: imsLimitSlow2) > _dElapsed) {
          iSpeed = 2;
          cResult = cSlow;
        } else {
          iSpeed = 1;
          cResult = cVerySlow;
        }
      }
      if (4 == _iThreadsStarted) {
        if (Duration(milliseconds: imsLimitVeryFast4) > _dElapsed) {
          iSpeed = 7;
          cResult = cVeryFast;
        } else if (Duration(milliseconds: imsLimitFast4) > _dElapsed) {
          iSpeed = 6;
          cResult = cFast;
        } else if (Duration(milliseconds: imsLimitBetterThanAverage4) > _dElapsed) {
          iSpeed = 5;
          cResult = cBetterThanAverage;
        } else if (Duration(milliseconds: imsLimitAverage4) > _dElapsed) {
          iSpeed = 4;
          cResult = cAverage;
        } else if (Duration(milliseconds: imsLimitSlowerThanAverage4) > _dElapsed) {
          iSpeed = 3;
          cResult = cSlowerThanAverage;
        } else if (Duration(milliseconds: imsLimitSlow4) > _dElapsed) {
          iSpeed = 2;
          cResult = cSlow;
        } else {
          iSpeed = 1;
          cResult = cVerySlow;
        }
      }
      if (Orientation.portrait == currentOrientation) {
        wTimeElapsedPortrait = ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultPage(
                        speed: iSpeed,
                        color: cNumbers,
                        backgroundcolor: cResult,
                        threads: _iThreadsStarted,
                        elapsed: _dElapsed)),
              );
            },
            style: ElevatedButton.styleFrom(primary: cResult),
            child: Text(
              _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
              style: TextStyle(fontSize: 32 * _dFontSizeScalePortrait, color: cNumbers),
            ));
      } else {
        wTimeElapsedLandscape = ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultPage(
                        speed: iSpeed,
                        color: cNumbers,
                        backgroundcolor: cResult,
                        threads: _iThreadsStarted,
                        elapsed: _dElapsed)),
              );
            },
            style: ElevatedButton.styleFrom(primary: cResult),
            child: Text(
              _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
              style: TextStyle(fontSize: 32 * _dFontSizeScaleLandscape, color: cNumbers),
            ));
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'Info Page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoPage()),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: OrientationBuilder(builder: (context, orientation) {
          return (orientation == Orientation.portrait)
              ? Stack(children: [
                  Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                    Container(
                      width: dScreenSizePortrait,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                          height: dScreenSizePortrait,
                          child: ChessTable(
                              wQueen: Padding(
                                  padding: EdgeInsets.only(bottom: dScreenSizePortrait / 320),
                                  child: wQueenScaledPortrait),
                              liPlace: _liPos,
                              dLeft: 24,
                              dTop: 16,
                              dScreenSize: dScreenSizePortrait)),
                    ),
                    wDisplayNumbers(_dFontSizeScalePortrait),
                    wTimeElapsedPortrait,
                    wddWaitType(_dFontSizeScalePortrait),
                    const Spacer(),
                  ])),
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            wTooltipThreads(_dFontSizeScalePortrait),
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ddMultiThread(_dFontSizeScalePortrait))
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text('FPS:',
                                      style: TextStyle(fontSize: 20 * _dFontSizeScalePortrait))),
                              Text(_iFPS.toString(),
                                  style: TextStyle(
                                      fontSize: 32 * _dFontSizeScalePortrait, color: cNumbers))
                            ]),
                            const SizedBox(height: 26)
                          ])))
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                  SizedBox(
                      height: dScreenSizeLandscape,
                      width: dScreenSizeLandscape,
                      child: ChessTable(
                          wQueen: wQueenScaledLandscape,
                          liPlace: _liPos,
                          dLeft: 24,
                          dTop: 16,
                          dScreenSize: dScreenSizeLandscape)),
                  Flexible(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          wDisplayNumbers(_dFontSizeScaleLandscape),
                          wTimeElapsedLandscape,
                          wddWaitType(_dFontSizeScaleLandscape)
                        ],
                      )),
                  Flexible(
                      flex: 3,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              (2.4 < (dScreenWidth / dScreenHeight))
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 24, right: 4),
                                      child: wTooltipThreads(_dFontSizeScaleLandscape))
                                  : const SizedBox.shrink(),
                              Padding(
                                padding: const EdgeInsets.only(top: 24, right: 10),
                                child: Text('FPS:',
                                    style: TextStyle(fontSize: 20 * _dFontSizeScaleLandscape)),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 24, right: 16),
                                  child: Text(_iFPS.toString(),
                                      style: TextStyle(
                                          fontSize: 32 * _dFontSizeScaleLandscape, color: cNumbers)))
                            ],
                          ),
                          Row(children: [
                            const Spacer(),
                            Padding(
                                padding: const EdgeInsets.only(top: 4, right: 12),
                                child: ddMultiThread(_dFontSizeScaleLandscape))
                          ]),
                          (2.4 > (dScreenWidth / dScreenHeight))
                              ? Row(children: [
                                  const Spacer(),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 6, right: 8),
                                      child: wTooltipThreads(_dFontSizeScaleLandscape))
                                ])
                              : const SizedBox.shrink(),
                        ],
                      ))
                ]);
        }),
        floatingActionButton: OrientationBuilder(builder: (context, orientation) {
          return (orientation == Orientation.portrait)
              ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                          child: (!_bPaused)
                              ? const Text("Pause", style: TextStyle(fontSize: 20))
                              : const Text("Resume", style: TextStyle(fontSize: 20))),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                      onPressed: (_bStart)
                          ? (_bPaused)
                              ? _resumeCounter
                              : _pauseCounter
                          : null),
                  const SizedBox(width: 16),
                  ElevatedButton(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                          child: (!_bStart)
                              ? (0 == _stepCounter)
                                  ? const Text("Start", style: TextStyle(fontSize: 20))
                                  : const Text("Reset", style: TextStyle(fontSize: 20))
                              : const Text("Stop", style: TextStyle(fontSize: 20))),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                      onPressed: (!_bStart)
                          ? (0 == _stepCounter)
                              ? _startCounter
                              : _resetCounter
                          : _stopCounter)
                ])
              : Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                          child: (!_bPaused)
                              ? const Text("Pause", style: TextStyle(fontSize: 20))
                              : const Text("Resume", style: TextStyle(fontSize: 20))),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                      onPressed: (_bStart)
                          ? (_bPaused)
                              ? _resumeCounter
                              : _pauseCounter
                          : null),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                          child: (!_bStart)
                              ? (0 == _stepCounter)
                                  ? const Text("Start", style: TextStyle(fontSize: 20))
                                  : const Text("Reset", style: TextStyle(fontSize: 20))
                              : const Text("Stop", style: TextStyle(fontSize: 20))),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                      onPressed: (!_bStart)
                          ? (0 == _stepCounter)
                              ? _startCounter
                              : _resetCounter
                          : _stopCounter)
                ]);
        }));
  }
}
