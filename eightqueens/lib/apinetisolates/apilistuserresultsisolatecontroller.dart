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

class UserResultsAnswer {
  final int me;
  final String userName;
  final String modelName;
  final int runCount;
  final int bestResult;
  final int averageResult;
  final int worstResult;

  UserResultsAnswer(
    {required this.me, required this.userName, required this.modelName, required this.runCount, required this.bestResult, required this.averageResult, required this.worstResult});

  factory UserResultsAnswer.fromMap(Map<String, dynamic> map) {
    return UserResultsAnswer(
      me: map['me'] ?? -1,
      userName: map['username'] ?? "-1",
      modelName: map['model_name'] ?? "-1",
      runCount: map['run_count'] ?? 0,
      bestResult: map['best_result'] ?? 10000,
      averageResult: map['average_result'] ?? 10000,
      worstResult: map['worst_result'] ?? 10000);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["me"] = me;
    map["username"] = userName;
    map["model_name"] = modelName;
    map["run_count"] = runCount;
    map["best_result"] = bestResult;
    map["average_result"] = averageResult;
    map["worst_result"] = worstResult;
    return map;
  }
}

class DioListUserResultsIsolate {

  static _listUserResultsEntryPoint(List<dynamic> ldInput) async {
    if (bReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
    SendPort sendPort = ldInput[0];
    ListUserResultsDioPost lurdp =
        ListUserResultsDioPost(apiKey: GNet.apiKeyRailwayListUR, userId: ldInput[2], interval: ldInput[3], threads: ldInput[4], limit: ldInput[5]);
    ListUserResultsDioResponse lurdr = await ListUserResultsDioResponse.createListUserResultsDioPost(
        GNet.uriListUserResults, ldInput[1],
        mBody: lurdp.toMap());
    debugPrint('apinetisolates, apilistuserresultsisolatecontroller.dart, _listUserResultsEntryPoint() lurdr: ${lurdr.toMap()}');
    sendPort.send(jsonEncode(lurdr.toMap())); //sending data back to main thread's function
  }

  Future<dynamic> _callListUserResultsIsolateApi(int userId0, int interval0, int threads0, int limit0, int nRetry) async {
    bool success = false;
    List<UserResultsAnswer> list = [];
    Map<String, List<UserResultsAnswer>> answer = { "list": list };
    List<dynamic> errors = [];
    Map<String, dynamic> info = {};
    int apiId = 0;
    int errorCode = 0;

    final Completer cMsg = Completer();
    var receivePort = ReceivePort(); //creating new port to listen data
    const String sIsolateKey = "isolateLUR";
    killNetworkProcessesByIsolateKey(sIsolateKey);
    Isolate isolateLUR = await Isolate.spawn(_listUserResultsEntryPoint, [
      receivePort.sendPort,
      CertificatesStorage.getCertRailway,
      userId0,
      interval0,
      threads0,
      limit0
    ]); //spawing/creating new thread as isolates.
    String sIsolateId = "$sIsolateKey-$nRetry-${isolateLUR.hashCode}";
    mrpiNetIsolates.putIfAbsent(sIsolateId, () => ReceivePortIsolate(receivePort: receivePort, isolate: isolateLUR));
    debugPrint("apinetisolates, apilistuserresultsisolatecontroller.dart, _callListUserResultsIsolateApi() mrpiNetIsolates.length: ${mrpiNetIsolates.length}");
    receivePort.listen((msg) async {
      ListUserResultsDioResponse lurdr = ListUserResultsDioResponse.fromMap(json.decode(msg));
      success = lurdr.success; // success can be overwritten
      errorCode = lurdr.errorCode; // errorCode can be overwritten
      try {
        List<dynamic> dList = lurdr.answer['list'];
        for (var element in dList) {
          list.add(UserResultsAnswer.fromMap(element));
        }
        answer = { "list": list };
        info = lurdr.info;
      } catch (e) {
        debugPrint("apinetisolates, apilistuserresultsisolatecontroller.dart, _callListUserResultsIsolateApi() Exception! e: $e");
      }
      errors = lurdr.errors;
      apiId = lurdr.apiId;
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
      isolateLUR.kill(priority: Isolate.immediate);
      mrpiNetIsolates.remove(sIsolateId);
      debugPrint('apinetisolates, apilistuserresultsisolatecontroller.dart, _callListUserResultsIsolateApi() msg: $msg');
    });
    return cMsg.future;
  }

  Future<dynamic> callListUserResultsRetryIsolateApi(int userId0, int interval0, int threads0, int limit0) async {
    const int nMaxRetry = nTimeoutRequestRetry4ListUserResults;
    List<dynamic> ldValue = await _callListUserResultsIsolateApi(userId0, interval0, threads0, limit0, 0);
    bool success = ldValue[0];
    int iN = 1;
    while (!success && nMaxRetry >= iN) {
      await Future.delayed(const Duration(milliseconds: iTimeoutRetryDelayMs));
      ldValue = await _callListUserResultsIsolateApi(userId0, interval0, threads0, limit0, iN);
      success = ldValue[0];
      iN++;
    }
    return ldValue;
  }
}

// DBR Index App ListUserResultsDioPost Classes and Methods

class ListUserResultsDioPost {
  final String apiKey;
  final int userId;
  final int interval;
  final int threads;
  final int limit;

