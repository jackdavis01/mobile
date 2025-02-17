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

class ModelResultsAnswer {
  final String modelName;
  final int runCount;
  final int bestResult;
  final int averageResult;
  final int worstResult;

  ModelResultsAnswer(
    {required this.modelName, required this.runCount, required this.bestResult, required this.averageResult, required this.worstResult});

  factory ModelResultsAnswer.fromMap(Map<String, dynamic> map) {
    return ModelResultsAnswer(
      modelName: map['model_name'] ?? "-1",
      runCount: map['run_count'] ?? 0,
      bestResult: map['best_result'] ?? 10000,
      averageResult: map['average_result'] ?? 10000,
      worstResult: map['worst_result'] ?? 10000);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["model_name"] = modelName;
    map["run_count"] = runCount;
    map["best_result"] = bestResult;
    map["average_result"] = averageResult;
    map["worst_result"] = worstResult;
    return map;
  }
}

class DioListModelResultsIsolate {

  static _listModelResultsEntryPoint(List<dynamic> ldInput) async {
    if (bReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
    SendPort sendPort = ldInput[0];
    ListModelResultsDioPost lmrdp =
        ListModelResultsDioPost(apiKey: GNet.apiKeyRailwayListMR, userId: ldInput[2], interval: ldInput[3], threads: ldInput[4], order: ldInput[5], orderDirection: ldInput[6], limit: ldInput[7]);
    ListModelResultsDioResponse lmrdr = await ListModelResultsDioResponse.createListModelResultsDioPost(
        GNet.uriListModelResults, ldInput[1],
        mBody: lmrdp.toMap());
    debugPrint('apinetisolates, apilistmodelresultsisolatecontroller.dart, _listModelResultsEntryPoint() lmrdr: ${lmrdr.toMap()}');
    sendPort.send(jsonEncode(lmrdr.toMap())); //sending data back to main thread's function
  }

  Future<dynamic> _callListModelResultsIsolateApi(int userId0, int interval0, int threads0, int order0, int orderDirection0, int limit0, int nRetry) async {
    bool success = false;
    List<ModelResultsAnswer> list = [];
    Map<String, List<ModelResultsAnswer>> answer = { "list": list };
    List<dynamic> errors = [];
    Map<String, dynamic> info = {};
    int apiId = 0;
    int errorCode = 0;

    final Completer cMsg = Completer();
    var receivePort = ReceivePort(); //creating new port to listen data
    const String sIsolateKey = "isolateLMR";
    killNetworkProcessesByIsolateKey(sIsolateKey);
    Isolate isolateLMR = await Isolate.spawn(_listModelResultsEntryPoint, [
      receivePort.sendPort,
      CertificatesStorage.getCertRailway,
      userId0,
      interval0,
      threads0,
      order0,
      orderDirection0,
      limit0
    ]); //spawing/creating new thread as isolates.
    String sIsolateId = "$sIsolateKey-$nRetry-${isolateLMR.hashCode}";
    mrpiNetIsolates.putIfAbsent(sIsolateId, () => ReceivePortIsolate(receivePort: receivePort, isolate: isolateLMR));
    debugPrint("apinetisolates, apilistmodelresultsisolatecontroller.dart, _callListModelResultsIsolateApi() mrpiNetIsolates.length: ${mrpiNetIsolates.length}");
    receivePort.listen((msg) async {
      ListModelResultsDioResponse lmrdr = ListModelResultsDioResponse.fromMap(json.decode(msg));
      success = lmrdr.success; // success can be overwritten
      errorCode = lmrdr.errorCode; // errorCode can be overwritten
      try {
        List<dynamic> dList = lmrdr.answer['list'];
        for (var element in dList) {
          list.add(ModelResultsAnswer.fromMap(element));
        }
        answer = { "list": list };
        info = lmrdr.info;
      } catch (e) {
        debugPrint("apinetisolates, apilistmodelresultsisolatecontroller.dart, _callListModelResultsIsolateApi() Exception! e: $e");
      }
      errors = lmrdr.errors;
      apiId = lmrdr.apiId;
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
      isolateLMR.kill(priority: Isolate.immediate);
      mrpiNetIsolates.remove(sIsolateId);
      debugPrint('apinetisolates, apilistmodelresultsisolatecontroller.dart, _callListModelResultsIsolateApi() msg: $msg');
    });
    return cMsg.future;
  }

  Future<dynamic> callListModelResultsRetryIsolateApi(int userId0, int interval0, int threads0, int order0, int orderDirection0, int limit0) async {
    const int nMaxRetry = nTimeoutRequestRetry4ListModelResults;
    List<dynamic> ldValue = await _callListModelResultsIsolateApi(userId0, interval0, threads0, order0, orderDirection0, limit0, 0);
    bool success = ldValue[0];
    int iN = 1;
    while (!success && nMaxRetry >= iN) {
      await Future.delayed(const Duration(milliseconds: iTimeoutRetryDelayMs));
      ldValue = await _callListModelResultsIsolateApi(userId0, interval0, threads0, limit0, order0, orderDirection0, iN);
      success = ldValue[0];
      iN++;
    }
    return ldValue;
  }
}

// DBR Index App ListModelResultsDioPost Classes and Methods

class ListModelResultsDioPost {
  final String apiKey;
  final int userId;
  final int interval;
  final int threads;
  final int order;
  final int orderDirection;
  final int limit;

