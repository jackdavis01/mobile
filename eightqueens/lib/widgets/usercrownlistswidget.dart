import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistuserresultsisolatecontroller.dart';
import '../middleware/fsstorage.dart';
import '../middleware/localstorage.dart';
import 'adhandler.dart';
import '../middleware/customfloatingactionbuttonlocation.dart';
import '../parameters/themedata.dart';

class UserCrownLists extends StatefulWidget {

  final String pageTitle;
  final FSSLocalStringList fssLslULLoadDates;
  final List<String> Function(List<List<String>> llsULLoadDates) serializeULLoadDates;
  final List<List<String>> Function(List<String> lsULD, List<List<String>> initLsULD) deserializeULLoadDates;
  final LocalStringList lslUser;
  final List<String> Function(List<List<List<UserResultsAnswer>>> lllUra) serializeLllura;
  final List<List<List<UserResultsAnswer>>> Function(List<String> lsUL, List<List<List<UserResultsAnswer>>> initLlsUL) deserializeLllura;

  final Future<dynamic> Function() callListUserRetryIsolateApi;

  const UserCrownLists({Key? key, required this.pageTitle,
                             required this.fssLslULLoadDates,
                             required this.serializeULLoadDates,
                             required this.deserializeULLoadDates,
                             required this.lslUser,
                             required this.serializeLllura,
                             required this.deserializeLllura,
                             required this.callListUserRetryIsolateApi}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserCrownListsState();

}

class _UserCrownListsState extends State<UserCrownLists>  with TickerProviderStateMixin {

  final int _iRefreshDelaySec = 300;
  bool _bRefreshDelayCompleted = true;
  List<List<String>> llsULLoadDates = [["1980-01-01T00:00:00.000Z"]];
  bool _bHasULLoadCompleted = false;
  List<List<List<UserResultsAnswer>>> lllura = [[[]]];
  List<List<_UserCrownListsDataTable>> lluldt = [[_UserCrownListsDataTable(lUserAnswer: [], threads: 0)]];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getLocalUserListsDates();
      await _getUserList();
    });
  }

  Future<void> _getLocalUserListsDates() async {
    llsULLoadDates = widget.deserializeULLoadDates(
      await widget.fssLslULLoadDates.get(), [["1980-01-01T00:00:00.000Z"]]);
  }

  bool _isTabLoadable() {
    DateTime dtLoadDatesUTC = (DateTime.tryParse(llsULLoadDates[0][0]) ?? DateTime.utc(1980,1,1,0,0,0)).toUtc();
    DateTime dtNow = DateTime.now().toUtc();
    Duration duDiff = dtNow.difference(dtLoadDatesUTC);
    bool isLoadable = (Duration(seconds: _iRefreshDelaySec - 1) < duDiff);
    return isLoadable;
  }

  Timer? _timer;
  Completer<void>? _completer;

  Future<void> _startOrResetRealoadTimer() async {
    _timer?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
    _completer = Completer<void>();
    _bRefreshDelayCompleted = false;

    _timer = Timer(Duration(seconds: _iRefreshDelaySec), () {
      if (mounted) {
        setState(() {
          _bRefreshDelayCompleted = true;
        });
      }
      if (_completer != null && !_completer!.isCompleted) {
        _completer!.complete();
      }
    });

    return _completer!.future;
  }

  void _handleFloatingActionButtonPress() => _refreshUserList();

  void _refreshUserList()  => _getUserList();

  Future<void> _getUserList() async {

    _bHasULLoadCompleted = false;

    List<List<List<UserResultsAnswer>>> lllura0 = widget.deserializeLllura(await widget.lslUser.get(), [[[]]]);
    if (mounted) {
      setState(() {
        lllura = lllura0;
      });
    }

    if (_isTabLoadable()) {
      List<dynamic> ldValue =
        await widget.callListUserRetryIsolateApi();
      bool success = ldValue[0];
      if (success) {
        Map<String, List<UserResultsAnswer>> answer = ldValue[1];
        List<UserResultsAnswer> list = answer['list'] ?? [];
        debugPrint("widgets, userlistswidget.dart, getUserList() list: ${list.map((e) => e.toMap()).toList()}");
        if (mounted) {
          setState(() {
            lllura[0][0] = list;
          });
        }
        List<String> lsValue = widget.serializeLllura(lllura);
        widget.lslUser.set(lsValue);
      }
    }

    llsULLoadDates[0][0] = DateTime.now().toUtc().toIso8601String();
    List<String> lsValue = widget.serializeULLoadDates(llsULLoadDates);
    widget.fssLslULLoadDates.set(lsValue);
  
    _startOrResetRealoadTimer();
    _bHasULLoadCompleted = true;

  }

  Widget scrollableDataTable() {
    _UserCrownListsDataTable uldt = _UserCrownListsDataTable(
        lUserAnswer: lllura[0][0],
        threads: 0);
    lluldt[0][0] = uldt;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12.0,
          columns: kTableColumns,
          rows: lluldt[0][0].getRows(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: blueTheme, // ThemeData.light(), // Apply light theme
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: blueTheme.colorScheme.inversePrimary,
            title: Padding(
              padding: const EdgeInsets.only(top: 12.0), child: Text(widget.pageTitle)),
            centerTitle: true,
          ),
          body: Column(children: [
            Expanded(child: scrollableDataTable()),
            const AdBanner(),
          ]),
          floatingActionButton: (_bRefreshDelayCompleted && _bHasULLoadCompleted && _isTabLoadable())
            ? ElevatedButton(onPressed: _handleFloatingActionButtonPress, child: const Icon(Icons.refresh_rounded, size: 36))
            : null,
          floatingActionButtonLocation: CustomFloatingActionButtonLocation(0.0, -104.0),
        ),
      ),
    );
  }

}

