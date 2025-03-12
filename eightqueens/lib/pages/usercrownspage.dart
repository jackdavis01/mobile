import 'dart:async';
import 'package:flutter/material.dart';
import '../apinetisolates/apilistuserresultsisolatecontroller.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../widgets/usercrownlistswidget.dart';

class UserCrownsPage extends StatefulWidget {
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  const UserCrownsPage({Key? key, required this.autoRegLocal, required this.lls}) : super(key: key);
  @override
  State<UserCrownsPage> createState() => _UserCrownsPageState();
}

class _UserCrownsPageState extends State<UserCrownsPage> with TickerProviderStateMixin {
  final int order = 7;
  final int orderDirection = 2;
  DioListUserResultsIsolate dluri = DioListUserResultsIsolate();


  Future<dynamic> _callListUserRetryIsolateApi() {
    return dluri.callListUserResultsRetryIsolateApi(widget.autoRegLocal.getUserId(), 0, 0,
                                                    order, orderDirection, 100);
  }

  @override
  Widget build(BuildContext context) {
    return UserCrownLists(pageTitle: "Crown Leaders",
                     fssLslULLoadDates: widget.lls.fssUserCrownsDates,
                     serializeULLoadDates: widget.lls.serializeURLoadDates,
                     deserializeULLoadDates: widget.lls.deserializeURLoads,
                     lslUser: widget.lls.lslUserCrowns,
                     serializeLllura: widget.lls.serializeLlluraList,
                     deserializeLllura: widget.lls.deserializeLlluList,
                     callListUserRetryIsolateApi: _callListUserRetryIsolateApi);
  }

}
