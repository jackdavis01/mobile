import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/modellistswidget.dart';

class ModelRunnersPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  const ModelRunnersPage({Key? key, required this.autoRegLocal, required this.lls}) : super(key: key);
  @override
  State<ModelRunnersPage> createState() => _ModelRunnersPageState();
}

class _ModelRunnersPageState extends State<ModelRunnersPage> with TickerProviderStateMixin {
  final int order = 1;
  final int orderDirection = 2;
  DioListModelResultsIsolate dlmri = DioListModelResultsIsolate();

  Future<dynamic> _callListModelRetryIsolateApi(int interval0, int thread0) {
    return dlmri.callListModelResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), interval0, thread0,
                                                    order, orderDirection, 100);
  }

  @override
  Widget build(BuildContext context) {
    return ModelLists(pageTitle: "Model Runners",
                      fssLslMLLoadDates: widget.lls.fssModelRunnersDates,
                      serializeMLLoadDates: widget.lls.serializeMRLoadDates,
                      deserializeMLLoadDates: widget.lls.deserializeMRLoads,
                      lslModel: widget.lls.lslModelRunners,
                      serializeLllmra: widget.lls.serializeLllmraList,
                      deserializeLllmra: widget.lls.deserializeLllmList,
                      callListModelRetryIsolateApi: _callListModelRetryIsolateApi);
  }

}
