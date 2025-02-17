import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/fsstorage.dart';
import 'localstorage.dart';
import '../apinetisolates/apilistuserresultsisolatecontroller.dart';

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

class ListsLocalStorage {

  FSSLocalStringList fssUserResultsDates = FSSLocalStringList(fssGlobal, 'userresultsdates', []);
  LocalStringList lslUserResults = LocalStringList(spGlobal, 'userresults', []);
  FSSLocalStringList fssModelResultsDates = FSSLocalStringList(fssGlobal, 'modelresultsdates', []);
  LocalStringList lslModelResults = LocalStringList(spGlobal, 'modelresults', []);
  FSSLocalStringList fssUserRunnersDates = FSSLocalStringList(fssGlobal, 'userrunnersdates', []);
  LocalStringList lslUserRunners = LocalStringList(spGlobal, 'userrunners', []);
  FSSLocalStringList fssModelRunnersDates = FSSLocalStringList(fssGlobal, 'modelrunnersdates', []);
  LocalStringList lslModelRunners = LocalStringList(spGlobal, 'modelrunners', []);
  FSSLocalStringList fssUserWorstResultsDates = FSSLocalStringList(fssGlobal, 'userworstresultsdates', []);
  LocalStringList lslUserWorstResults = LocalStringList(spGlobal, 'userworstresults', []);
  FSSLocalStringList fssModelWorstResultsDates = FSSLocalStringList(fssGlobal, 'modelworstresultsdates', []);
  LocalStringList lslModelWorstResults = LocalStringList(spGlobal, 'modelworstresults', []);