  ListModelResultsDioPost({required this.apiKey, required this.userId, required this.interval, required this.threads, required this.order, required this.orderDirection, required this.limit});

  factory ListModelResultsDioPost.fromMap(Map<String, dynamic> map) {
    return ListModelResultsDioPost(
        apiKey: map['apiKey'], userId: map['userId'], interval: map['interval'], threads: map['threads'], order: map['order'], orderDirection: map['orderDirection'], limit: map['limit']);
  }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map = <String, dynamic>{};
    map["apiKey"] = apiKey;
    map["userId"] = userId;
    map["interval"] = interval;
    map["threads"] = threads;
    map["order"] = order;
    map["orderDirection"] = orderDirection;
    map["limit"] = limit;
    return map;
  }
}

class ListModelResultsDioResponse {
  final bool success;
  final Map<String, dynamic> answer;
  final List<dynamic> errors;
  final Map<String, dynamic> info;
  final int apiId;
  final int errorCode;
  static const int _iApiId = 1005;

  ListModelResultsDioResponse(
      {required this.success,
      required this.answer,
      required this.errors,
      required this.info,
      required this.apiId,
      required this.errorCode});

  factory ListModelResultsDioResponse.fromMap(Map<String, dynamic> map) {
    return ListModelResultsDioResponse(
        success: map['success'] ?? false,
        answer: map['answer'] ?? { "list": [] },
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

  static Future<ListModelResultsDioResponse> createListModelResultsDioPost(Uri uri, List<int> liCert,
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
        debugPrint("ListModelResultsDioResponse request data: ${jsonEncode(mBody)}");
        debugPrint("ListModelResultsDioResponse response.data: ${response.data}");
        debugPrint("ListModelResultsDioResponse response.data.runtimeType: ${response.data.runtimeType}");
        if (response.data is Map) {
          input = jsonEncode(response.data);
          decryptedResponse = input; // no base64 encryption in response
          debugPrint("ListModelResultsDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
        } else if (response.data is String) {
          input = response.data.replaceAll('\r', '').replaceAll('\n', '');
          decryptedResponse = utf8.decode(base64.decode(input));
          debugPrint("ListModelResultsDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
        } else {
          debugPrint('ListModelResultsDioResponse NotMapOrStringResponse.');
          mapDecodedResponse = json.decode(json.encode({
            "errors": ["NotMapOrStringResponse"],
            "apiId": _iApiId,
            "errorCode": -5
          }));
          debugPrint('ListModelResultsDioResponse mapDecodedResponse: $mapDecodedResponse');
          return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
        }
      } else {
        debugPrint("ListModelResultsDioResponse response.statusCode is not 200: $statusCode");
        throw Exception(response.statusMessage);
      }
    } on FormatException catch (e) {
      debugPrint('ListModelResultsDioResponse FormatException: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["FormatException"],
        "apiId": _iApiId,
        "errorCode": -7
      }));
      return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
    } on DioException catch (e) {
      debugPrint('ListModelResultsDioResponse DioException: $e');
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
      return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
    } on SocketException catch (_) {
      debugPrint('ListModelResultsDioResponse SocketException.');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["SocketException"],
        "apiId": _iApiId,
        "errorCode": -6
      }));
      return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
    } catch (e) {
      debugPrint('ListModelResultsDioResponse Exception: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["Exception: $e"],
        "apiId": _iApiId,
        "errorCode": -4
      }));
      return ListModelResultsDioResponse.fromMap(mapDecodedResponse);
    } finally {
      dio.close(force: true);
    }
  }
}
