import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import '../dartjs/nojsconnection.dart' if (dart.library.html) '../dartjs/jsconnection.dart' as dartjs;
import "package:async/async.dart";
import 'package:eightqueens/widgets/webwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as _foundation show kIsWeb, kReleaseMode;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collection/collection.dart';
import '../isolates/findsolutions.dart';
import '../isolates/multithreadedfindsolutions.dart';
import '../middleware/rankings.dart';
import '../middleware/certificate.dart';
import '../middleware/autoregistration.dart';
import '../middleware/insertresultsorautoreg.dart';
import '../widgets/boxwidgets.dart';
import 'configpage.dart';
import 'infopage.dart';
import 'resultpage.dart';

class HomePage extends StatefulWidget {
  final String title;
  final double headerSize;

  const HomePage({Key? key, required this.title, required this.headerSize}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FindSolutions findSolution = FindSolutions();
  final MultiTreadedFindSolution multiThreadedFindSolution = MultiTreadedFindSolution();
  final int iDisplayDelayConstant = 180000;
  final int iMinDisplayDelay = 5;
  final int iMaxDisplayDelay = 24;
  bool _bStart = false;
  bool _bPaused = false;
  int _stepCounter = 0;
  int _stepCounterPrevious = 0;
  int _solutionCounter = 0;
  bool _bCheckQueensNoAttack = false;
  int _waitms = 0;
  int _iddThreads = 1;
  int _nThreadsStarted = 1;
  DateTime _dtStart = DateTime.now().toUtc();
  DateTime _dtProgress = DateTime.now().toUtc();
  Duration _dElapsed = const Duration(days: 0);
  Duration _dFirstFrame = const Duration(days: 0);
  int _iFrameCount = 0;
  int _iFPS = 0;
  final List<int> _liFrameCount = [];
  List<int> _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
  final List<int> liMultiStepCounter = <int>[];
  final List<int> liMultiSolutionCounter = <int>[];
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
  List<dynamic> _ldvLD = [];
  bool _b5secWaitStarted = false;
  bool _bResultPageOpened = false;
  bool _insertResultOrAutoRegStarted = false;

  final GlobalKey<ResultPageState> _resultPageKey = GlobalKey();

  final Rankings _rks = Rankings();
  int _iSpeedRank = 0;
  Color _cSpeedRank = Colors.white;
  String _sRankName = "Unknown";

  AutoRegLocal arl = AutoRegLocal();
  late AutoRegMiddleware arm;
  late InsertResultsOrAutoRegMiddleware iroarm;

  @override
  initState() {
    super.initState();
    CertificatesStorage.load();
    arm = AutoRegMiddleware(autoRegLocal: arl);
    iroarm = InsertResultsOrAutoRegMiddleware(autoRegLocal: arl, autoRegMiddleware: arm);
    if (!_foundation.kIsWeb) arl.initEAutoRegedFromLocal();
    _lsMultiThreadItems.add('8 Threads');
    wQueenImage = SvgPicture.asset(assetQueenName, semanticsLabel: 'Queen :)');
  }

  Future<void> _startStepCounter() async {
    if (1 == _iddThreads) {
      _nThreadsStarted = 1;
      if (!_foundation.kIsWeb) {
        await _startStepCounterOneThreaded();
      } else {
        await _startStepCounter4WebOneThreaded();
      }
    } else if (2 == _iddThreads) {
      _nThreadsStarted = 2;
      if (!_foundation.kIsWeb) {
        await _startStepCounterMultiThreaded();
      } else {
        await _startStepCounter4WebMultiThreaded();
      }
    } else if (4 == _iddThreads) {
      _nThreadsStarted = 4;
      if (!_foundation.kIsWeb) {
        await _startStepCounterMultiThreaded();
      } else {
        await _startStepCounter4WebMultiThreaded();
      }
    } else if (8 == _iddThreads) {
      _nThreadsStarted = 8;
      if (!_foundation.kIsWeb) {
        await _startStepCounterMultiThreaded();
      } else {
        await _startStepCounter4WebMultiThreaded();
      }
    }
  }

  Future<void> _startStepCounterOneThreaded() async {
    setState(() {
      _bStart = true;
      _bPaused = false;
      _stepCounter = 0;
      _stepCounterPrevious = 0;
      _solutionCounter = 0;
    });
    List<dynamic> ldSqdLd = await findSolution.startIsolateInBackground();
    _sendPort = ldSqdLd[0];
    _sqdEvents = ldSqdLd[1];
    _dtStart = DateTime.now().toUtc();
    _dtProgress = DateTime.now().toUtc();
    _dFirstFrame = const Duration(days: 0);
    _iFrameCount = 0;
    _liFrameCount.clear();
    _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    do {
      await _frameDisplay();
      int iDisplayDelay = iDisplayDelayConstant ~/ (1 + _stepCounter - _stepCounterPrevious);
      iDisplayDelay = max(iMinDisplayDelay, iDisplayDelay);
      iDisplayDelay = min(iMaxDisplayDelay, iDisplayDelay);
      await Future.delayed(Duration(milliseconds: iDisplayDelay));
    } while (_bStart);
    findSolution.stopIsolateInBackground();
    setState(() {});
  }

  Future<void> _startStepCounterMultiThreaded() async {
    for (int i = 0; i < _nThreadsStarted; i++) {
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
      _stepCounterPrevious = 0;
      _solutionCounter = 0;
    });
    _lsendPort.clear();
    _lsqdEvents.clear();
    List<dynamic> ldSqdLd =
        await multiThreadedFindSolution.startMultiIsolatesInBackground(_nThreadsStarted);
    for (int i = 0; i < _nThreadsStarted; i++) {
      _lsendPort.add(ldSqdLd[0][i]);
      _lsqdEvents.add(ldSqdLd[1][i]);
    }
    _dtStart = DateTime.now().toUtc();
    _dtProgress = DateTime.now().toUtc();
    _dFirstFrame = const Duration(days: 0);
    _iFrameCount = 0;
    _liFrameCount.clear();
    _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    _iPort = 0;
    do {
      await _frameDisplayForMultiThreads();
      int iDisplayDelay = iDisplayDelayConstant ~/ (1 + _stepCounter - _stepCounterPrevious);
      iDisplayDelay = max(iMinDisplayDelay, iDisplayDelay);
      iDisplayDelay = min(iMaxDisplayDelay, iDisplayDelay);
      await Future.delayed(Duration(milliseconds: iDisplayDelay));
    } while (_bStart);
    multiThreadedFindSolution.stopAllIsolatesInBackground();
    setState(() {});
  }

