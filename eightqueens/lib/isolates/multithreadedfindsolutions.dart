import 'dart:isolate';
import 'dart:math';
import "package:async/async.dart";
//import 'package:flutter/foundation.dart';
import 'stepandcheck.dart';

class MultiTreadedFindSolution {
  int _nThreads = 2;
  DateTime _dtStart = DateTime.now().toUtc();
  int _iComWait = 0;
  final List<Isolate?> _liFS = <Isolate>[];
  final List<Isolate> _liFindSolutions = <Isolate>[];
  final List<Capability> _capsIsolate = <Capability>[];
  int _stepCounter = 0;
  bool _bCheckQueensNoAttack = false;
  int _solutionCounter = 0;
  int _iWaitms = 0;
  bool _bResume = false;

  Future<List<dynamic>> startMultiIsolatesInBackground(int nThreads0) async {
    _nThreads = nThreads0;
    final List<ReceivePort> lreceivePort = <ReceivePort>[];
    final List<StreamQueue<dynamic>> lsqdEvents = <StreamQueue<dynamic>>[];
    final List<SendPort> lsendPort = <SendPort>[];
    _liFindSolutions.clear();
    for (int i = 0; i < _nThreads; i++) {
      if (_liFS.asMap().containsKey(i)) _liFS[i]?.kill();
      lreceivePort.add(ReceivePort());
      _liFindSolutions.add(await Isolate.spawn(_findSolutionIsolateEntryPoint, [i, lreceivePort[i].sendPort],
          paused: true, debugName: "fsThread-" + i.toString()));
      if (_liFS.asMap().containsKey(i)) {
        _liFS.removeAt(i);
        _liFS.insert(i, _liFindSolutions[i]);
      } else {
        _liFS.add(_liFindSolutions[i]);
      }
    }
    for (int i = 0; i < _nThreads; i++) {
      lsqdEvents.add(StreamQueue<dynamic>(lreceivePort[i]));
      _liFindSolutions[i].resume(_liFindSolutions[i].pauseCapability ?? Capability());
      lsendPort.add(await lsqdEvents[i].next);
    }
    return [lsendPort, lsqdEvents];
  }

  void stopAllIsolatesInBackground() {
    for (int i = 0; i < _nThreads; i++) {
      _liFindSolutions[i].kill(priority: Isolate.immediate);
    }
  }

  Future _findSolutionIsolateEntryPoint(List<dynamic> ldISP) async {
    // Send a SendPort to the main isolate so that it can send findSolution State Request to
    // this isolate.
    final receivePort = ReceivePort();
    final int iThreadNo = ldISP[0];
    final SendPort sendPort = ldISP[1];
    sendPort.send(receivePort.sendPort);

    // debugPrint("S iThreadNo: $iThreadNo");

    receivePort.listen((msg) {
      if (msg is int) {
        _iWaitms = msg;
        _bResume = true;
        _dtStart = DateTime.now().toUtc();
        _iComWait = 0;
      }
      _sendFindSolutionState(sendPort);
    });

    _stepCounter = 0;
    _solutionCounter = 0;
    int _nSubSteps = 0;
    int _iLastRowStart = 1;
    if (2 == _nThreads) {
      _nSubSteps = 4 * (pow(8, 7) as int) - 1;
      _iLastRowStart = 4 * iThreadNo + 1;
    } else if (4 == _nThreads) {
      _nSubSteps = 2 * (pow(8, 7) as int) - 1;
      _iLastRowStart = 2 * iThreadNo + 1;
    } else if (8 == _nThreads) {
      _nSubSteps = (pow(8, 7) as int) - 1;
      _iLastRowStart = iThreadNo + 1;
    }

    liPos = <int>[1, 1, 1, 1, 1, 1, 1, _iLastRowStart];

    // debugPrint("S1 iThreadNo: $iThreadNo, _stepCounter: $_stepCounter");
    await Future.delayed(Duration(milliseconds: 16 * iThreadNo));
    // debugPrint("S2 iThreadNo: $iThreadNo, _stepCounter: $_stepCounter");

    for (int i = 0; i < _nSubSteps; i++) {
      if (0 == (i % 1999)) {
        if (2 < _nThreads) {
          if (const Duration(milliseconds: 64) < DateTime.now().toUtc().difference(_dtStart)) {
            _iComWait = _iComWait * 2;
            _iComWait++;
          }
          await Future.delayed(Duration(microseconds: _iComWait));
          // debugPrint("P iThreadNo: $iThreadNo, _stepCounter: $_stepCounter");
        } else {
          await Future.delayed(const Duration(microseconds: 1));
        }
      }
      await _stepController();
    }

    _sendFindSolutionState(sendPort);
    sendPort.send(null);
  }

  void _sendFindSolutionState(SendPort sp0) {
    sp0.send([liPos, _stepCounter, _solutionCounter, _bCheckQueensNoAttack]);
  }

  void pause() {
    _capsIsolate.clear();
    for (int i = 0; i < _nThreads; i++) {
      _capsIsolate.add(_liFindSolutions[i].pause(_liFindSolutions[i].pauseCapability));
    }
  }

  void resume() {
    for (int i = 0; i < _nThreads; i++) {
      _liFindSolutions[i].resume(_capsIsolate[i]);
    }
  }

  Future<void> _stepController() async {
    // debugPrint("P1 _stepCounter: $_stepCounter");
    step();
    _stepCounter++;
    // debugPrint("P2 _stepCounter: $_stepCounter");
    _bCheckQueensNoAttack = checkQueensNoAttack();
    if (_bCheckQueensNoAttack) {
      _solutionCounter++;
      if (0 < _iWaitms) {
        for (int i = 0; i < 100; i++) {
          await Future.delayed(Duration(microseconds: _iWaitms * 10));
          if (_bResume) break;
        }
      }
      _bResume = false;
    }
  }
}
