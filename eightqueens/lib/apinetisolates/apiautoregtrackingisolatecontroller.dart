import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';
import '../parameters/globals.dart';
import '../parameters/net.dart' if (dart.library.html) '../parameters/nonet.dart';
import '../parameters/globaldio.dart' if (dart.library.html) '../parameters/noglobaldio.dart';
import 'api_isolateglobals.dart';
import '../middleware/certificate.dart';

class AutoRegTrackingAnswer {
  final String userId;
  final bool updated;
  final bool inserted;

  AutoRegTrackingAnswer(
      {required this.userId, required this.updated, required this.inserted});

  factory AutoRegTrackingAnswer.fromMap(Map<String, dynamic> map) {
    return AutoRegTrackingAnswer(
        userId: map['userId'] ?? "-1",
        updated: map['updated'] ?? false,
        inserted: map['inserted'] ?? false);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["userId"] = userId;
    map["updated"] = updated;
    map["inserted"] = inserted;
    return map;
  }
}

class DioAutoRegTrackingIsolate {

  static _autoRegTrackingEntryPoint(List<dynamic> ldInput) async {
    if (bReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
    SendPort sendPort = ldInput[0];
    AutoRegTrackingDioPost artdp =
        AutoRegTrackingDioPost(apiKey: GNet.apiKeyRailwayTracking, type: ldInput[2], userId: ldInput[3], ls: ldInput[4], time: ldInput[5], udid: ldInput[6]);
    AutoRegTrackingDioResponse artdr = await AutoRegTrackingDioResponse.createAutoRegTrackingDioPost(
        GNet.uriAutoRegTracking, ldInput[1],
        mBody: artdp.toMap());
    debugPrint('apinetisolates, apiautoregtrackingisolatecontroller.dart, _autoRegTrackingEntryPoint() artdr: ${artdr.toMap()}');
    sendPort.send(jsonEncode(artdr.toMap())); //sending data back to main thread's function
  }

  Future<dynamic> _callAutoRegTrackingIsolateApi(int type0, int userId0, int ls0, int time0, String udid0, int nRetry) async {
    bool success = false;
    AutoRegTrackingAnswer answer = AutoRegTrackingAnswer.fromMap({"userId": "-2", "userName": "-2", "credit": 0});
    List<dynamic> errors = [];
    Map<String, dynamic> info = {};
    int apiId = 0;
    int errorCode = 0;

    final Completer cMsg = Completer();
    var receivePort = ReceivePort(); //creating new port to listen data
    const String sIsolateKey = "isolateART";
    killNetworkProcessesByIsolateKey(sIsolateKey);
    Isolate isolateART = await Isolate.spawn(_autoRegTrackingEntryPoint, [
      receivePort.sendPort,
      CertificatesStorage.getCertRailway,
      type0,
      userId0,
      ls0,
      time0,
      udid0
    ]); //spawing/creating new thread as isolates.
    String sIsolateId = "$sIsolateKey-$nRetry-${isolateART.hashCode}";
    mrpiNetIsolates.putIfAbsent(sIsolateId, () => ReceivePortIsolate(receivePort: receivePort, isolate: isolateART));
    debugPrint("apinetisolates, apiautoregtrackingisolatecontroller.dart, _callAutoRegTrackingIsolateApi() mrpiNetIsolates.length: ${mrpiNetIsolates.length}");
    receivePort.listen((msg) async {
      AutoRegTrackingDioResponse artdr = AutoRegTrackingDioResponse.fromMap(json.decode(msg));
      success = artdr.success; // success can be overwritten
      errorCode = artdr.errorCode; // errorCode can be overwritten
      try {
        answer = AutoRegTrackingAnswer.fromMap(artdr.answer);
        info = artdr.info;
      } catch (e) {
        debugPrint(
            "apinetisolates, apiautoregtrackingisolatecontroller.dart, _callAutoRegTrackingIsolateApi() Exception! e: $e");
      }
      errors = artdr.errors;
      apiId = artdr.apiId;
      List<dynamic> ldMsg = [
        success,
        answer,
        errors,
        info,
        apiId,
        errorCode
      ];
      cMsg.complete(ldMsg);
      receivePort.close();
      isolateART.kill(priority: Isolate.immediate);
      mrpiNetIsolates.remove(sIsolateId);
      debugPrint('apinetisolates, apiautoregtrackingisolatecontroller.dart, _callAutoRegTrackingIsolateApi() msg: $msg');
    });
    return cMsg.future;
  }

  Future<dynamic> callAutoRegTrackingRetryIsolateApi(int type0, int userId0, int ls0, int time0, String udid0) async {
    const int nMaxRetry = nTimeoutRequestRetry4AutoRegTracking;
    List<dynamic> ldValue = await _callAutoRegTrackingIsolateApi(type0, userId0, ls0, time0, udid0, 0);
    bool success = ldValue[0];
    int iN = 1;
    while (!success && nMaxRetry >= iN) {
      await Future.delayed(const Duration(milliseconds: iTimeoutRetryDelayMs));
      ldValue = await _callAutoRegTrackingIsolateApi(type0, userId0, ls0, time0, udid0, iN);
      success = ldValue[0];
      iN++;
    }
    return ldValue;
  }
}

// DBR Index App AutoRegTrackingDioPost Classes and Methods

class AutoRegTrackingDioPost {
  final String apiKey;
  final int type;
  final int userId;
  final int ls;
  final int time; // millisec
  final String udid;

