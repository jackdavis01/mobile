import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/modellistswidget.dart';

class ModelWorstResultsPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  const ModelWorstResultsPage({Key? key, required this.autoRegLocal, required this.lls}) : super(key: key);
  @override
  State<ModelWorstResultsPage> createState() => _ModelWorstResultsPageState();
}

class _ModelWorstResultsPageState extends State<ModelWorstResultsPage> with TickerProviderStateMixin {
  final int order = 2;
  final int orderDirection = 2;
  DioListModelResultsIsolate dlmri = DioListModelResultsIsolate();

  Future<dynamic> _callListModelRetryIsolateApi(int interval0, int thread0) {
    return dlmri.callListModelResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), interval0, thread0,
                                                    order, orderDirection, 100);
  }

  @override
  Widget build(BuildContext context) {
    return ModelLists(pageTitle: "Model Stat",
                      fssLslMLLoadDates: widget.lls.fssModelWorstResultsDates,
                      serializeMLLoadDates: widget.lls.serializeMRLoadDates,
                      deserializeMLLoadDates: widget.lls.deserializeMRLoads,
                      lslModel: widget.lls.lslModelWorstResults,
                      serializeLllmra: widget.lls.serializeLllmraList,
                      deserializeLllmra: widget.lls.deserializeLllmList,
                      callListModelRetryIsolateApi: _callListModelRetryIsolateApi);
  }

}