  void clearLocalListDates() {
    List<String> lsValueUR = serializeURLoadDates([["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                   ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                   ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
    fssUserResultsDates.set(lsValueUR);
    List<String> lsValueMR = serializeMRLoadDates([["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                   ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                   ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                    "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
    fssModelResultsDates.set(lsValueMR);
    List<String> lsValueURu = serializeURLoadDates([["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
    fssUserRunnersDates.set(lsValueURu);
    List<String> lsValueMRu = serializeMRLoadDates([["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
    fssModelRunnersDates.set(lsValueMRu);
    List<String> lsValueUWR = serializeURLoadDates([["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
    fssUserWorstResultsDates.set(lsValueUWR);
    List<String> lsValueMWR = serializeMRLoadDates([["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                                    ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                                     "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
    fssModelWorstResultsDates.set(lsValueMWR);
  }

  // UserResults and UserRunners Local conversions

  List<String> serializeURLoadDates(List<List<String>> llsURLD) {
    final List<String> lsReturn = [];
    for (int i = 0; i < llsURLD.length; i++) {
      final List<String> lsURLD = llsURLD[i];
      final List<String> lsValue = [];
      for (int j = 0; j < lsURLD.length; j++) {
        lsValue.add(lsURLD[j]);
      }
      lsReturn.add(jsonEncode(lsValue));
    }
    return lsReturn;
  }

  List<List<String>> deserializeURLoads(List<String> serializedURLD, List<List<String>> emptyURDL) {
    List<List<String>> llsURDL = emptyURDL;
    final int nSURDL = serializedURLD.length;
    try {
      for (int i = 0; i < nSURDL; i++) {
        List<dynamic> ldValue = jsonDecode(serializedURLD[i]);
        int nLdValue = ldValue.length;
        for (int j = 0; j < nLdValue; j++) {
            String s = ldValue[j];
            llsURDL[i][j] = s;
        }
      }
    } catch(e) {
      debugPrint("middleware, listslocalstorage.dart, _deserializeURLoad() e: $e");
    }
    return llsURDL;
  }

  List<String> serializeLlluraList(List<List<List<UserResultsAnswer>>> llluraList0) {
    final List<String> lsReturn = [];
    for (int i = 0; i < llluraList0.length; i++) {
      final List<List<UserResultsAnswer>> llura = llluraList0[i];
      final List<List<String>> lssValue = [];
      for (int j = 0; j < llura.length; j++) {
        final List<UserResultsAnswer> lura = llura[j];
        final List<String> lsValue = [];
        for (int k = 0; k < lura.length; k++) {
          lsValue.add(jsonEncode(lura[k].toMap()));
        }
        lssValue.add(lsValue);
      }
      lsReturn.add(jsonEncode(lssValue));
    }
    return lsReturn;
  }

  List<List<List<UserResultsAnswer>>> deserializeLlluList(List<String> serializedList, List<List<List<UserResultsAnswer>>> emptyLllura) {
    final List<List<List<UserResultsAnswer>>> lllura = emptyLllura;
    final int nSL = serializedList.length;
    try {
      for (int i = 0; i < nSL; i++) {
        List<dynamic> ldValue = jsonDecode(serializedList[i]);
        int nLdValue = ldValue.length;
        for (int j = 0; j < nLdValue; j++) {
          List<dynamic> ldVal = ldValue[j];
          int nLdVal = ldVal.length;
          for (int k = 0; k < nLdVal; k++) {
            String s = ldVal[k];
            UserResultsAnswer ura = UserResultsAnswer.fromMap(jsonDecode(s));
            lllura[i][j].add(ura);
          }
        }
      }
    } catch(e) {
      debugPrint("middleware, listslocalstorage.dart, _deserializeLlluList() e: $e");
    }
    return lllura;
  }

  // ModelResults Local conversions

  List<String> serializeMRLoadDates(List<List<String>> llsMRLD) {
    final List<String> lsReturn = [];
    for (int i = 0; i < llsMRLD.length; i++) {
      final List<String> lsMRLD = llsMRLD[i];
      final List<String> lsValue = [];
      for (int j = 0; j < lsMRLD.length; j++) {
        lsValue.add(lsMRLD[j]);
      }
      lsReturn.add(jsonEncode(lsValue));
    }
    return lsReturn;
  }

  List<List<String>> deserializeMRLoads(List<String> serializedMRLD, List<List<String>> emptyMRDL) {
    List<List<String>> llsMRDL = emptyMRDL;
    final int nSURDL = serializedMRLD.length;
    try {
      for (int i = 0; i < nSURDL; i++) {
        List<dynamic> ldValue = jsonDecode(serializedMRLD[i]);
        int nLdValue = ldValue.length;
        for (int j = 0; j < nLdValue; j++) {
            String s = ldValue[j];
            llsMRDL[i][j] = s;
        }
      }
    } catch(e) {
      debugPrint("middleware, listslocalstorage.dart, _deserializeURLoad() e: $e");
    }
    return llsMRDL;
  }

  List<String> serializeLllmraList(List<List<List<ModelResultsAnswer>>> lllmraList0) {
    final List<String> lsReturn = [];
    for (int i = 0; i < lllmraList0.length; i++) {
      final List<List<ModelResultsAnswer>> llmra = lllmraList0[i];
      final List<List<String>> lssValue = [];
      for (int j = 0; j < llmra.length; j++) {
        final List<ModelResultsAnswer> lmra = llmra[j];
        final List<String> lsValue = [];
        for (int k = 0; k < lmra.length; k++) {
          lsValue.add(jsonEncode(lmra[k].toMap()));
        }
        lssValue.add(lsValue);
      }
      lsReturn.add(jsonEncode(lssValue));
    }
    return lsReturn;
  }

  List<List<List<ModelResultsAnswer>>> deserializeLllmList(List<String> serializedList, List<List<List<ModelResultsAnswer>>> emptyLllura) {
    final List<List<List<ModelResultsAnswer>>> lllmra = emptyLllura;
    final int nSL = serializedList.length;
    try {
      for (int i = 0; i < nSL; i++) {
        List<dynamic> ldValue = jsonDecode(serializedList[i]);
        int nLdValue = ldValue.length;
        for (int j = 0; j < nLdValue; j++) {
          List<dynamic> ldVal = ldValue[j];
          int nLdVal = ldVal.length;
          for (int k = 0; k < nLdVal; k++) {
            String s = ldVal[k];
            ModelResultsAnswer mra = ModelResultsAnswer.fromMap(jsonDecode(s));
            lllmra[i][j].add(mra);
          }
        }
      }
    } catch(e) {
      debugPrint("middleware, listslocalstorage.dart, _deserializeLlluList() e: $e");
    }
    return lllmra;
  }

}
