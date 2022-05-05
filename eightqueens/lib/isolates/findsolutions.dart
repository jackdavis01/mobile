import 'dart:isolate';
import "package:async/async.dart";
import 'dart:math';
import 'stepandcheck.dart';

class FindSolutions {
  Isolate? _fSI;
  late Isolate _findSolutionsIsolate;
  late Capability _capIsolate;
  int _stepCounter = 0;
  bool _bCheckQueensNoAttack = false;
  int _solutionCounter = 0;
  int _iWaitms = 0;
  bool _bResume = false;

  Future<List<dynamic>> startIsolateInBackground() async {
    final receivePort = ReceivePort();
    _fSI?.kill();
    _findSolutionsIsolate =
        await Isolate.spawn(_findSolutionIsolateEntryPoint, receivePort.sendPort, debugName: "fsThread-single");
    _fSI = _findSolutionsIsolate;
    // Convert the ReceivePort into a StreamQueue to receive messages from the
    // spawned isolate using a pull-based interface. Events are stored in this
    // queue until they are accessed by `events.next`.
    final StreamQueue<dynamic> sqdEvents = StreamQueue<dynamic>(receivePort);
    // The first message from the spawned isolate is a SendPort. This port is
    // used to communicate with the spawned isolate.
    SendPort _sendPort = await sqdEvents.next;
    return [_sendPort, sqdEvents];
  }

  void stopIsolateInBackground() {
    _findSolutionsIsolate.kill(priority: Isolate.immediate);
  }

  Future _findSolutionIsolateEntryPoint(SendPort sendPort) async {
    // Send a SendPort to the main isolate so that it can send findSolution State Request to
    // this isolate.
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((msg) {
      if (msg is int) {
        _iWaitms = msg;
        _bResume = true;
      }
      _sendFindSolutionState(sendPort);
    });

    _stepCounter = 0;
    _solutionCounter = 0;
    liPos = <int>[1, 1, 1, 1, 1, 1, 1, 1];
    for (int i = 0; i < pow(8, 8) - 1; i++) {
      await _stepDisplay();
      if (0 == (i % 997)) {
        await Future.delayed(Duration.zero);
      }
    }

    _sendFindSolutionState(sendPort);
    sendPort.send(null);
  }

  void _sendFindSolutionState(SendPort sp0) {
    sp0.send([liPos, _stepCounter, _solutionCounter, _bCheckQueensNoAttack]);
  }

  void pause() {
    _capIsolate = _findSolutionsIsolate.pause(_findSolutionsIsolate.pauseCapability);
  }

  void resume() {
    _findSolutionsIsolate.resume(_capIsolate);
  }

  Future<void> _stepDisplay() async {
    step();
    _stepCounter++;
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
