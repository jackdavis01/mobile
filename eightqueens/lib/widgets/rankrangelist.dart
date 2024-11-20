import 'package:flutter/material.dart';
import '../parameters/rankings.dart';

class RankRangeListTitle extends StatelessWidget {
  const RankRangeListTitle({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(child:
      Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text("Rank Ranges", style: TextStyle(fontSize: 24.0)),
      ),
    );
  }
}

class RankRangeList extends StatelessWidget {

  final Rankings rR = Rankings();

  RankRangeList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<RankRecord> lRR = rR.getRankingList();
    List<String> lsHeader = ["Th", "Min, ms", "Max, ms", "Rank Name"];
    lRR.insert(0, lRR[0]);
    int columnCount = lRR[0].toMap().keys.length - 1;
    int rowCount = lRR.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 452,
        height: 1408,
        child: Container(
          padding: const EdgeInsets.only(top: 2, left: 2),
          color: Theme.of(context).colorScheme.onPrimary,
          child: 
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: List.generate(columnCount * rowCount, (index) {
                int iColumn = index % columnCount;
                int iRow = index ~/ columnCount;
                String sField = "";
                double dWidth = 100;
                switch (iColumn) {
                  case 0: dWidth = 42; sField = "${lRR[iRow].iNThread}"; break;
                  case 1: dWidth = 100; sField = "${lRR[iRow].iMinLimitMs}"; break;
                  case 2: dWidth = 100; sField = (86000000 < lRR[iRow].iMaxLimitMs) ? "Infinite" : "${lRR[iRow].iMaxLimitMs}"; break;
                  case 3: dWidth = 200; sField = lRR[iRow].sRankName; break;
                }
                Color cRow = lRR[iRow].cRank;
                FontWeight fwRow = FontWeight.normal;
                if (0 == iRow) {
                  sField = lsHeader[iColumn];
                  cRow = Colors.black12;
                  fwRow = FontWeight.bold;
                }
                return
                  Container(
                    width: dWidth,
                    height: 36,
                    color: cRow,
                    padding: const EdgeInsets.only(top: 6, right: 8, bottom: 6, left: 8),
                    child:
                      Text(sField, style: TextStyle(fontSize: 17, fontWeight: fwRow)),
                  );
              }),
            ),
        ),
      ),
    );
  }
}
