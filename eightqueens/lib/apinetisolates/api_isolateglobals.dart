import 'dart:isolate';
import 'package:flutter/foundation.dart' show debugPrint;

class ReceivePortIsolate {
  final ReceivePort receivePort;
  final Isolate isolate;
  ReceivePortIsolate({required this.receivePort, required this.isolate});
}

typedef MapReceivePortIsolate = Map<String, ReceivePortIsolate>;

MapReceivePortIsolate mrpiNetIsolates = {};

bool _enableNetworkProcesses = true;

bool get getEnableNetworkProcesses => _enableNetworkProcesses;

enableNetworkProcesses() {
  _enableNetworkProcesses = true;
}

disableNetworkProcesses() {
  _enableNetworkProcesses = false;
}

disableNetworkProcessesAndKillAllNetworkIsolates() {
  disableNetworkProcesses();
  for (String sIsolateKey in mrpiNetIsolates.keys) {
    debugPrint(
        "api_isolateglobals.dart, disableNetworkProcessesAndKillAllNetworkIsolates(), mrpiNetIsolates.size(): ${mrpiNetIsolates.keys.length}");
    mrpiNetIsolates[sIsolateKey]?.receivePort.close();
    mrpiNetIsolates[sIsolateKey]?.isolate.kill(priority: Isolate.immediate);
    debugPrint(
        "api_isolateglobals.dart, disableNetworkProcessesAndKillAllNetworkIsolates(), mrpiNetIsolates.size(): ${mrpiNetIsolates.keys.length},  killed: sIsolateKey: $sIsolateKey");
  }
  mrpiNetIsolates.clear();
  debugPrint(
      "api_isolateglobals.dart, disableNetworkProcessesAndKillAllNetworkIsolates(), mrpiNetIsolates.clear() & size(): ${mrpiNetIsolates.keys.length}");
}

killNetworkProcessesByIsolateKey(final String sIKey) {
  for (String sIsolateKey in mrpiNetIsolates.keys) {
    List<String> lsIsolateKey = sIsolateKey.split('-');
    if (sIKey == lsIsolateKey[0]) {
      debugPrint(
          "api_isolateglobals.dart, killNetworkProcessesByIsolateKey(), mrpiNetIsolates.size(): ${mrpiNetIsolates.keys.length}");
      mrpiNetIsolates[sIsolateKey]?.receivePort.close();
      mrpiNetIsolates[sIsolateKey]?.isolate.kill(priority: Isolate.immediate);
      debugPrint(
          "api_isolateglobals.dart, killNetworkProcessesByIsolateKey(), mrpiNetIsolates.size(): ${mrpiNetIsolates.keys.length}, killed: sIKey: $sIKey, sIsolateKey: $sIsolateKey");
    }
  }
}