  Future<void> _startStepCounter4WebOneThreaded() async {
    setState(() {
      _bStart = true;
      _bPaused = false;
      _stepCounter = 0;
      _stepCounterPrevious = 0;
      _solutionCounter = 0;
    });

    dartjs.jsCallStartWorker(_foundation.kReleaseMode);

    dartjs.jsCallBackSendMessage2Dart(_sendMessage2Dart);

    _dtStart = DateTime.now().toUtc();
    _dtProgress = DateTime.now().toUtc();
    _dFirstFrame = const Duration(days: 0);
    _iFrameCount = 0;
    _liFrameCount.clear();
    _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    _ldvLD = [];
    do {
      await _frameDisplay4Web();
      int iDisplayDelay = iDisplayDelayConstant ~/ (1 + _stepCounter - _stepCounterPrevious);
      iDisplayDelay = max(iMinDisplayDelay, iDisplayDelay);
      iDisplayDelay = min(iMaxDisplayDelay, iDisplayDelay);
      await Future.delayed(Duration(milliseconds: iDisplayDelay));
    } while (_bStart);
    dartjs.jsStopWorker();
    setState(() {});
    debugPrint('Dart Message: stop 1');
  }

  Future<void> _startStepCounter4WebMultiThreaded() async {
    for (int i = 0; i < _nThreadsStarted; i++) {
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
      _stepCounterPrevious = 0;
      _solutionCounter = 0;
    });

