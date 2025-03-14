import 'package:shared_preferences/shared_preferences.dart';

class SpGlobal {
  static late final SharedPreferences pref;
  static bool _init = false;
  static Future init() async {
    if (_init) return;
    pref = await SharedPreferences.getInstance();
    _init = true;
    return pref;
  }
}

late SharedPreferences spGlobal;

LocalString lsBFeatureDiscoveryHasAlreadyBeenCompleted = LocalString(spGlobal, 'featurediscoveryhasalreadybeencompleted', 'false');

DateTime _dtLongTimeAgo = DateTime.utc(1980);
LocalString _lsSInAppReviewDate = LocalString(spGlobal, 'inappreviewdate', _dtLongTimeAgo.toUtc().toIso8601String());
Future<DateTime> getInAppReviewLocalDate() async { return DateTime.tryParse(await _lsSInAppReviewDate.get()) ?? DateTime.now().toUtc(); }
void setEnabledInAppReviewLocalDateToNow() { _lsSInAppReviewDate.set(DateTime.now().toUtc().toIso8601String()); }
void setEnabledInAppReviewLocalDateToLongTimeAgo() { _lsSInAppReviewDate.set(_dtLongTimeAgo.toUtc().toIso8601String()); }

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

class LocalString {
  final SharedPreferences storage;
  final String _sKey;
  final String initString;

  LocalString(this.storage, this._sKey, this.initString);

  Future<String> get() async {
    return await _getSharedPreference() ?? initString;
  }

  Future<String?> _getSharedPreference() async {
    return storage.getString(_sKey);
  }

  set(String sValue) async {
    await _saveSharedPreference(sValue);
  }

  Future<void> _saveSharedPreference(String sInput) async {
    await storage.setString(_sKey, sInput);
  }
}
