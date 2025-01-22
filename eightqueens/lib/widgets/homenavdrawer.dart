import 'package:flutter/material.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../pages/userresultspage.dart';
import '../pages/modelresultspage.dart';
import '../pages/infopage.dart';

class HomeNavDrawer extends StatefulWidget {

  final Widget wCrown;
  final AutoRegLocal autoRegLocal;
  final ListsLocalStorage lls;
  final DataPackageInfo Function() getDpi;

  const HomeNavDrawer({Key? key, required this.wCrown, required this.autoRegLocal, required this.lls, required this.getDpi}): super(key: key);

  @override
  _HomeNavDrawerState createState() => _HomeNavDrawerState();

}

class _HomeNavDrawerState extends State<HomeNavDrawer> {

  String userName = "";
  String sUserCrown = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String uName = await widget.autoRegLocal.getUserName();
      String uCrown = (await widget.autoRegLocal.getUserCrown()).toString();
      setState(() {
        userName = uName;
        sUserCrown = uCrown;
      });
    });
    super.initState();
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
      otherAccountsPictures: const <Widget>[],
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        const ListTile(
          title: Text('Top Performers', style: TextStyle(fontSize: 18.0)),
          onTap: null,
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            title: const Text('User Stat', style: TextStyle(fontSize: 18.0)),
            minLeadingWidth: 20.0,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserResultsPage(autoRegLocal: widget.autoRegLocal, lls: widget.lls)),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 20.0), child: 
          ListTile(
            title: const Text('Model Stat', style: TextStyle(fontSize: 18.0)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ModelResultsPage(autoRegLocal: widget.autoRegLocal, lls: widget.lls)),
            ),
        )),
        ListTile(
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
