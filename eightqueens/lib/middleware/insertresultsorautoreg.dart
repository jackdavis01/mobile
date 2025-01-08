import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../middleware/deviceinfoplus.dart';
import '../middleware/autoregistration.dart';
import '../apinetisolates/apisendresultsisolatecontroller.dart';
import 'udid.dart';

class InsertResultsOrAutoRegMiddleware {

  final AutoRegLocal autoRegLocal;
  final AutoRegMiddleware autoRegMiddleware;
  InsertResultsOrAutoRegMiddleware({required this.autoRegLocal, required this.autoRegMiddleware});

  final DioInsertResultsIsolate diri = DioInsertResultsIsolate();

  final Udid oUdid = Udid();

  Future<bool> insertResultOrAutoReg(int iThreads, Duration duResult) async {

    bool success = false;

    String os = '';
    int iResult = duResult.inMilliseconds;

    debugPrint('middleware, insertresultsorautoreg.dart, insertResultAutoReg() iResult: $iResult');

    if (!kIsWeb) {
      if (Platform.isAndroid) { os = 'a'; } else if (Platform.isIOS) { os = 'i'; }
      if (os.isNotEmpty) {
        String sModelCode = await getDeviceInfoModel();
        String sUdid = await oUdid.get();
        if (EAutoReged.reged == autoRegLocal.eAutoReged) {
          int userId0 = autoRegLocal.iUserId;
          List<dynamic> ldValue = await diri.callInsertResultsRetryIsolateApi(userId0, sModelCode, os, sUdid, iThreads, iResult);
          success = ldValue[0];
        } else if (EAutoReged.unreged == autoRegLocal.eAutoReged) {
          success = await autoRegMiddleware.callAutoReg(sModelCode, os, sUdid, iThreads, iResult);
        }
      }
    }
    return success;
  }
}
