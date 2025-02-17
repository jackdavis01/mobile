import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../apinetisolates/apiprofilehandlerisolatecontroller.dart';
import '../pages/settingspage.dart';
import '../pages/userresultspage.dart';
import '../pages/modelresultspage.dart';
import '../pages/userrunnerspage.dart';
import '../pages/modelrunnerspage.dart';
import '../pages/userworstresultspage.dart';
import '../pages/modelworstresultspage.dart';
import '../pages/infopage.dart';

class HomeNavDrawer extends StatefulWidget {

  final Widget wCrown;
  final DioProfileHandlerIsolate dphi;
  final AutoRegLocal arl;
  final ListsLocalStorage lls;
  final DataPackageInfo Function() getDpi;

  const HomeNavDrawer({Key? key, required this.wCrown, required this.dphi, required this.arl, required this.lls, required this.getDpi}): super(key: key);

  @override
  _HomeNavDrawerState createState() => _HomeNavDrawerState();

}

class _HomeNavDrawerState extends State<HomeNavDrawer> {

  String userName = "";
  String sUserCrown = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshHeader();
    });
    super.initState();
  }

  Future<void> _refreshHeader() async {
    String uName = await widget.arl.getUserName();
    String uCrown = (await widget.arl.getUserCrown()).toString();
    setState(() {
      userName = uName;
      sUserCrown = uCrown;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerHeader = UserAccountsDrawerHeader(
      accountName: Text(userName, style: const TextStyle(fontSize: 18.0)),
      accountEmail: Text('Crown: $sUserCrown', style: const TextStyle(fontSize: 18.0)),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: widget.wCrown),
      ),
      otherAccountsPictures: (EAutoReged.reged == widget.arl.eAutoReged) ? <Widget>[
        CircleAvatar(
          child: IconButton(onPressed:  () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(dphi: widget.dphi, arl: widget.arl, lls: widget.lls, getDpi: widget.getDpi, refreshParent: _refreshHeader)),
            );
          }, icon: const Icon(Icons.edit)))] : null,
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        const ListTile(
          leading: Icon(Icons.star),
          minLeadingWidth: 0,
          title: Text('Top Performers', style: TextStyle(fontSize: 18.0)),
          onTap: null,
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            leading: const Icon(Icons.person),
            minLeadingWidth: 0,
            horizontalTitleGap: 20.0,
            title: const Text('User Stat', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserResultsPage(autoRegLocal: widget.arl, lls: widget.lls)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            leading: const Icon(Icons.phone_android),
            minLeadingWidth: 0,
            horizontalTitleGap: 20.0,
            title: const Text('Model Stat', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ModelResultsPage(autoRegLocal: widget.arl, lls: widget.lls)),
            ),
        )),
        const ListTile(
            leading: FaIcon(FontAwesomeIcons.personRunning),
            minLeadingWidth: 0,
          title: Text('Top Runners', style: TextStyle(fontSize: 18.0)),
          onTap: null,
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            leading: const Icon(Icons.person),
            minLeadingWidth: 0,
            horizontalTitleGap: 20.0,
            title: const Text('User Runners', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserRunnersPage(autoRegLocal: widget.arl, lls: widget.lls)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            leading: const Icon(Icons.phone_android),
            minLeadingWidth: 0,
            horizontalTitleGap: 20.0,
            title: const Text('Model Runners', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ModelRunnersPage(autoRegLocal: widget.arl, lls: widget.lls)),
            ),
        )),
        const ListTile(
          leading: FaIcon(FontAwesomeIcons.faceSadTear),
          minLeadingWidth: 0,
          title: Text('Worst Performers', style: TextStyle(fontSize: 18.0)),
          onTap: null,
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            leading: const Icon(Icons.person),
            minLeadingWidth: 0,
            horizontalTitleGap: 20.0,
            title: const Text('User Stat', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserWorstResultsPage(autoRegLocal: widget.arl, lls: widget.lls)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            leading: const Icon(Icons.phone_android),
            minLeadingWidth: 0,
            horizontalTitleGap: 20.0,
            title: const Text('Model Stat', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ModelWorstResultsPage(autoRegLocal: widget.arl, lls: widget.lls)),
            ),
        )),
        ListTile(
          leading: const Icon(Icons.info),
          minLeadingWidth: 0,
          title: const Text('Info', style: TextStyle(fontSize: 18.0)),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => InfoPage(dpi: widget.getDpi())),
          ),
        ),
      ],
    );
    return Drawer(
        child: drawerItems,
    );
  }
}
