import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import '../middleware/fsstorage.dart';
import '../apinetisolates/apiautoregisolatecontroller.dart';
import '../apinetisolates/apiautoregtrackingisolatecontroller.dart';
import 'udid.dart';

class AutoRegMiddleware {

  final AutoRegLocal autoRegLocal;
  AutoRegMiddleware({required this.autoRegLocal});

  final DioAutoRegIsolate dari = DioAutoRegIsolate();

  Future<bool> callAutoReg(String sModelCode, String os, int build, String udid, int iThreads, int iResult, int ls) async {

    bool success = false;
  
    debugPrint('middleware, autoregistration.dart, callAutoReg() iResult: $iResult');

    if (!kIsWeb) {
      if (Platform.isAndroid) { os = 'a'; } else if (Platform.isIOS) { os = 'i'; }
      if (os.isNotEmpty) {
        List<dynamic> ldValue = await dari.callRequestAutoRegRetryIsolateApi(sModelCode, os, build, udid, iThreads, iResult);
        success = ldValue[0];
        if (success) {
          AutoRegAnswer answer = ldValue[1];
          int userId = int.tryParse(answer.userId) ?? -4;
          autoRegLocal.setUserIdLocal(userId, udid, ls);
          String userName = answer.userName;
          autoRegLocal.setUserNameLocal(userName);
          int userCrown = answer.credit;
          autoRegLocal.setUserCrownLocal(userCrown);
        }
      }
    }
    return success;
  }
}

enum EAutoReged { unknown, unreged, reged }

class AutoRegLocal {

  final Udid oUdid = Udid();

  EAutoReged eAutoReged = EAutoReged.unknown;

  FSSLocalInt regedUserIdLocal = FSSLocalInt(fssGlobal, 'regedUserId', -3);
  static const String sMe = "Me";
  FSSLocalString regedUserNameLocal = FSSLocalString(fssGlobal, 'regedUserName', sMe);
  FSSLocalInt regedUserCrownLocal = FSSLocalInt(fssGlobal, 'regedUserCrown', 0);

  final DioAutoRegTrackingIsolate darti = DioAutoRegTrackingIsolate();

  final int _nUserIdLength = 15;

  int _iUserId = -10;

  int getUserId() => _iUserId;

  Future<void> initEAutoRegedFromLocal() async {
    await _clearSecureStorageUserIdOnReinstall();
    int userId = await regedUserIdLocal.get();
    await _setEAutoReged(userId);
    _iUserId = userId;
    debugPrint("middleware, autoregistration.dart, initEAutoRegedFromLocal() _iUserId: $_iUserId");
  }

  Future<void> _clearSecureStorageUserIdOnReinstall() async {
    String key = 'hasRunBefore';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(!(prefs.getBool(key) ?? false )) {
      int ls = 0;
      int time = 0;
      int userId = -6;
      int iPreviousUserId = await regedUserIdLocal.get();
      const resetUserId = -20;
      await regedUserIdLocal.set(resetUserId);
      prefs.setBool(key, true);
      outerLoop1:
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 100; j++) {
          int iDelayMs = pow(2, i).truncate();
          time = time + iDelayMs;
          await Future.delayed(Duration(milliseconds: iDelayMs));
          userId = await regedUserIdLocal.get();
          if (resetUserId == userId) {
            ls = 1;
            debugPrint("middleware, autoregistration.dart, _clearSecureStorageUserIdOnReinstall() iPreviousUserId: $iPreviousUserId, userId: $userId, i: $i, j: $j, time: $time");
            break outerLoop1;
          }
        }
      }
      if (inRangeUserId(iPreviousUserId)) {
        const int type = 2; // uninstalled userId sending
        String sUdid = await oUdid.get();
        List<dynamic> ldValue = await darti.callAutoRegTrackingRetryIsolateApi(type, iPreviousUserId, ls, time, sUdid);
        debugPrint("middleware, autoregistration.dart, _clearSecureStorageUserIdOnReinstall() ldValue: $ldValue");
      }
      debugPrint("middleware, autoregistration.dart, _clearSecureStorageUserIdOnReinstall() new resetUserId: $resetUserId, local get userId: $userId");
    }
  }

  bool inRangeUserId(int userId0) => (pow(10, _nUserIdLength - 1) <= userId0 && pow(10, _nUserIdLength) > userId0);

  Future<void> _setEAutoReged(int userId0) async {
    if (inRangeUserId(userId0)) {
      eAutoReged = EAutoReged.reged;
    } else {
      eAutoReged = EAutoReged.unreged;
    }
  }

  Future<void> setUserIdLocal(int userId0, String udid, int ls0) async {
    regedUserIdLocal.set(userId0);
    int ls = 0;
    int time = 0;
    int userId = -5;
    outerLoop2:
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 100; j++) {
        int iDelayMs = pow(2, i).truncate();
        time = time + iDelayMs;
        await Future.delayed(Duration(milliseconds: iDelayMs));
        userId = await regedUserIdLocal.get();
        if (userId == userId0) {
          ls = ls0;
          debugPrint("middleware, autoregistration.dart, setUserIdLocal() userId: $userId, i: $i, iLS0: $ls0");
          break outerLoop2;
        }
      }
    }
    if (inRangeUserId(userId0)) {
      const int type = 1;
      List<dynamic> ldValue = await darti.callAutoRegTrackingRetryIsolateApi(type, userId0, ls, time, udid);
      debugPrint("middleware, autoregistration.dart, setUserIdLocal() ldValue: $ldValue");
    }
    debugPrint("middleware, autoregistration.dart, setUserIdLocal() new userId0: $userId0, local get userId: $userId, previosus _iUserId: $_iUserId");
    _iUserId = userId0;
    await _setEAutoReged(_iUserId);
  }

  void setUserNameLocal(String sUserName) { regedUserNameLocal.set(sUserName); }

  Future<String> getUserName() async => await regedUserNameLocal.get();

  void setUserCrownLocal(int iCrown) { regedUserCrownLocal.set(iCrown); }

  Future<int> getUserCrown() async => await regedUserCrownLocal.get();

}
