import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistuserresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/userlistswidget.dart';

class UserWorstResultsPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  const UserWorstResultsPage({Key? key, required this.autoRegLocal, required this.lls}) : super(key: key);
  @override
  State<UserWorstResultsPage> createState() => _UserWorstResultsPageState();
}

class _UserWorstResultsPageState extends State<UserWorstResultsPage> with TickerProviderStateMixin {
  final int order = 4;
  final int orderDirection = 2;
  DioListUserResultsIsolate dluri = DioListUserResultsIsolate();

  Future<dynamic> _callListUserRetryIsolateApi(int interval0, int thread0) {
    return dluri.callListUserResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), interval0, thread0,
                                                    order, orderDirection, 100);
  }

  @override
  Widget build(BuildContext context) {
    return UserLists(pageTitle: "User Stat",
                     fssLslULLoadDates: widget.lls.fssUserWorstResultsDates,
                     serializeULLoadDates: widget.lls.serializeURLoadDates,
                     deserializeULLoadDates: widget.lls.deserializeURLoads,
                     lslUser: widget.lls.lslUserWorstResults,
                     serializeLllura: widget.lls.serializeLlluraList,
                     deserializeLllura: widget.lls.deserializeLlluList,
                     callListUserRetryIsolateApi: _callListUserRetryIsolateApi);
  }

}
