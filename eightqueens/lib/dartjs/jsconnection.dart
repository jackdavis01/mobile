// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

void jsCallStartWorker(bool bRelease) {
  js.context.callMethod('startWorker', [bRelease]);
}

void jsCallBackSendMessage2Dart(Function sendMessage2Dart) {
  js.context['sendMessage2Dart'] = sendMessage2Dart;
}

void jsStopWorker() {
  js.context.callMethod('stopWorker', []);
}

void jsStartMultithreadedWorkers(int nThreadsStarted, int waitms, bool bRelease) {
  js.context.callMethod('startMultithreadedWorkers', [nThreadsStarted, waitms, bRelease]);
}

void jsSendMultithreadedMessage2Dart(Function sendMultithreadedMessage2Dart) {
  js.context['sendMultithreadedMessage2Dart'] = sendMultithreadedMessage2Dart;
}

void jsStopMultithreadedWorkers() {
  js.context.callMethod('stopMultithreadedWorkers', []);
}

void jsPauseWorker() {
  js.context.callMethod('pauseWorker', []);
}

void jsPauseMultithreadedWorkers() {
  js.context.callMethod('pauseMultithreadedWorkers', []);
}

void jsResumeWorker() {
  js.context.callMethod('resumeWorker', []);
}

void jsResumeMultithreadedWorkers() {
  js.context.callMethod('resumeMultithreadedWorkers', []);
}

void jsReceiveMsgFromDart(int waitms) {
  js.context.callMethod('receiveMsgFromDart', [waitms]);
}

void jsReceiveMultithreadedMsgFromDart(int iPort, int waitms) {
  js.context.callMethod('receiveMultithreadedMsgFromDart', [iPort, waitms]);
}
