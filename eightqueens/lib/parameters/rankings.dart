import 'package:flutter/material.dart';

class RankRecord {
  final int iNThread;
  final String sRankName;
  final int iMinLimitMs;
  final int iMaxLimitMs;
  final Color cRank;

  RankRecord({required this.iNThread, required this.sRankName, required this.iMinLimitMs, required this.iMaxLimitMs, required this.cRank});

  factory RankRecord.fromMap(Map<String, dynamic> map) {
    return RankRecord(iNThread: map['iNThread'], sRankName: map['sRankName'], iMinLimitMs: map['iMinLimitMs'], iMaxLimitMs: map['iMaxLimitMs'], cRank: map['cRank']);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["iNThread"] = iNThread;
    map["sRankName"] = sRankName;
    map["iMinLimitMs"] = iMinLimitMs;
    map["iMaxLimitMs"] = iMaxLimitMs;
    map["cRank"] = cRank;
    return map;
  }
}

const int maxPreciseWebInt = 0x20000000000000;

class Rankings {
  final List<int> liThreads = [1, 2, 4, 8];
  final List<String> lsRankNames = [
    'Faster than light',
    'Light speed',
    'Crazy fast',
    'Very fast',
    'Fast',
    'Better than average',
    'Average',
    'Slower than average',
    'Slow',
    'Very slow',
  ];
  /*final List<List<int>> lliRanks = [
    [0, 0, 0, 0],
    [8000, 4000, 2000, 1000],
    [12000, 8000, 5000, 2500],
    [18000, 13500, 10000, 5500],
    [22000, 16500, 12000, 8000],
    [27000, 20000, 14000, 10500],
    [33000, 25000, 17000, 13000],
    [64000, 40000, 20000, 16000],
    [100000, 60000, 26000, 20000],
    [maxPreciseWebInt, maxPreciseWebInt, maxPreciseWebInt, maxPreciseWebInt]
  ];*/
  final List<List<int>> lliRanks = [
    [0, 0, 0, 0],
    [2400, 1200, 600, 300],
    [4000, 2400, 1500, 800],
    [6000, 4500, 3000, 1600],
    [7300, 5500, 4000, 2400],
    [9000, 6600, 4600, 3500],
    [11000, 8300, 5600, 4300],
    [21300, 12000, 6600, 5300],
    [33000, 20000, 8600, 6600],
    [maxPreciseWebInt, maxPreciseWebInt, maxPreciseWebInt, maxPreciseWebInt]
  ];
  final List<Color> lcRanks = [
    Colors.white,
    Color.alphaBlend(Colors.blue.shade100.withAlpha(255 ~/ 3 * 2), Colors.lightGreen.shade100),
    Color.alphaBlend(Colors.blue.shade100.withAlpha(255 ~/ 3), Colors.lightGreen.shade100),
    Colors.lightGreen.shade100,
    Color.alphaBlend(Colors.yellow.shade100.withAlpha(255 ~/ 3), Colors.lightGreen.shade100),
    Color.alphaBlend(Colors.yellow.shade100.withAlpha(255 ~/ 3 * 2), Colors.lightGreen.shade100),
    Colors.yellow.shade100,
    Color.alphaBlend(Colors.yellow.shade100.withAlpha(255 ~/ 2), Colors.orange.shade100),
    Colors.orange.shade100,
    Colors.red.shade100,
  ];

  int getSpeedRank(final int iNThread, final Duration dElapsed) {
    int iThread = 0;
    int iSpeed = 0;
    for (int i = 0; i < liThreads.length; i++) {
      if (iNThread == liThreads[i]) iThread = i;
    }
    for (int i = 1; i < lliRanks.length; i++) {
      if (Duration(milliseconds: lliRanks[i-1][iThread]) <= dElapsed && Duration(milliseconds: lliRanks[i][iThread]) > dElapsed) {
        iSpeed = i;
        break;
      }
    }
    return iSpeed;
  }

  List<RankRecord> getRankingList() {
    final List<RankRecord> lRankRecords = [];
    for (int i = 0; i < liThreads.length; i++) {
      for (int j = 0; j < lliRanks.length-1; j++) {
        Map<String, dynamic> msdRankRecords = {"iNThread": liThreads[i], "sRankName": lsRankNames[j+1], "iMinLimitMs": lliRanks[j][i], "iMaxLimitMs": lliRanks[j+1][i], "cRank": lcRanks[j+1]};
        RankRecord rr = RankRecord.fromMap(msdRankRecords);
        lRankRecords.add(rr);
      }
    }
    return lRankRecords;
  }

}
