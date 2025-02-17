import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistuserresultsisolatecontroller.dart';
import '../middleware/fsstorage.dart';
import '../middleware/localstorage.dart';
import '../middleware/adhandler.dart';
import '../middleware/customfloatingactionbuttonlocation.dart';

class UserLists extends StatefulWidget {

  final String pageTitle;
  final FSSLocalStringList fssLslULLoadDates;
  final List<String> Function(List<List<String>> llsULLoadDates) serializeULLoadDates;
  final List<List<String>> Function(List<String> lsULD, List<List<String>> initLsULD) deserializeULLoadDates;
  final LocalStringList lslUser;
  final List<String> Function(List<List<List<UserResultsAnswer>>> lllUra) serializeLllura;
  final List<List<List<UserResultsAnswer>>> Function(List<String> lsUL, List<List<List<UserResultsAnswer>>> initLlsUL) deserializeLllura;

  final Future<dynamic> Function(int interval0, int threads0) callListUserRetryIsolateApi;

  const UserLists({Key? key, required this.pageTitle,
                             required this.fssLslULLoadDates,
                             required this.serializeULLoadDates,
                             required this.deserializeULLoadDates,
                             required this.lslUser,
                             required this.serializeLllura,
                             required this.deserializeLllura,
                             required this.callListUserRetryIsolateApi}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserListsState();

}

class _UserListsState extends State<UserLists>  with TickerProviderStateMixin {