  AutoRegTrackingDioPost({required this.apiKey, required this.type, required this.userId, required this.ls, required this.time, required this.udid});

  factory AutoRegTrackingDioPost.fromMap(Map<String, dynamic> map) {
    return AutoRegTrackingDioPost(
        apiKey: map['apiKey'], type: map['type'], userId: map['userId'], ls: map['ls'], time: map['time'], udid: map['udid']);
  }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map = <String, dynamic>{};
    map["apiKey"] = apiKey;
    map["type"] = type;
    map["userId"] = userId;
    map["ls"] = ls;
    map["time"] = time;
    map["udid"] = udid;
    return map;
  }
}

class AutoRegTrackingDioResponse {
  final bool success;
  final Map<String, dynamic> answer;
  final List<dynamic> errors;
  final Map<String, dynamic> info;
  final int apiId;
  final int errorCode;
  static const int _iApiId = 1003;

  AutoRegTrackingDioResponse(
      {required this.success,
      required this.answer,
      required this.errors,
      required this.info,
      required this.apiId,
      required this.errorCode});

  factory AutoRegTrackingDioResponse.fromMap(Map<String, dynamic> map) {
    return AutoRegTrackingDioResponse(
        success: map['success'] ?? false,
        answer: map['answer'] ?? {},
        errors: map['errors'] ?? <String>[],
        info: map['info'] ?? {},
        apiId: map['apiId'] ?? _iApiId,
        errorCode: map['errorCode'] ?? 0);
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["success"] = success;
    map["answer"] = answer;
    map["errors"] = errors;
    map["info"] = info;
    map["apiId"] = apiId;
    map["errorCode"] = errorCode;
    return map;
  }

  static Future<AutoRegTrackingDioResponse> createAutoRegTrackingDioPost(Uri uri, List<int> liCert,
      {required Map mBody}) async {
    DioResponse response;
    String input, decryptedResponse;
    Map<String, dynamic> mapDecodedResponse;
    final dio = DioHttp(dioOptions);
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
        HttpClient(context: CertificateSecurityContext.get(liCert))
          ..maxConnectionsPerHost = 16
          /*..badCertificateCallback = (X509Certificate cert, String host, int port) => true*/;
    try {
      response = await dio.postUri(uri, data: jsonEncode(mBody));
      final int statusCode = response.statusCode ?? -1;
      if (statusCode == 200) {
        debugPrint("AutoRegTrackingDioResponse request data: ${jsonEncode(mBody)}");
        debugPrint("AutoRegTrackingDioResponse response.data: ${response.data}");
        debugPrint("AutoRegTrackingDioResponse response.data.runtimeType: ${response.data.runtimeType}");
        if (response.data is Map) {
          input = jsonEncode(response.data);
          decryptedResponse = input; // no base64 encryption in response
          debugPrint("AutoRegTrackingDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
        } else if (response.data is String) {
          input = response.data.replaceAll('\r', '').replaceAll('\n', '');
          decryptedResponse = utf8.decode(base64.decode(input));
          debugPrint("AutoRegTrackingDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
        } else {
          debugPrint('AutoRegTrackingDioResponse NotMapOrStringResponse.');
          mapDecodedResponse = json.decode(json.encode({
            "errors": ["NotMapOrStringResponse"],
            "apiId": _iApiId,
            "errorCode": -5
          }));
          debugPrint('AutoRegTrackingDioResponse mapDecodedResponse: $mapDecodedResponse');
          return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
        }
      } else {
        debugPrint("AutoRegTrackingDioResponse response.statusCode is not 200: $statusCode");
        throw Exception(response.statusMessage);
      }
    } on FormatException catch (e) {
      debugPrint('AutoRegTrackingDioResponse FormatException: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["FormatException"],
        "apiId": _iApiId,
        "errorCode": -7
      }));
      return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
    } on DioException catch (e) {
      debugPrint('AutoRegTrackingDioResponse DioException: $e');
      if (e.type == DioExceptionType.connectionTimeout) {
        mapDecodedResponse = json.decode(json.encode({
          "errors": ["DioException: ${e.type}"],
          "apiId": _iApiId,
          "errorCode": -1
        }));
      } else if (e.type == DioExceptionType.receiveTimeout) {
        mapDecodedResponse = json.decode(json.encode({
          "errors": ["DioException: ${e.type}"],
          "apiId": _iApiId,
          "errorCode": -2
        }));
      } else {
        mapDecodedResponse = json.decode(json.encode({
          "errors": ["DioException: ${e.type}"],
          "apiId": _iApiId,
          "errorCode": -3
        }));
      }
      return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
    } on SocketException catch (_) {
      debugPrint('AutoRegTrackingDioResponse SocketException.');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["SocketException"],
        "apiId": _iApiId,
        "errorCode": -6
      }));
      return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
    } catch (e) {
      debugPrint('AutoRegTrackingDioResponse Exception: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["Exception: $e"],
        "apiId": _iApiId,
        "errorCode": -4
      }));
      return AutoRegTrackingDioResponse.fromMap(mapDecodedResponse);
    } finally {
      dio.close(force: true);
    }
  }
}
