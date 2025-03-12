import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/fsstorage.dart';
import '../middleware/localstorage.dart';
import 'adhandler.dart';
import '../middleware/customfloatingactionbuttonlocation.dart';
import '../parameters/themedata.dart';

class ModelLists extends StatefulWidget {

  final String pageTitle;
  final FSSLocalStringList fssLslMLLoadDates;
  final List<String> Function(List<List<String>> llsMLLoadDates) serializeMLLoadDates;
  final List<List<String>> Function(List<String> lsMLD, List<List<String>> initLsMLD) deserializeMLLoadDates;
  final LocalStringList lslModel;
  final List<String> Function(List<List<List<ModelResultsAnswer>>> lllMra) serializeLllmra;
  final List<List<List<ModelResultsAnswer>>> Function(List<String> lsML, List<List<List<ModelResultsAnswer>>> initLlsML) deserializeLllmra;

  final Future<dynamic> Function(int interval0, int threads0) callListModelRetryIsolateApi;

  const ModelLists({Key? key, required this.pageTitle,
                              required this.fssLslMLLoadDates,
                              required this.serializeMLLoadDates,
                              required this.deserializeMLLoadDates,
                              required this.lslModel,
                              required this.serializeLllmra,
                              required this.deserializeLllmra,
                              required this.callListModelRetryIsolateApi}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModelListsState();

}

class _ModelListsState extends State<ModelLists>  with TickerProviderStateMixin {

