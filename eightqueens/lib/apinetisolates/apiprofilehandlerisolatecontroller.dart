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

class ProfileHandlerAnswer {
  final Map<String, dynamic> profile;
  final Map<String, dynamic> newProfile;

  ProfileHandlerAnswer(
      {required this.profile, required this.newProfile});

  factory ProfileHandlerAnswer.fromMap(Map<String, dynamic> map) {
    return ProfileHandlerAnswer(
        profile: Map<String, dynamic>.from(map['profile'] ?? {}),
        newProfile: Map<String, dynamic>.from(map['newProfile'] ?? {}));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["profile"] = profile;
    map["newProfile"] = newProfile;
    return map;
  }
}

class Profile {
  final String userName;
  final int credit;

  Profile(
      {required this.userName, required this.credit});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
        userName: map['username'] ?? "-1",
        credit: map['credit'] ?? -1);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["username"] = userName;
    map["credit"] = credit;
    return map;
  }
}

class NewProfile {
  final String newUsername;
  final bool available;
  final bool updated;

  NewProfile(
      {required this.newUsername, required this.available, required this.updated});

  factory NewProfile.fromMap(Map<String, dynamic> map) {
    return NewProfile(
        newUsername: map['newUsername'] ?? "-1",
        available: map['available'] ?? false,
        updated: map['updated'] ?? false);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map["newUsername"] = newUsername;
    map["available"] = available;
    map["updated"] = updated;
    return map;
  }
}

class DioProfileHandlerIsolate {

  static _profileHandlerEntryPoint(List<dynamic> ldInput) async {
    if (bReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
    SendPort sendPort = ldInput[0];
    ProfileHandlerDioPost phdp =
        ProfileHandlerDioPost(apiKey: GNet.apiKeyRailwayProfile, type: ldInput[2], userId: ldInput[3], base64username: ldInput[4]);
    ProfileHandlerDioResponse phdr = await ProfileHandlerDioResponse.createProfileHandlerDioPost(
        GNet.uriProfileHandler, ldInput[1],
        mBody: phdp.toMap());
    debugPrint('apinetisolates, apiprofilehandlerisolatecontroller.dart, _profileHandlerEntryPoint() phdr: ${phdr.toMap()}');
    sendPort.send(jsonEncode(phdr.toMap())); //sending data back to main thread's function
  }

  Future<dynamic> _callProfileHandlerIsolateApi(int type0, int userId0, String base64username0, int nRetry) async {
    bool success = false;
    ProfileHandlerAnswer answer = ProfileHandlerAnswer.fromMap({"profile": {}, "newProfile": {}});
    Profile profile = Profile.fromMap({"username": "-2", "credit": -2});
    NewProfile newProfile = NewProfile.fromMap({"newUsername": "-2", "available": false, "updated": false});
    List<dynamic> errors = [];
    Map<String, dynamic> info = {};
    int apiId = 0;
    int errorCode = 0;

    final Completer cMsg = Completer();
    var receivePort = ReceivePort(); //creating new port to listen data
    const String sIsolateKey = "isolatePH";
    killNetworkProcessesByIsolateKey(sIsolateKey);
    Isolate isolatePH = await Isolate.spawn(_profileHandlerEntryPoint, [
      receivePort.sendPort,
      CertificatesStorage.getCertRailway,
      type0,
      userId0,
      base64username0
    ]); //spawing/creating new thread as isolates.
    String sIsolateId = "$sIsolateKey-$nRetry-${isolatePH.hashCode}";
    mrpiNetIsolates.putIfAbsent(sIsolateId, () => ReceivePortIsolate(receivePort: receivePort, isolate: isolatePH));
    debugPrint("apinetisolates, apiprofilehandlerisolatecontroller.dart, _callProfileHandlerIsolateApi() mrpiNetIsolates.length: ${mrpiNetIsolates.length}");
    receivePort.listen((msg) async {
      ProfileHandlerDioResponse phdr = ProfileHandlerDioResponse.fromMap(json.decode(msg));
      success = phdr.success; // success can be overwritten
      errorCode = phdr.errorCode; // errorCode can be overwritten
      try {
        answer = ProfileHandlerAnswer.fromMap(phdr.answer);
        profile = Profile.fromMap(answer.profile);
        newProfile = NewProfile.fromMap(answer.newProfile);
        info = phdr.info;
      } catch (e) {
        debugPrint(
            "apinetisolates, apiprofilehandlerisolatecontroller.dart, _callProfileHandlerIsolateApi() Exception! e: $e");
      }
      errors = phdr.errors;
      apiId = phdr.apiId;
      List<dynamic> ldMsg = [
        success,
        profile,
        newProfile,
        errors,
        info,
        apiId,
        errorCode
      ];
      cMsg.complete(ldMsg);
      receivePort.close();
      isolatePH.kill(priority: Isolate.immediate);
      mrpiNetIsolates.remove(sIsolateId);
      debugPrint('apinetisolates, apiprofilehandlerisolatecontroller.dart, _callProfileHandlerIsolateApi() msg: $msg');
    });
    return cMsg.future;
  }

  Future<dynamic> callProfileHandlerRetryIsolateApi(int type0, int userId0, String base64username0) async {
    const int nMaxRetry = nTimeoutRequestRetry4ProfileHandler;
    List<dynamic> ldValue = await _callProfileHandlerIsolateApi(type0, userId0, base64username0, 0);
    bool success = ldValue[0];
    int iN = 1;
    while (!success && nMaxRetry >= iN) {
      await Future.delayed(const Duration(milliseconds: iTimeoutRetryDelayMs));
      ldValue = await _callProfileHandlerIsolateApi(type0, userId0, base64username0, iN);
      success = ldValue[0];
      iN++;
    }
    return ldValue;
  }
}

// DBR Index App ProfileHandlerDioPost Classes and Methods

class ProfileHandlerDioPost {
  final String apiKey;
  final int type;
  final int userId;
  final String base64username;

