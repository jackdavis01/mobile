import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../middleware/deviceinfoplus.dart';
import '../middleware/autoregistration.dart';
import '../apinetisolates/apisendresultsisolatecontroller.dart';

class InsertResultsOrAutoRegMiddleware {

  final AutoRegLocal autoRegLocal;
  final AutoRegMiddleware autoRegMiddleware;
  InsertResultsOrAutoRegMiddleware({required this.autoRegLocal, required this.autoRegMiddleware});

  final DioInsertResultsIsolate diri = DioInsertResultsIsolate();

  Future<bool> insertResultOrAutoReg(int iBuild, int iThreads, Duration duResult) async {

    bool success = false;
    int errorCode = -100;

    String os = '';
    int iResult = duResult.inMilliseconds;

    debugPrint('middleware, insertresultsorautoreg.dart, insertResultAutoReg() iResult: $iResult');

    if (!kIsWeb) {
      if (Platform.isAndroid) { os = 'a'; } else if (Platform.isIOS) { os = 'i'; }
      if (os.isNotEmpty) {
        String sModelCode = await getDeviceInfoModel();
        String sUdid = await autoRegLocal.oUdid.get();
        if (EAutoReged.reged == autoRegLocal.eAutoReged) {
          int userId0 = autoRegLocal.iUserId;
          List<dynamic> ldValue = await diri.callInsertResultsRetryIsolateApi(userId0, sModelCode, os, iBuild, sUdid, iThreads, iResult);
          success = ldValue[0];
          errorCode = ldValue[5];
          if (-101 == errorCode) {
            const int iLS = 2;
            success = await autoRegMiddleware.callAutoReg(sModelCode, os, iBuild, sUdid, iThreads, iResult, iLS);
          }
        } else if (EAutoReged.unreged == autoRegLocal.eAutoReged) {
          const int iLS = 1;
          success = await autoRegMiddleware.callAutoReg(sModelCode, os, iBuild, sUdid, iThreads, iResult, iLS);
        }
      }
    }
    return success;
  }
}