  late TabController _tabIntervalsController;
  late TabController _tabThreadsController;
  final int _iRefreshDelaySec = 300;
  bool _bRefreshDelayCompleted = true;
  List<List<String>> llsMLLoadDates = [["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                       ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                       ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]];
  bool _bHasMLLoadCompleted = false;
  List<List<List<ModelResultsAnswer>>> lllmra = [
    [[], [], [], []],
    [[], [], [], []],
    [[], [], [], []]
  ];
  List<List<_ModelListsDataTable>> llmldt = [
    [
      _ModelListsDataTable(lModelAnswer: [], threads: 1),
      _ModelListsDataTable(lModelAnswer: [], threads: 2),
      _ModelListsDataTable(lModelAnswer: [], threads: 4),
      _ModelListsDataTable(lModelAnswer: [], threads: 8),
    ],
    [
      _ModelListsDataTable(lModelAnswer: [], threads: 1),
      _ModelListsDataTable(lModelAnswer: [], threads: 2),
      _ModelListsDataTable(lModelAnswer: [], threads: 4),
      _ModelListsDataTable(lModelAnswer: [], threads: 8),
    ],    [
      _ModelListsDataTable(lModelAnswer: [], threads: 1),
      _ModelListsDataTable(lModelAnswer: [], threads: 2),
      _ModelListsDataTable(lModelAnswer: [], threads: 4),
      _ModelListsDataTable(lModelAnswer: [], threads: 8),
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
      await _getLocalModelListsDates();
      await _getModelList(0, 0);
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

  Future<void> _getLocalModelListsDates() async {
    llsMLLoadDates = widget.deserializeMLLoadDates(
      await widget.fssLslMLLoadDates.get(), [["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                              "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                             ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                              "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"],
                                             ["1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z",
                                              "1980-01-01T00:00:00.000Z", "1980-01-01T00:00:00.000Z"]]);
  }

  bool _isTabLoadable() {
    DateTime dtLoadDatesUTC = (DateTime.tryParse(llsMLLoadDates[_tabIntervalsController.index][_tabThreadsController.index]) ?? DateTime.utc(1980,1,1,0,0,0)).toUtc();
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

  void _handleTabSelection() => _refreshModelList();

  void _handleFloatingActionButtonPress() => _refreshModelList();

  void _refreshModelList()  => _getModelList(_tabIntervalsController.index, _tabThreadsController.index);

  Future<void> _getModelList(int iIntervalTab, int iThreadTab) async {

    _bHasMLLoadCompleted = false;

    List<List<List<ModelResultsAnswer>>> lllmra0 = widget.deserializeLllmra(await widget.lslModel.get(), [[[], [], [], []],[[], [], [], []],[[], [], [], []]]);
    if (mounted) {
      setState(() {
        lllmra = lllmra0;
      });
    }

    if (_isTabLoadable()) {
      List<dynamic> ldValue =
        await widget.callListModelRetryIsolateApi(_intervalTabToThreads(iIntervalTab), _threadTabToThreads(iThreadTab));
      bool success = ldValue[0];
      if (success) {
        Map<String, List<ModelResultsAnswer>> answer = ldValue[1];
        List<ModelResultsAnswer> list = answer['list'] ?? [];
        debugPrint("widgets, modellistswidget.dart, getModelList() list: ${list.map((e) => e.toMap()).toList()}");
        if (mounted) {
          setState(() {
            lllmra[iIntervalTab][iThreadTab] = list;
          });
        }
        List<String> lsValue = widget.serializeLllmra(lllmra);
        widget.lslModel.set(lsValue);
      }
    }

    llsMLLoadDates[iIntervalTab][iThreadTab] = DateTime.now().toUtc().toIso8601String();
    List<String> lsValue = widget.serializeMLLoadDates(llsMLLoadDates);
    widget.fssLslMLLoadDates.set(lsValue);
  
    _startOrResetRealoadTimer();
    _bHasMLLoadCompleted = true;

  }

  Widget scrollableDataTable(int iIntervalTab, int iThreadTab) {
    _ModelListsDataTable uldt = _ModelListsDataTable(
        lModelAnswer: lllmra[iIntervalTab][iThreadTab],
        threads: _threadTabToThreads(iThreadTab));
    llmldt[iIntervalTab][iThreadTab] = uldt;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 12.0,
          columns: _kTableColumns,
          rows: llmldt[iIntervalTab][iThreadTab].getRows(),
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
          floatingActionButton: (_bRefreshDelayCompleted && _bHasMLLoadCompleted && _isTabLoadable())
            ? ElevatedButton(onPressed: _handleFloatingActionButtonPress, child: const Icon(Icons.refresh_rounded, size: 36))
            : null,
          floatingActionButtonLocation: CustomFloatingActionButtonLocation(0.0, -104.0),
        ),
      ),
    );
  }

}

const List<DataColumn> _kTableColumns = <DataColumn>[
  DataColumn(
    label: Padding(padding: EdgeInsets.only(right: 6), child: Text('No.', style: TextStyle(fontSize: 17.6))),
    numeric: true,
    tooltip: "Position in the list",
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

class _ModelListsRow {
  _ModelListsRow(this.modelName, this.runs, this.best, this.average, this.worst);
  final String modelName;
  final int runs;
  final double best;
  final double average;
  final double worst;
}

class _ModelListsDataTable {
  final List<ModelResultsAnswer> lModelAnswer;
  final int threads;

  _ModelListsDataTable({required this.lModelAnswer, required this.threads});

  _ModelListsRow _convertModelListsElementToDataTableRow(List<ModelResultsAnswer> lmra0, int row0) {
    _ModelListsRow mlr = _ModelListsRow(
      lmra0[row0].modelName,
      lmra0[row0].runCount,
      lmra0[row0].bestResult / 1000,
      lmra0[row0].averageResult / 1000,
      lmra0[row0].worstResult / 1000,
    );
    return mlr;
  }

  List<DataRow> getRows() {
    final int nRows = lModelAnswer.length;
    final List<DataRow> ldr = [];
    for (int row = 0; row < nRows; row++) {
      _ModelListsRow mlr = _convertModelListsElementToDataTableRow(lModelAnswer, row);
      ldr.add(
        DataRow(cells: [
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text('${row + 1}', style: const TextStyle(fontSize: 17)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 8), child: Text(mlr.modelName, style: const TextStyle(fontSize: 17)))),
          DataCell(Padding(padding: const EdgeInsets.only(right: 12), child: Text('${mlr.runs}', style: const TextStyle(fontSize: 17)))),
          DataCell(Text(mlr.best.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
          DataCell(Text(mlr.average.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
          DataCell(Text(mlr.worst.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
        ]));
    }
    return ldr;
  }
}
