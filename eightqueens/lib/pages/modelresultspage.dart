import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistmodelresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/modellistswidget.dart';

class ModelResultsPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  final String os;
  const ModelResultsPage({Key? key, required this.autoRegLocal, required this.lls, required this.os}) : super(key: key);
  @override
  State<ModelResultsPage> createState() => _ModelResultsPageState();
}

class _ModelResultsPageState extends State<ModelResultsPage> with TickerProviderStateMixin {
  final int order = 2;
  final int orderDirection = 1;
  DioListModelResultsIsolate dlmri = DioListModelResultsIsolate();

  Future<dynamic> _callListModelRetryIsolateApi(int interval0, int thread0) {
    return dlmri.callListModelResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), interval0, thread0,
                                                    order, orderDirection, 100, widget.os);
  }

  @override
  Widget build(BuildContext context) {
    return ModelLists(pageTitle: "Model Stat",
                      fssLslMLLoadDates: widget.lls.modelResultsDatesByOs(widget.os),
                      serializeMLLoadDates: widget.lls.serializeMRLoadDates,
                      deserializeMLLoadDates: widget.lls.deserializeMRLoads,
                      lslModel: widget.lls.modelResultsByOs(widget.os),
                      serializeLllmra: widget.lls.serializeLllmraList,
                      deserializeLllmra: widget.lls.deserializeLllmList,
                      callListModelRetryIsolateApi: _callListModelRetryIsolateApi);
  }

}
