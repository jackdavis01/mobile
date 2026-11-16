import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/fsstorage.dart';
import '../middleware/localstorage.dart';
import '../middleware/listslocalstorage.dart';
import 'adhandler.dart';
import '../middleware/customfloatingactionbuttonlocation.dart';
import '../parameters/themedata.dart';
import '../parameters/statisticsinterval.dart';

class ModelLists extends StatefulWidget {
  final String pageTitle;
  final FSSLocalStringList fssLslMLLoadDates;
  final List<String> Function(List<List<String>> llsMLLoadDates) serializeMLLoadDates;
  final List<List<String>> Function(List<String> lsMLD, List<List<String>> initLsMLD) deserializeMLLoadDates;
  final LocalStringList lslModel;
  final List<String> Function(List<List<List<ModelResultsAnswer>>> lllMra) serializeLllmra;
  final List<List<List<ModelResultsAnswer>>> Function(List<String> lsML, List<List<List<ModelResultsAnswer>>> initLlsML)
      deserializeLllmra;

  final Future<dynamic> Function(int interval0, int threads0) callListModelRetryIsolateApi;

  const ModelLists(
      {Key? key,
      required this.pageTitle,
      required this.fssLslMLLoadDates,
      required this.serializeMLLoadDates,
      required this.deserializeMLLoadDates,
      required this.lslModel,
      required this.serializeLllmra,
      required this.deserializeLllmra,
      required this.callListModelRetryIsolateApi})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModelListsState();
}

class _ModelListsState extends State<ModelLists> with TickerProviderStateMixin {
  late TabController _tabIntervalsController;
  late TabController _tabThreadsController;
  final int _iRefreshDelaySec = 300;
  bool _bRefreshDelayCompleted = true;
  List<List<String>> llsMLLoadDates = ListsLocalStorage.emptyStatisticsLoadDates();
  bool _bHasMLLoadCompleted = false;
  List<List<List<ModelResultsAnswer>>> lllmra =
      List.generate(StatisticsInterval.values.length, (_) => [[], [], [], []]);
  List<List<_ModelListsDataTable>> llmldt =
      List.generate(StatisticsInterval.values.length, (_) => [
      _ModelListsDataTable(lModelAnswer: [], threads: 1),
      _ModelListsDataTable(lModelAnswer: [], threads: 2),
      _ModelListsDataTable(lModelAnswer: [], threads: 4),
      _ModelListsDataTable(lModelAnswer: [], threads: 8),
    ]);

  @override
  void initState() {
    super.initState();
    _tabIntervalsController = TabController(length: StatisticsInterval.values.length, vsync: this);
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
        await widget.fssLslMLLoadDates.get(), ListsLocalStorage.emptyStatisticsLoadDates());
  }

  bool _isTabLoadable() {
    DateTime dtLoadDatesUTC =
        (DateTime.tryParse(llsMLLoadDates[_tabIntervalsController.index][_tabThreadsController.index]) ??
                DateTime.utc(1980, 1, 1, 0, 0, 0))
            .toUtc();
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

  void _refreshModelList() => _getModelList(_tabIntervalsController.index, _tabThreadsController.index);

  Future<void> _getModelList(int iIntervalTab, int iThreadTab) async {
    _bHasMLLoadCompleted = false;

    List<List<List<ModelResultsAnswer>>> lllmra0 = widget.deserializeLllmra(
        await widget.lslModel.get(),
        List.generate(StatisticsInterval.values.length, (_) => [[], [], [], []]));
    if (mounted) {
      setState(() {
        lllmra = lllmra0;
      });
    }

    if (_isTabLoadable()) {
      List<dynamic> ldValue = await widget.callListModelRetryIsolateApi(
          StatisticsInterval.values[iIntervalTab].apiValue, _threadTabToThreads(iThreadTab));
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
    _ModelListsDataTable uldt =
        _ModelListsDataTable(lModelAnswer: lllmra[iIntervalTab][iThreadTab], threads: _threadTabToThreads(iThreadTab));
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

  int _threadTabToThreads(int iThreadTab) {
    switch (iThreadTab) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 4;
      case 3:
        return 8;
      default:
        return 1;
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
            title: Padding(padding: const EdgeInsets.only(top: 12.0), child: Text(widget.pageTitle)),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: TabBar(
                padding: const EdgeInsets.only(bottom: 3.0),
                controller: _tabIntervalsController,
                isScrollable: true,
                tabs: <Widget>[
                  for (final interval in StatisticsInterval.values)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                      child: Text(interval.label, style: const TextStyle(fontSize: 18.4), maxLines: 1),
                    ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(children: [
              Expanded(
                  child: TabBarView(
                controller: _tabIntervalsController,
                children: <Widget>[
                  for (int iIntervalTab = 0; iIntervalTab < StatisticsInterval.values.length; iIntervalTab++)
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
                              for (int iThreadTab = 0; iThreadTab < 4; iThreadTab++)
                                scrollableDataTable(iIntervalTab, iThreadTab),
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
          ),
          floatingActionButton: (_bRefreshDelayCompleted && _bHasMLLoadCompleted && _isTabLoadable())
              ? AdBannerFabLift(
                  child: SafeArea(
                      top: false,
                      child: ElevatedButton(
                          onPressed: _handleFloatingActionButtonPress, child: const Icon(Icons.refresh_rounded, size: 36))))
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
      ldr.add(DataRow(cells: [
        DataCell(Padding(
            padding: const EdgeInsets.only(right: 8), child: Text('${row + 1}', style: const TextStyle(fontSize: 17)))),
        DataCell(Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(mlr.modelName, style: const TextStyle(fontSize: 17)))),
        DataCell(Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text('${mlr.runs}', style: const TextStyle(fontSize: 17)))),
        DataCell(Text(mlr.best.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
        DataCell(Text(mlr.average.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
        DataCell(Text(mlr.worst.toStringAsFixed(3), style: const TextStyle(fontSize: 17))),
      ]));
    }
    return ldr;
  }
}
