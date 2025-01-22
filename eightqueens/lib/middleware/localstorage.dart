import 'package:shared_preferences/shared_preferences.dart';

class LocalStringList {
  final SharedPreferences storage;
  final String _sKey;
  final List<String> initStringList;

  LocalStringList(this.storage, this._sKey, this.initStringList);

  Future<List<String>> get() async {
    return await _getSharedPreference() ?? initStringList;
  }

  Future<List<String>?> _getSharedPreference() async {
    List<dynamic> ldValue = storage.getStringList(_sKey) ?? initStringList;
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
    await storage.setStringList(_sKey, lsInput);
  }
}