  ProfileHandlerDioPost({required this.apiKey, required this.type, required this.userId, required this.base64username});

  factory ProfileHandlerDioPost.fromMap(Map<String, dynamic> map) {
    return ProfileHandlerDioPost(
        apiKey: map['apiKey'], type: map['type'], userId: map['userId'], base64username: map['base64username']);
  }

  Map<String,dynamic> toMap() {
    Map<String,dynamic> map = <String, dynamic>{};
    map["apiKey"] = apiKey;
    map["type"] = type;
    map["userId"] = userId;
    map["base64username"] = base64username;
    return map;
  }
}

class ProfileHandlerDioResponse {
  final bool success;
  final Map<String, dynamic> answer;
  final List<dynamic> errors;
  final Map<String, dynamic> info;
  final int apiId;
  final int errorCode;
  static const int _iApiId = 1003;

  ProfileHandlerDioResponse(
      {required this.success,
      required this.answer,
      required this.errors,
      required this.info,
      required this.apiId,
      required this.errorCode});

  factory ProfileHandlerDioResponse.fromMap(Map<String, dynamic> map) {
    return ProfileHandlerDioResponse(
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

  static Future<ProfileHandlerDioResponse> createProfileHandlerDioPost(Uri uri, List<int> liCert,
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
        debugPrint("ProfileHandlerDioResponse request data: ${jsonEncode(mBody)}");
        debugPrint("ProfileHandlerDioResponse response.data: ${response.data}");
        debugPrint("ProfileHandlerDioResponse response.data.runtimeType: ${response.data.runtimeType}");
        if (response.data is Map) {
          input = jsonEncode(response.data);
          decryptedResponse = input; // no base64 encryption in response
          debugPrint("ProfileHandlerDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
        } else if (response.data is String) {
          input = response.data.replaceAll('\r', '').replaceAll('\n', '');
          decryptedResponse = utf8.decode(base64.decode(input));
          debugPrint("ProfileHandlerDioResponse decryptedResponse: $decryptedResponse");
          mapDecodedResponse = json.decode(decryptedResponse);
          return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
        } else {
          debugPrint('ProfileHandlerDioResponse NotMapOrStringResponse.');
          mapDecodedResponse = json.decode(json.encode({
            "errors": ["NotMapOrStringResponse"],
            "apiId": _iApiId,
            "errorCode": -5
          }));
          debugPrint('ProfileHandlerDioResponse mapDecodedResponse: $mapDecodedResponse');
          return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
        }
      } else {
        debugPrint("ProfileHandlerDioResponse response.statusCode is not 200: $statusCode");
        throw Exception(response.statusMessage);
      }
    } on FormatException catch (e) {
      debugPrint('ProfileHandlerDioResponse FormatException: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["FormatException"],
        "apiId": _iApiId,
        "errorCode": -7
      }));
      return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
    } on DioException catch (e) {
      debugPrint('ProfileHandlerDioResponse DioException: $e');
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
      return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
    } on SocketException catch (_) {
      debugPrint('ProfileHandlerDioResponse SocketException.');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["SocketException"],
        "apiId": _iApiId,
        "errorCode": -6
      }));
      return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
    } catch (e) {
      debugPrint('ProfileHandlerDioResponse Exception: $e');
      mapDecodedResponse = json.decode(json.encode({
        "errors": ["Exception: $e"],
        "apiId": _iApiId,
        "errorCode": -4
      }));
      return ProfileHandlerDioResponse.fromMap(mapDecodedResponse);
    } finally {
      dio.close(force: true);
    }
  }
}