  ListUserResultsDioPost({required this.apiKey, required this.userId, required this.interval, required this.threads, required this.limit});

  factory ListUserResultsDioPost.fromMap(Map<String, dynamic> map) {
    return ListUserResultsDioPost(
        apiKey: map['apiKey'], userId: map['userId'], interval: map['interval'], threads: map['threads'], limit: map['limit']);
  }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map = <String, dynamic>{};
    map["apiKey"] = apiKey;
    map["userId"] = userId;
    map["interval"] = interval;
    map["threads"] = threads;
    map["limit"] = limit;
    return map;
  }
}

class ListUserResultsDioResponse {
  final bool success;
  final Map<String, dynamic> answer;
  final List<dynamic> errors;
  final Map<String, dynamic> info;
  final int apiId;
  final int errorCode;
  static const int _iApiId = 1004;

  ListUserResultsDioResponse(
      {required this.success,
      required this.answer,
      required this.errors,
      required this.info,
      required this.apiId,
      required this.errorCode});

  factory ListUserResultsDioResponse.fromMap(Map<String, dynamic> map) {
    return ListUserResultsDioResponse(
        success: map['success'] ?? false,
        answer: map['answer'] ?? { "list": []},
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

  static Future<ListUserResultsDioResponse> createListUserResultsDioPost(Uri uri, List<int> liCert,
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
        debugPrint("ListUserResultsDioResponse request data: ${jsonEncode(mBody)}");
        debugPrint("ListUserResultsDioResponse response.data: ${response.data}");
        debugPrint("ListUserResultsDioResponse response.data.runtimeType: ${response.data.runtimeType}");
        if (response.data is Map) {
          input = jsonEncode(response.data);
          decryptedResponse = input; // no base64 encryption in response
          debugPrint("ListUserResultsDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
        } else if (response.data is String) {
          input = response.data.replaceAll('\r', '').replaceAll('\n', '');
          decryptedResponse = utf8.decode(base64.decode(input));
          debugPrint("ListUserResultsDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
        } else {
          debugPrint('ListUserResultsDioResponse NotMapOrStringResponse.');
          mapDecodedResponse = json.decode(json.encode({
            "errors": ["NotMapOrStringResponse"],
            "apiId": _iApiId,
            "errorCode": -5
          }));
          debugPrint('ListUserResultsDioResponse mapDecodedResponse: $mapDecodedResponse');
          return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
        }
      } else {
        debugPrint("ListUserResultsDioResponse response.statusCode is not 200: $statusCode");
        throw Exception(response.statusMessage);
      }
    } on FormatException catch (e) {
      debugPrint('ListUserResultsDioResponse FormatException: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["FormatException"],
        "apiId": _iApiId,
        "errorCode": -7
      }));
      return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
    } on DioException catch (e) {
      debugPrint('ListUserResultsDioResponse DioException: $e');
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
      return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
    } on SocketException catch (_) {
      debugPrint('ListUserResultsDioResponse SocketException.');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["SocketException"],
        "apiId": _iApiId,
        "errorCode": -6
      }));
      return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
    } catch (e) {
      debugPrint('ListUserResultsDioResponse Exception: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["Exception: $e"],
        "apiId": _iApiId,
        "errorCode": -4
      }));
      return ListUserResultsDioResponse.fromMap(mapDecodedResponse);
    } finally {
      dio.close(force: true);
    }
  }
}