  late TabController _tabIntervalsController;
  late TabController _tabThreadsController;
  final int _iRefreshDelaySec = 300;
  bool _bRefreshDelayCompleted = true;
  List<List<String>> llsULLoadDates = [["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                       ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                       ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]];
  bool _bHasULLoadCompleted = false;
  List<List<List<UserResultsAnswer>>> lllura = [
    [[], [], [], []],
    [[], [], [], []],
    [[], [], [], []]
  ];
  List<List<UserListsDataTable>> lluldt = [
    [
      UserListsDataTable(lUserAnswer: [], threads: 1),
      UserListsDataTable(lUserAnswer: [], threads: 2),
      UserListsDataTable(lUserAnswer: [], threads: 4),
      UserListsDataTable(lUserAnswer: [], threads: 8),
    ],
    [
      UserListsDataTable(lUserAnswer: [], threads: 1),
      UserListsDataTable(lUserAnswer: [], threads: 2),
      UserListsDataTable(lUserAnswer: [], threads: 4),
      UserListsDataTable(lUserAnswer: [], threads: 8),
    ],    [
      UserListsDataTable(lUserAnswer: [], threads: 1),
      UserListsDataTable(lUserAnswer: [], threads: 2),
      UserListsDataTable(lUserAnswer: [], threads: 4),
      UserListsDataTable(lUserAnswer: [], threads: 8),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _tabIntervalsController = TabController(length: 3, vsync: this);
    _tabIntervalsController.addListener(_handleTabSelection);
    _tabThreadsController = TabController(length: 4, vsync: this);
    _tabThreadsController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getLocalUserListsDates();
      await _getUserList(0, 0);
    });
  }

  @override
  void dispose() {
    _tabIntervalsController.removeListener(_handleTabSelection);
    _tabIntervalsController.dispose();
    _tabThreadsController.removeListener(_handleTabSelection);
    _tabThreadsController.dispose();
    super.dispose();
  }

  Future<void> _getLocalUserListsDates() async {
    llsULLoadDates = widget.deserializeULLoadDates(
      await widget.fssLslULLoadDates.get(), [["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                              "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                             ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                              "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                             ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                              "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
  }

  bool _isTabLoadable() {
    DateTime dtLoadDatesUTC = (DateTime.tryParse(llsULLoadDates[_tabIntervalsController.index][_tabThreadsController.index]) ?? DateTime.utc(1980,1,1,0,0,0)).toUtc();
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

  void _handleTabSelection() => _refreshUserList();

  void _handleFloatingActionButtonPress() => _refreshUserList();

  void _refreshUserList()  => _getUserList(_tabIntervalsController.index, _tabThreadsController.index);

  Future<void> _getUserList(int iIntervalTab, int iThreadTab) async {

    _bHasULLoadCompleted = false;

    List<List<List<UserResultsAnswer>>> lllura0 = widget.deserializeLllura(await widget.lslUser.get(), [[[], [], [], []],[[], [], [], []],[[], [], [], []]]);
    if (mounted) {
      setState(() {
        lllura = lllura0;
      });
    }

    if (_isTabLoadable()) {
      List<dynamic> ldValue =
        await widget.callListUserRetryIsolateApi(_intervalTabToThreads(iIntervalTab), _threadTabToThreads(iThreadTab));
      bool success = ldValue[0];
      if (success) {
        Map<String, List<UserResultsAnswer>> answer = ldValue[1];
        List<UserResultsAnswer> list = answer['list'] ?? [];
        debugPrint("widgets, userlistswidget.dart, getUserList() list: ${list.map((e) => e.toMap()).toList()}");
        if (mounted) {
          setState(() {
            lllura[iIntervalTab][iThreadTab] = list;
          });
        }
        List<String> lsValue = widget.serializeLllura(lllura);
        widget.lslUser.set(lsValue);
      }
    }

    llsULLoadDates[iIntervalTab][iThreadTab] = DateTime.now().toUtc().toIso8601String();
    List<String> lsValue = widget.serializeULLoadDates(llsULLoadDates);
    widget.fssLslULLoadDates.set(lsValue);
  
    _startOrResetRealoadTimer();
    _bHasULLoadCompleted = true;

  }

  Widget scrollableDataTable(int iIntervalTab, int iThreadTab) {
    UserListsDataTable uldt = UserListsDataTable(
        lUserAnswer: lllura[iIntervalTab][iThreadTab],
        threads: _threadTabToThreads(iThreadTab));
    lluldt[iIntervalTab][iThreadTab] = uldt;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12.0,
          columns: kTableColumns,
          rows: lluldt[iIntervalTab][iThreadTab].getRows(),
        ),
      ),
    );
  }

  int _intervalTabToThreads(int iThreadTab) {
    switch (iThreadTab) {
      case 0: return 2; // Weekly
      case 1: return 3; // Monthly
      case 2: return 4; // Quarterly
      default: return 1;
    }
  }

  int _threadTabToThreads(int iThreadTab) {
    switch (iThreadTab) {
      case 0: return 1;
      case 1: return 2;
      case 2: return 4;
      case 3: return 8;
      default: return 1;
    }
  }

  final ThemeData blueTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: blueTheme, // ThemeData.light(), // Apply light theme
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 12.0), child: Text(widget.pageTitle)),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: TabBar(
                padding: const EdgeInsets.only(bottom: 3.0),
                controller: _tabIntervalsController,
                isScrollable: true,
                tabs: const <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                    child: Text("Weekly", style: TextStyle(fontSize: 18.4), maxLines: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                    child: Text("Monthly", style: TextStyle(fontSize: 18.4), maxLines: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                    child: Text("Quarterly", style: TextStyle(fontSize: 18.4), maxLines: 1),
                  ),
                ],
              ),
            ),
          ),
          body: Column(children: [
            Expanded(child: TabBarView(
              controller: _tabIntervalsController,
              children: <Widget>[
                DefaultTabController(
                  length: 4,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabThreadsController,
                        isScrollable: true,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("1 Thread", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("2 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("4 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("8 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabThreadsController,
                          children: <Widget>[
                            scrollableDataTable(0, 0),
                            scrollableDataTable(0, 1),
                            scrollableDataTable(0, 2),
                            scrollableDataTable(0, 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 4,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabThreadsController,
                        isScrollable: true,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("1 Thread", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("2 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("4 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("8 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabThreadsController,
                          children: <Widget>[
                            scrollableDataTable(1, 0),
                            scrollableDataTable(1, 1),
                            scrollableDataTable(1, 2),
                            scrollableDataTable(1, 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 4,
                  initialIndex: 0,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabThreadsController,
                        isScrollable: true,
                        tabs: const [
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("1 Thread", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("2 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("4 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: Text("8 Threads", style: TextStyle(fontSize: 18.4), maxLines: 1),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabThreadsController,
                          children: <Widget>[
                            scrollableDataTable(2, 0),
                            scrollableDataTable(2, 1),
                            scrollableDataTable(2, 2),
                            scrollableDataTable(2, 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
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
    label: Padding(padding: EdgeInsets.only(right: 6), child: Text('No.', style: TextStyle(fontSize: 17.6))),
    numeric: true,
    tooltip: "Position in the list",
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
  DataColumn(
    label: Text('Best', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Best results in second",
  ),
  DataColumn(
    label: Text('Average', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Average results in second",
  ),
  DataColumn(
    label: Text('Worst', style: TextStyle(fontSize: 17.6)),
    numeric: true,
    tooltip: "Worst results in second",
  ),
];

class _UserListsRow {
  _UserListsRow(this.me, this.userName, this.modelName, this.runs, this.best, this.average, this.worst);
  final bool me;
  final String userName;
  final String modelName;
  final int runs;
  final double best;
  final double average;
  final double worst;
}

class UserListsDataTable {
  final List<UserResultsAnswer> lUserAnswer;
  final int threads;

  UserListsDataTable({required this.lUserAnswer, required this.threads});

  _UserListsRow _convertUserListsElementToDataTableRow(List<UserResultsAnswer> lura0, int row0) {
    _UserListsRow ulr = _UserListsRow(
      (1 == lura0[row0].me) ? true : false,
      lura0[row0].userName,
      lura0[row0].modelName,
      lura0[row0].runCount,
      lura0[row0].bestResult / 1000,
      lura0[row0].averageResult / 1000,
      lura0[row0].worstResult / 1000,
    );
    return ulr;
  }

  List<DataRow> getRows() {
    final int nRows = lUserAnswer.length;
    final List<DataRow> ldr = [];
    for (int row = 0; row < nRows; row++) {
      _UserListsRow mur = _convertUserListsElementToDataTableRow(lUserAnswer, row);
      FontWeight fw = (mur.me) ? FontWeight.bold : FontWeight.normal;
      String sMe = (mur.me) ? " (me)" : "";
      ldr.add(
        DataRow(cells: [
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text('${row + 1}', style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text(mur.userName + sMe, style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text(mur.modelName, style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 12), child: Text('${mur.runs}', style: TextStyle(fontSize: 17, fontWeight: fw)))),
          DataCell(Text(mur.best.toStringAsFixed(3), style: TextStyle(fontSize: 17, fontWeight: fw))),
          DataCell(Text(mur.average.toStringAsFixed(3), style: TextStyle(fontSize: 17, fontWeight: fw))),
          DataCell(Text(mur.worst.toStringAsFixed(3), style: TextStyle(fontSize: 17, fontWeight: fw))),
        ]));
    }
    return ldr;
  }
}
