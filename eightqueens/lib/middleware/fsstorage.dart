import 'dart:convert';
import 'dart:io' as dart_io show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage fssGlobal =
  (!kIsWeb)
  ? (dart_io.Platform.isAndroid)
    ? const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true))
    : const FlutterSecureStorage()
  : const FlutterSecureStorage();

class FSSLocalStringList {
  final FlutterSecureStorage storage;
  final String _sKey;
  final List<String> initStringList;

  FSSLocalStringList(this.storage, this._sKey, this.initStringList);

  Future<List<String>> get() async {
    return await _getSharedPreference() ?? initStringList;
  }

  Future<List<String>?> _getSharedPreference() async {
    List<dynamic> ldValue = jsonDecode(await storage.read(key: _sKey) ?? jsonEncode(initStringList));
    List<String> lsValue = convertLd2Ls(ldValue);
    return lsValue;
  }

  List<String> convertLd2Ls(List<dynamic> ldValue) {
    List<String> lsValue = [];
    for (var element in ldValue) {
      lsValue.add(element as String);
    }
    return lsValue;
  }

  set(List<String> lsValue) async {
    await _saveSharedPreference(lsValue);
  }

  Future<void> _saveSharedPreference(List<String> lsInput) async {
    await storage.write(key: _sKey, value: jsonEncode(lsInput));
  }
}

class FSSLocalInt {
  final FlutterSecureStorage _storage;
  final String _sKey;
  final int _initInt;

  FSSLocalInt(this._storage, this._sKey, this._initInt);

  Future<int> get() async {
    return await _getSharedPreference() ?? _initInt;
  }

  Future<int?> _getSharedPreference() async {
    int iValue = jsonDecode(await _storage.read(key: _sKey) ?? jsonEncode(_initInt));
    return iValue;
  }

  set(int iValue) async {
    await _saveSharedPreference(iValue);
  }

  Future<void> _saveSharedPreference(int iInput) async {
    await _storage.write(key: _sKey, value: jsonEncode(iInput));
  }
}
