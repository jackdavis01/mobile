import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistuserresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/userlistswidget.dart';

class UserRunnersPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  final String os;
  const UserRunnersPage({Key? key, required this.autoRegLocal, required this.lls, required this.os}) : super(key: key);
  @override
  State<UserRunnersPage> createState() => _UserRunnersPageState();
}

class _UserRunnersPageState extends State<UserRunnersPage> with TickerProviderStateMixin {
  final int order = 3;
  final int orderDirection = 2;
  DioListUserResultsIsolate dluri = DioListUserResultsIsolate();


  Future<dynamic> _callListUserRetryIsolateApi(int interval0, int thread0) {
    return dluri.callListUserResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), interval0, thread0,
                                                    order, orderDirection, 100, widget.os);
  }

  @override
  Widget build(BuildContext context) {
    return UserLists(pageTitle: "User Runners",
                     fssLslULLoadDates: widget.lls.userRunnersDatesByOs(widget.os),
                     serializeULLoadDates: widget.lls.serializeURLoadDates,
                     deserializeULLoadDates: widget.lls.deserializeURLoads,
                     lslUser: widget.lls.userRunnersByOs(widget.os),
                     serializeLllura: widget.lls.serializeLlluraList,
                     deserializeLllura: widget.lls.deserializeLlluList,
                     callListUserRetryIsolateApi: _callListUserRetryIsolateApi);
  }

}
