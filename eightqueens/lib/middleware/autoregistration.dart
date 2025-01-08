import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../middleware/fsstorage.dart';
import '../apinetisolates/apiautoregisolatecontroller.dart';

class AutoRegMiddleware {

  final AutoRegLocal autoRegLocal;
  AutoRegMiddleware({required this.autoRegLocal});

  final DioAutoRegIsolate dari = DioAutoRegIsolate();

  Future<bool> callAutoReg(String sModelCode, String os, String udid, int iThreads, int iResult) async {

    bool success = false;
  
    debugPrint('middleware, autoregistration.dart, callAutoReg() iResult: $iResult');

    if (!kIsWeb) {
      if (Platform.isAndroid) { os = 'a'; } else if (Platform.isIOS) { os = 'i'; }
      if (os.isNotEmpty) {
        List<dynamic> ldValue = await dari.callRequestAutoRegRetryIsolateApi(sModelCode, os, udid, iThreads, iResult);
        success = ldValue[0];
        if (success) {
          Answer answer = ldValue[1];
          int userId = int.tryParse(answer.userId) ?? -4;
          autoRegLocal.setUserIdLocal(userId);
        }
      }
    }
    return success;
  }
}

enum EAutoReged { unknown, unreged, reged }

class AutoRegLocal {

  EAutoReged eAutoReged = EAutoReged.unknown;

  FSSLocalInt regedUserIdLocal = FSSLocalInt(fssGlobal, 'regedUserId', -3);

  final int _nUserIdLength = 15;

  int _iUserId = -10;

  int get iUserId => _iUserId;

  Future<void> initEAutoRegedFromLocal() async {
    int userId = await regedUserIdLocal.get();
    if (pow(10, _nUserIdLength - 1) <= userId && pow(10, _nUserIdLength) > userId) {
      eAutoReged = EAutoReged.reged;
    } else {
      eAutoReged = EAutoReged.unreged;
    }
    _iUserId = userId;
    debugPrint("middleware, autoregistration.dart, initEAutoRegedFromLocal() _iUserId: $_iUserId");
  }

  Future<void> setUserIdLocal(int userId0) async {
    regedUserIdLocal.set(userId0);
    int userId = -5;
    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 2));
      userId = await regedUserIdLocal.get();
      if (userId == userId0) {
        debugPrint("middleware, autoregistration.dart, setUserIdLocal() userId: $userId, i: $i");
        break;
      }
    }
    debugPrint("middleware, autoregistration.dart, setUserIdLocal() new userId0: $userId0, local get userId: $userId, previosus _iUserId: $_iUserId");
    _iUserId = userId0;
  }
}