    dartjs.jsStartMultithreadedWorkers(_nThreadsStarted, _waitms, _foundation.kReleaseMode);

    dartjs.jsSendMultithreadedMessage2Dart(_sendMultithreadedMessage2Dart);

    _dtStart = DateTime.now().toUtc();
    _dtProgress = DateTime.now().toUtc();
    _dFirstFrame = const Duration(days: 0);
    _iFrameCount = 0;
    _liFrameCount.clear();
    _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    _iPort = 0;
    _ldvLD = [];
    do {
      await _frameDisplay4WebForMultiThreads();
      int iDisplayDelay = iDisplayDelayConstant ~/ (1 + _stepCounter - _stepCounterPrevious);
      iDisplayDelay = max(iMinDisplayDelay, iDisplayDelay);
      iDisplayDelay = min(iMaxDisplayDelay, iDisplayDelay);
      await Future.delayed(Duration(milliseconds: iDisplayDelay));
    } while (_bStart);
    dartjs.jsStopMultithreadedWorkers();
    setState(() {});
    debugPrint('Dart Message: multithreaded stop');
  }

  void _stopStepCounter() {
    setState(() {
      _bStart = false;
    });
    if (1 == _nThreadsStarted) {
      if (!_foundation.kIsWeb) {
        findSolution.stopIsolateInBackground();
      } else {
        dartjs.jsStopWorker();
      }
    } else {
      if (!_foundation.kIsWeb) {
        multiThreadedFindSolution.stopAllIsolatesInBackground();
      } else {
        dartjs.jsStopMultithreadedWorkers();
      }
    }
    setState(() {});
  }

  void _resetStepCounter() {
    setState(() {
      _bStart = false;
      _stepCounter = 0;
      _stepCounterPrevious = 0;
      _solutionCounter = 0;
      _dtStart = DateTime.now().toUtc();
      _dtProgress = DateTime.now().toUtc();
      _dElapsed = const Duration(days: 0);
      _dFirstFrame = const Duration(days: 0);
      _iFrameCount = 0;
      _iFPS = 0;
      _liFrameCount.clear();
      _liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
      _bResultPageOpened = false;
      _insertResultOrAutoRegStarted = false;
    });
    setState(() {});
  }

  void _pauseStepCounter() {
    if (1 == _nThreadsStarted) {
      if (!_foundation.kIsWeb) {
        findSolution.pause();
      } else {
        dartjs.jsPauseWorker();
      }
    } else {
      if (!_foundation.kIsWeb) {
        multiThreadedFindSolution.pause();
      } else {
        dartjs.jsPauseMultithreadedWorkers();
      }
    }
    setState(() {
      _bPaused = true;
    });
  }

  void _resumeStepCounter() {
    if (1 == _nThreadsStarted) {
      if (!_foundation.kIsWeb) {
        findSolution.resume();
      } else {
        dartjs.jsResumeWorker();
      }
    } else {
      if (!_foundation.kIsWeb) {
        multiThreadedFindSolution.resume();
      } else {
        dartjs.jsResumeMultithreadedWorkers();
      }
    }
    setState(() {
      _bPaused = false;
    });
  }

  Future<void> _frameDisplay() async {
    _dtProgress = DateTime.now().toUtc();
    _dElapsed = _dtProgress.difference(_dtStart);
    _sendPort.send(_waitms);
    try {
      var vLD = await _sqdEvents.next;
      if (vLD is List) {
        _stepCounterPrevious = _stepCounter;
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
    _dtProgress = DateTime.now().toUtc();
    _dElapsed = _dtProgress.difference(_dtStart);
    _iPort++;
    if (_iPort >= _nThreadsStarted) _iPort = 0;
    _lsendPort[_iPort].send(_waitms);
    try {
      var vLD = await _lsqdEvents[_iPort].next;
      if (vLD is List) {
        liMultiStepCounter[_iPort] = vLD[1];
        liMultiSolutionCounter[_iPort] = vLD[2];
        int iSumMultiStepCounter = 0;
        int iSumMultiSolutionCounter = 0;
        for (int i = 0; i < _nThreadsStarted; i++) {
          iSumMultiStepCounter += liMultiStepCounter[i] + 1;
          iSumMultiSolutionCounter += liMultiSolutionCounter[i];
        }
        _stepCounterPrevious = _stepCounter;
        setState(() {
          _liPos = vLD[0];
          _stepCounter = iSumMultiStepCounter;
          _solutionCounter = iSumMultiSolutionCounter;
          _bCheckQueensNoAttack = vLD[3];
        });
      } else if (null == vLD) {
        _lbStart[_iPort] = false;
        int iStart = 0;
        for (int i = 0; i < _nThreadsStarted; i++) {
          if (_lbStart[i]) iStart++;
        }
        if (0 == iStart) _bStart = false;
      }
    } on Exception catch (e) {
      debugPrint('Dart error message, mt: Dart, e.toString(): ' + e.toString());
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

  _sendMessage2Dart(var msgJs) {
    _ldvLD.add(msgJs);
    //debugPrint('Dart received message, msgJs: ' + msgJs.toString());
  }

  Future<void> _frameDisplay4Web() async {
    _dtProgress = DateTime.now().toUtc();
    _dElapsed = _dtProgress.difference(_dtStart);
    dartjs.jsReceiveMsgFromDart(_waitms);
    try {
      dynamic vLD;
      const int nWait = 100;
      int i = 0;
      do {
        await Future.delayed(const Duration(milliseconds: 1));
        i++;
      } while (_ldvLD.isEmpty && i < nWait);

      //debugPrint('Dart message, ldvLD: ' + ldvLD.toString() + ', i: ' + i.toString());

      if (_ldvLD.isEmpty) {
        vLD = [jsonEncode(_liPos), _stepCounter - 1, _solutionCounter, false];
      } else {
        vLD = _ldvLD.removeAt(0);
      }

      if (vLD is List) {
        _stepCounterPrevious = _stepCounter;
        setState(() {
          _liPos = jsonDecode(vLD[0]).cast<int>();
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
        dartjs.jsPauseWorker();
        setState(() {});
        await Future.delayed(Duration(milliseconds: _waitms));
        dartjs.jsResumeWorker();
      }
    }
    setState(() {});
    await Future.delayed(Duration.zero);
  }

  _sendMultithreadedMessage2Dart(List<dynamic> mtMsgJs) {
    _ldvLD.add(mtMsgJs);
    //debugPrint('Multithreaded Dart received message, mtMsgJs: $mtMsgJs');
  }

  Future<void> _frameDisplay4WebForMultiThreads() async {
    _dtProgress = DateTime.now().toUtc();
    _dElapsed = _dtProgress.difference(_dtStart);
    _iPort++;
    if (_iPort >= _nThreadsStarted) _iPort = 0;
    dartjs.jsReceiveMultithreadedMsgFromDart(_iPort, _waitms);
    try {
      dynamic vLD;
      const int nWait = 100;
      int i = 0;
      do {
        await Future.delayed(const Duration(milliseconds: 1));
        i++;
      } while (_ldvLD.isEmpty && i < nWait);

      //debugPrint('Dart message, ldvLD: $_ldvLD, i: $i');

      if (_ldvLD.isNotEmpty) {
        vLD = _ldvLD.removeAt(0);
        if (vLD[1] is List) {
          int iPort = vLD[0];
          liMultiStepCounter[iPort] = vLD[1][1];
          liMultiSolutionCounter[iPort] = vLD[1][2];
          int iSumMultiStepCounter = 0;
          int iSumMultiSolutionCounter = 0;
          for (int i = 0; i < _nThreadsStarted; i++) {
            iSumMultiStepCounter += liMultiStepCounter[i] + 1;
            iSumMultiSolutionCounter += liMultiSolutionCounter[i];
          }
          _stepCounterPrevious = _stepCounter;
          setState(() {
            _liPos = jsonDecode(vLD[1][0]).cast<int>();
            _stepCounter = iSumMultiStepCounter;
            _solutionCounter = iSumMultiSolutionCounter;
            _bCheckQueensNoAttack = vLD[1][3];
          });
        } else if (null == vLD[1]) {
          int iPort = vLD[0];
          _lbStart[iPort] = false;
          int iStart = 0;
          for (int i = 0; i < _nThreadsStarted; i++) {
            if (_lbStart[i]) iStart++;
          }
          if (0 == iStart) _bStart = false;
        }
      }
    } on Exception catch (e) {
      debugPrint('Dart error message, mt: Js, e.toString(): ' + e.toString());
    }
    if (_bCheckQueensNoAttack) {
      if (0 != _waitms) {
        dartjs.jsPauseMultithreadedWorkers();
        setState(() {});
        await Future.delayed(Duration(milliseconds: _waitms));
        dartjs.jsResumeMultithreadedWorkers();
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
            focusColor: Colors.transparent,
            itemHeight: (1.5 < dFontSizeScale0)
                ? 24 * (dFontSizeScale0 - 1.5) + kMinInteractiveDimension
                : kMinInteractiveDimension,
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
                padding: EdgeInsets.only(
                    right: 16 * dFontSizeScale0,
                    bottom: 4 * dFontSizeScale0,
                    left: 12 * dFontSizeScale0,
                    top: 4 * dFontSizeScale0),
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
    } else if (_lsMultiThreadItems[3] == _ddMultiThreadValue) {
      iddThreads = 8;
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
        focusColor: Colors.transparent,
        itemHeight: (1.5 < dFontSizeScale0)
            ? 24 * (dFontSizeScale0 - 1.5) + kMinInteractiveDimension
            : kMinInteractiveDimension,
        onChanged: onChangedDDMultiThread);
  }

  Widget wTooltipThreads(double dFontSizeScale0) {
    return Tooltip(
        message:
            "You can test the MultiThreaded speed of your device by choosing '2 Threads', '4 Threads' or '8 Threads'.",
        preferBelow: false,
        triggerMode: TooltipTriggerMode.tap,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(left: 60, right: 60),
        decoration:
            BoxDecoration(color: const Color(0xE04090FF), borderRadius: BorderRadius.circular(6)),
        textStyle: const TextStyle(color: Colors.white, fontSize: 20),
        showDuration: const Duration(seconds: 10),
        child: Padding(
            padding: EdgeInsets.only(right: 8 * dFontSizeScale0, top: 4 * dFontSizeScale0),
            child: Transform.scale(
                scale: dFontSizeScale0 * 1.36,
                child: const Icon(Icons.info_outline, color: Colors.blue))));
  }

  @override
  Widget build(BuildContext context) {
    if (200000 > (_dElapsed.inMicroseconds - _dFirstFrame.inMicroseconds)) {
      _iFrameCount++;
    } else {
      _dFirstFrame = _dElapsed;
      _liFrameCount.add(_iFrameCount);
      if (5 < _liFrameCount.length) {
        _liFrameCount.removeAt(0);
      }
      _iFPS = _liFrameCount.sum * (6 - _liFrameCount.length);
      _iFrameCount = 0;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            (_foundation.kIsWeb)
                ? IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Config Page',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConfigPage()),
                      );
                    },
                  )
                : const SizedBox.shrink(),
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
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {

          _openResultPage(Color cResult0) {
            if (null == _resultPageKey.currentState) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultPage(
                        key: _resultPageKey,
                        speed: _iSpeedRank,
                        color: cNumbers,
                        backgroundcolor: cResult0,
                        threads: _nThreadsStarted,
                        elapsed: _dElapsed,
                        rankname: _sRankName)),
              );
            }
          }

          _startOpenResultPageAfterWait(Color cResult0) async {
            const int iWaitMsSec = 3000;
            for (int i = 0; i < iWaitMsSec; i += 100) {
              await Future.delayed(const Duration(milliseconds: 100));
              if (pow(8, 8) != _stepCounter || _bResultPageOpened) break;
            }
            if (pow(8, 8) == _stepCounter && !_bResultPageOpened) {
              _bResultPageOpened = true;
              _openResultPage(cResult0);
            }
            _b5secWaitStarted = false;
          }

          Future<void> _callInsertResultsOrAutoRegAfterWait() async {
            await Future.delayed(const Duration(milliseconds: 1000));
            if (!_bStart && 0 < _stepCounter && const Duration(milliseconds: 0) < _dElapsed) {
              bool success = await iroarm.insertResultOrAutoReg(_nThreadsStarted, _dElapsed);
              if (success) {
                _insertResultOrAutoRegStarted = false;
              }
            }
          }

          // ! debugPrint('constraints.maxWidth: ${constraints.maxWidth}');
          // ! debugPrint('constraints.maxHeight: ${constraints.maxHeight}');
          //double dScreenWidth = MediaQuery.of(context).size.width;
          //double dScreenHeight = MediaQuery.of(context).size.height;
          double dScreenWidth = constraints.maxWidth;
          double dScreenHeight = constraints.maxHeight;
          //debugPrint("ScreenWidth: ${dScreenWidth.toStringAsFixed(2)}");
          //debugPrint("ScreenHeight: ${dScreenHeight.toStringAsFixed(2)}");
          // Height (without SafeArea: without status and toolbar)
          //EdgeInsets dHeightPadding = MediaQuery.of(context).padding; // .viewPadding;
          dScreenHeight = max(
              dScreenHeight // -
              //widget.headerSize -
              //dHeightPadding.top -
              //kToolbarHeight -
              //dHeightPadding.bottom
              ,
              0);
          // ! debugPrint("ScreenWidth: ${dScreenWidth.toStringAsFixed(2)}");
          // ! debugPrint("ScreenHeight-: ${dScreenHeight.toStringAsFixed(2)}");
          double dScreenSizePortrait = 0;
          double dScreenSizeLandscape = 0;
          Widget wQueenScaledPortrait = const SizedBox.shrink();
          Widget wTimeElapsedPortrait = const SizedBox.shrink();
          Widget wQueenScaledLandscape = const SizedBox.shrink();
          Widget wTimeElapsedLandscape = const SizedBox.shrink();

          Orientation currentOrientation = Orientation.landscape;
          if (dScreenWidth < dScreenHeight) currentOrientation = Orientation.portrait;
          if (Orientation.portrait == currentOrientation) {
            dScreenSizePortrait = max(min(dScreenWidth, (dScreenHeight - 100) / 1.58), 200);
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
            _dFontSizeScaleLandscape = dScreenSizeLandscape / 332;
            wQueenScaledLandscape = Padding(
                padding: EdgeInsets.only(bottom: dScreenSizeLandscape / 220),
                child: Transform.scale(scale: 380 / dScreenSizeLandscape, child: wQueenImage));
            wTimeElapsedLandscape = Text(
                _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
                style: TextStyle(fontSize: 32 * _dFontSizeScaleLandscape, color: cNumbers));
          }
          if (pow(8, 8) == _stepCounter) {
            if (!_foundation.kIsWeb && !_insertResultOrAutoRegStarted) {
              _insertResultOrAutoRegStarted = true;
              _callInsertResultsOrAutoRegAfterWait();
            }
            _iSpeedRank = _rks.getSpeedRank(_nThreadsStarted, _dElapsed);
            //debugPrint("homepage.dart, build, _iSpeedRank: $_iSpeedRank");
            _cSpeedRank = _rks.lcRanks[_iSpeedRank];
            //debugPrint("homepage.dart, build, _cSpeedRank: $_cSpeedRank");
            _sRankName = _rks.lsRankNames[_iSpeedRank];
            //debugPrint("homepage.dart, build, _sRankName: $_sRankName");
            if (!_b5secWaitStarted) {
              _b5secWaitStarted = true;
              _startOpenResultPageAfterWait(_cSpeedRank);
            }
            if (Orientation.portrait == currentOrientation) {
              wTimeElapsedPortrait = ElevatedButton(
                  onPressed: () { _bResultPageOpened = true; _openResultPage(_cSpeedRank); },
                  clipBehavior: Clip.none,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cSpeedRank,
                  ),
                  child: Text(
                    _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
                    style: TextStyle(fontSize: 32 * _dFontSizeScalePortrait, color: cNumbers),
                  ));
            } else {
              wTimeElapsedLandscape = ElevatedButton(
                  onPressed: () { _bResultPageOpened = true; _openResultPage(_cSpeedRank); },
                  style: ElevatedButton.styleFrom(backgroundColor: _cSpeedRank),
                  child: Text(
                    _dElapsed.toString().substring(0, _dElapsed.toString().indexOf('.') + 4),
                    style: TextStyle(fontSize: 30 * _dFontSizeScaleLandscape, color: cNumbers),
                  ));
            }
          }
          if (constraints.maxWidth < constraints.maxHeight) {
            return Stack(children: [
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
                          /*dLeft: 24,
                              dTop: 16,*/
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
                      padding: EdgeInsets.only(left: 32 * _dFontSizeScalePortrait),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        wTooltipThreads(_dFontSizeScalePortrait),
                        Row(children: [
                          Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ddMultiThread(_dFontSizeScalePortrait))
                        ]),
                        SizedBox(height: 6 * _dFontSizeScalePortrait),
                        Row(children: [
                          Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text('FPS:',
                                  style: TextStyle(fontSize: 20 * _dFontSizeScalePortrait))),
                          Text(_iFPS.toString(),
                              style:
                                  TextStyle(fontSize: 32 * _dFontSizeScalePortrait, color: cNumbers))
                        ]),
                        SizedBox(height: 26 * _dFontSizeScalePortrait)
                      ])))
            ]);
          } else {
            return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              SizedBox(
                  height: dScreenSizeLandscape,
                  width: dScreenSizeLandscape,
                  child: ChessTable(
                      wQueen: wQueenScaledLandscape,
                      liPlace: _liPos,
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
                          (1.76 < (dScreenWidth / dScreenHeight))
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
                      (1.76 > (dScreenWidth / dScreenHeight))
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
          }
        }),
        floatingActionButton:
            LayoutBuilder(builder: (BuildContext context, BoxConstraints floatingConstraints) {
          double realFloatingConstraintsMaxHeight =
              max(floatingConstraints.maxHeight - GVW.dWebWidgetHeaderHeight, 0);
          if (floatingConstraints.maxWidth < (realFloatingConstraintsMaxHeight)) {
            // portrait
            // debugPrint('floatingConstraints.maxWidth: ${floatingConstraints.maxWidth}');
            // debugPrint('realFloatingConstraintsMaxHeight: $realFloatingConstraintsMaxHeight');
            return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                      child: (!_bPaused)
                          ? const Text("Pause", style: TextStyle(fontSize: 20))
                          : const Text("Resume", style: TextStyle(fontSize: 20))),
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                  onPressed: (_bStart)
                      ? (_bPaused)
                          ? _resumeStepCounter
                          : _pauseStepCounter
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
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                  onPressed: (!_bStart)
                      ? (0 == _stepCounter)
                          ? _startStepCounter
                          : _resetStepCounter
                      : _stopStepCounter)
            ]);
          } else {
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              ElevatedButton(
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                      child: (!_bPaused)
                          ? const Text("Pause", style: TextStyle(fontSize: 20))
                          : const Text("Resume", style: TextStyle(fontSize: 20))),
                  style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                  onPressed: (_bStart)
                      ? (_bPaused)
                          ? _resumeStepCounter
                          : _pauseStepCounter
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
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
                  onPressed: (!_bStart)
                      ? (0 == _stepCounter)
                          ? _startStepCounter
                          : _resetStepCounter
                      : _stopStepCounter)
            ]);
          }
        }));
  }
}
