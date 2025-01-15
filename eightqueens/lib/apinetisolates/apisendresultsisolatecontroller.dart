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

class Answer {
  final String userId;
  final String userName;
  final int credit;

  Answer(
      {required this.userId, required this.userName, required this.credit});

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
        userId: map['userId'] ?? "-1",
        userName: map['userName'] ?? "-1",
        credit: map['credit'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["userId"] = userId;
    map["userName"] = userName;
    map["credit"] = credit;
    return map;
  }
}

class DioInsertResultsIsolate {

  static _insertResultsEntryPoint(List<dynamic> ldInput) async {
    if (bReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
    SendPort sendPort = ldInput[0];
    InsertResultsDioPost irdp =
        InsertResultsDioPost(apiKey: GNet.apiKeyRailway, userId: ldInput[2], modelCode: ldInput[3], os: ldInput[4],
                             build: ldInput[5], udid: ldInput[6], threads: ldInput[7], result: ldInput[8]);
    InsertResultsDioResponse irdr = await InsertResultsDioResponse.createInsertResultsDioPost(
        GNet.uriInsertResults, ldInput[1],
        mBody: irdp.toMap());
    debugPrint('apinetisolates, apisendresultsisolatecontroller.dart, _insertResultsEntryPoint() irdr: ${irdr.toMap()}');
    sendPort.send(jsonEncode(irdr.toMap())); //sending data back to main thread's function
  }

  Future<dynamic> _callInsertResultsIsolateApi(int userId0, String modelCode0, String os0, int build0, String udid0, int threads0, int result0, int nRetry) async {
    bool success = false;
    Answer answer = Answer.fromMap({"userId": "-2", "userName": "-2", "credit": 0});
    List<dynamic> errors = [];
    Map<String, dynamic> info = {};
    int apiId = 0;
    int errorCode = 0;

    final Completer cMsg = Completer();
    var receivePort = ReceivePort(); //creating new port to listen data
    const String sIsolateKey = "isolateIR";
    killNetworkProcessesByIsolateKey(sIsolateKey);
    Isolate isolateIR = await Isolate.spawn(_insertResultsEntryPoint, [
      receivePort.sendPort,
      CertificatesStorage.getCertRailway,
      userId0,
      modelCode0,
      os0,
      build0,
      udid0,
      threads0,
      result0
    ]); //spawing/creating new thread as isolates.
    String sIsolateId = "$sIsolateKey-$nRetry-${isolateIR.hashCode}";
    mrpiNetIsolates.putIfAbsent(sIsolateId, () => ReceivePortIsolate(receivePort: receivePort, isolate: isolateIR));
    debugPrint("apinetisolates, apisendresultsisolatecontroller.dart, _callInsertResultsIsolateApi() mrpiNetIsolates.length: ${mrpiNetIsolates.length}");
    receivePort.listen((msg) async {
      InsertResultsDioResponse irdr = InsertResultsDioResponse.fromMap(json.decode(msg));
      success = irdr.success; // success can be overwritten
      errorCode = irdr.errorCode; // errorCode can be overwritten
      try {
        answer = Answer.fromMap(irdr.answer);
        info = irdr.info;
        if (irdr.errors.contains("unregedUserIdOrUdid")) {
          errorCode = -101;
          success = true; // notactivated is not an error
        }
      } catch (e) {
        debugPrint(
            "apinetisolates, apisendresultsisolatecontroller.dart, _callInsertResultsIsolateApi() Exception! e: $e");
      }
      errors = irdr.errors;
      apiId = irdr.apiId;
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
      isolateIR.kill(priority: Isolate.immediate);
      mrpiNetIsolates.remove(sIsolateId);
      debugPrint('apinetisolates, apisendresultsisolatecontroller.dart, _callInsertResultsIsolateApi() msg: $msg');
    });
    return cMsg.future;
  }

  Future<dynamic> callInsertResultsRetryIsolateApi(int userId0, String modelCode0, String os0, int build0, String udid0, int threads0, int result0) async {
    const int nMaxRetry = nTimeoutRequestRetry4InsertResults;
    List<dynamic> ldValue = await _callInsertResultsIsolateApi(userId0, modelCode0, os0, build0, udid0, threads0, result0, 0);
    bool success = ldValue[0];
    int iN = 1;
    while (!success && nMaxRetry >= iN) {
      await Future.delayed(const Duration(milliseconds: iTimeoutRetryDelayMs));
      ldValue = await _callInsertResultsIsolateApi(userId0, modelCode0, os0, build0, udid0, threads0, result0, iN);
      success = ldValue[0];
      iN++;
    }
    return ldValue;
  }
}

// DBR Index App InsertResultsDioPost Classes and Methods

class InsertResultsDioPost {
  final String apiKey;
  final int userId;
  final String modelCode;
  final String os;
  final int build;
  final String udid;
  final int threads;
  final int result; // millisec