const List<DataColumn> kTableColumns = <DataColumn>[
  DataColumn(
    label: Padding(padding: EdgeInsets.only(right: 1), child: Text('No.', style: TextStyle(fontSize: 17.6))),
    numeric: true,
    tooltip: "Position in the list",
  ),
  DataColumn(
    label: Text('Crowns', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "The collected crowns",
  ),
  DataColumn(
    label: Text('User name', style: TextStyle(fontSize: 17.6)),
  ),
  DataColumn(
    label: Text('Model name', style: TextStyle(fontSize: 17.6)),
  ),
  DataColumn(
    label: Text('Runs', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Number of measurements",
  ),
];

class _UserCrownListsRow {
  _UserCrownListsRow(this.me, this.crowns, this.userName, this.modelName, this.runs);
  final bool me;
  final int crowns;
  final String userName;
  final String modelName;
  final int runs;
}

class _UserCrownListsDataTable {
  final List<UserResultsAnswer> lUserAnswer;
  final int threads;

  _UserCrownListsDataTable({required this.lUserAnswer, required this.threads});

  _UserCrownListsRow _convertUserListsElementToDataTableRow(List<UserResultsAnswer> lura0, int row0) {
    _UserCrownListsRow uclr = _UserCrownListsRow(
      (1 == lura0[row0].me) ? true : false,
      lura0[row0].credit,
      lura0[row0].userName,
      lura0[row0].modelName,
      lura0[row0].runCount,
    );
    return uclr;
  }

  List<DataRow> getRows() {
    final int nRows = lUserAnswer.length;
    final List<DataRow> ldr = [];
    for (int row = 0; row < nRows; row++) {
      _UserCrownListsRow uclr = _convertUserListsElementToDataTableRow(lUserAnswer, row);
      FontWeight fw = (uclr.me) ? FontWeight.bold : FontWeight.normal;
      String sMe = (uclr.me) ? " (me)" : "";
      ldr.add(
        DataRow(cells: [
          DataCell(Padding(padding: const EdgeInsets.only(right: 2), child: Text('${row + 1}', style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 12), child: Text('${uclr.crowns}', style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text(uclr.userName + sMe, style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text(uclr.modelName, style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 12), child: Text('${uclr.runs}', style: TextStyle(fontSize: 17, fontWeight: fw)))),
        ]));
    }
    return ldr;
  }
}