  InsertResultsDioPost({required this.apiKey, required this.userId, required this.modelCode, required this.os,
                        required this.build, required this.udid, required this.threads, required this.result});

  factory InsertResultsDioPost.fromMap(Map<String, dynamic> map) {
    return InsertResultsDioPost(
        apiKey: map['apiKey'], userId: map['userId'], modelCode: map['modelCode'], os: map['os'], build: map['build'],
        udid: map['udid'], threads: map['threads'], result: map['result']);
  }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map = <String, dynamic>{};
    map["apiKey"] = apiKey;
    map["userId"] = userId;
    map["modelCode"] = modelCode;
    map["os"] = os;
    map["build"] = build;
    map["udid"] = udid;
    map["threads"] = threads;
    map["result"] = result;
    return map;
  }
}

class InsertResultsDioResponse {
  final bool success;
  final Map<String, dynamic> answer;
  final List<dynamic> errors;
  final Map<String, dynamic> info;
  final int apiId;
  final int errorCode;
  static const int _iApiId = 1002;

  InsertResultsDioResponse(
      {required this.success,
      required this.answer,
      required this.errors,
      required this.info,
      required this.apiId,
      required this.errorCode});

  factory InsertResultsDioResponse.fromMap(Map<String, dynamic> map) {
    return InsertResultsDioResponse(
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

  static Future<InsertResultsDioResponse> createInsertResultsDioPost(Uri uri, List<int> liCert,
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
        debugPrint("InsertResultsDioResponse request data: ${jsonEncode(mBody)}");
        debugPrint("InsertResultsDioResponse response.data: ${response.data}");
        debugPrint("InsertResultsDioResponse response.data.runtimeType: ${response.data.runtimeType}");
        if (response.data is Map) {
          input = jsonEncode(response.data);
          decryptedResponse = input; // no base64 encryption in response
          debugPrint("InsertResultsDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return InsertResultsDioResponse.fromMap(mapDecodedResponse);
        } else if (response.data is String) {
          input = response.data.replaceAll('\r', '').replaceAll('\n', '');
          decryptedResponse = utf8.decode(base64.decode(input));
          debugPrint("InsertResultsDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return InsertResultsDioResponse.fromMap(mapDecodedResponse);
        } else {
          debugPrint('InsertResultsDioResponse NotMapOrStringResponse.');
          mapDecodedResponse = json.decode(json.encode({
            "errors": ["NotMapOrStringResponse"],
            "apiId": _iApiId,
            "errorCode": -5
          }));
          debugPrint('InsertResultsDioResponse mapDecodedResponse: $mapDecodedResponse');
          return InsertResultsDioResponse.fromMap(mapDecodedResponse);
        }
      } else {
        debugPrint("InsertResultsDioResponse response.statusCode is not 200: $statusCode");
        throw Exception(response.statusMessage);
      }
    } on FormatException catch (e) {
      debugPrint('InsertResultsDioResponse FormatException: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["FormatException"],
        "apiId": _iApiId,
        "errorCode": -7
      }));
      return InsertResultsDioResponse.fromMap(mapDecodedResponse);
    } on DioException catch (e) {
      debugPrint('InsertResultsDioResponse DioException: $e');
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
      return InsertResultsDioResponse.fromMap(mapDecodedResponse);
    } on SocketException catch (_) {
      debugPrint('InsertResultsDioResponse SocketException.');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["SocketException"],
        "apiId": _iApiId,
        "errorCode": -6
      }));
      return InsertResultsDioResponse.fromMap(mapDecodedResponse);
    } catch (e) {
      debugPrint('InsertResultsDioResponse Exception: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["Exception: $e"],
        "apiId": _iApiId,
        "errorCode": -4
      }));
      return InsertResultsDioResponse.fromMap(mapDecodedResponse);
    } finally {
      dio.close(force: true);
    }
  }
}
