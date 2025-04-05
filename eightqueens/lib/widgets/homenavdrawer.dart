import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../middleware/autoregistration.dart';
import '../middleware/deviceinfoplus.dart';
import '../middleware/listslocalstorage.dart';
import '../apinetisolates/apiprofilehandlerisolatecontroller.dart';
import '../widgets/featurediscovery.dart';
import '../pages/settingspage.dart';
import '../pages/userresultspage.dart';
import '../pages/modelresultspage.dart';
import '../pages/userrunnerspage.dart';
import '../pages/modelrunnerspage.dart';
import '../pages/userworstresultspage.dart';
import '../pages/modelworstresultspage.dart';
import '../pages/usercrownspage.dart';
import '../pages/crowncollectionpage.dart';
import '../pages/infopage.dart';

class HomeNavDrawer extends StatefulWidget {

  final Widget wCrown;
  final DioProfileHandlerIsolate dphi;
  final AutoRegLocal arl;
  final ListsLocalStorage lls;
  final DataPackageInfo Function() getDpi;
  final HomeFeatureDiscovery hfd;
  final Future<void> Function() refreshParent;

  const HomeNavDrawer({Key? key, required this.wCrown, required this.dphi, required this.arl, required this.lls, required this.getDpi, required this.hfd, required this.refreshParent}): super(key: key);

  @override
  _HomeNavDrawerState createState() => _HomeNavDrawerState();

}

class _HomeNavDrawerState extends State<HomeNavDrawer> {

  String userName = "";
  int iUserCrown = 0;
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
    iUserCrown = await widget.arl.getUserCrown();
    String uCrown = iUserCrown.toString();
    widget.refreshParent();
    if (mounted) {
      setState(() {
        userName = uName;
        sUserCrown = uCrown;
      });
    }
  }

  void _navigateToInfoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage(dpi: widget.getDpi(), dphi: widget.dphi, arl: widget.arl, lls: widget.lls, refreshParent: _refreshHeader)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerHeader = Container(
      padding: const EdgeInsets.only(right: 16),
      color: Theme.of(context).primaryColor,
      child:
        UserAccountsDrawerHeader(
          accountName: Text(userName, style: const TextStyle(fontSize: 18.0)),
          accountEmail: Text((2 > iUserCrown) ? 'Crown: $sUserCrown' : 'Crowns: $sUserCrown', style: const TextStyle(fontSize: 18.0)),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: widget.wCrown),
          ),
          margin: const EdgeInsets.only(bottom: 0),
          otherAccountsPictures: <Widget>[
            (EAutoReged.reged == widget.arl.eAutoReged)
            ? CircleAvatar(
                child: IconButton(onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage(dphi: widget.dphi, arl: widget.arl, lls: widget.lls, getDpi: widget.getDpi, hfd: widget.hfd, refreshParent: _refreshHeader)),
                  );
                },
                icon: const Icon(Icons.edit)))
            : const SizedBox.shrink(),
            CircleAvatar(
                child: IconButton(onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage(dphi: widget.dphi, arl: widget.arl, lls: widget.lls, getDpi: widget.getDpi, hfd: widget.hfd, refreshParent: _refreshHeader)),
                  );
                },
                icon: const Icon(Icons.settings))),
            CircleAvatar(
              child: IconButton(onPressed: () => _navigateToInfoPage(),
              icon: const Icon(Icons.info))),
          ],
        ),
    );
    final drawerItems = ListView(
      children: <Widget>[
        drawerHeader,
        const SizedBox(height: 8),
        ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 16, right: 32),
          leading: const Icon(Icons.star),
          visualDensity: const VisualDensity(horizontal: -4),
          title: const Text('Top Performers', style: TextStyle(fontSize: 18.0)),
          children: <Widget>[
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
            ))
          ],
        ),
        ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 16, right: 32),
          leading: const FaIcon(FontAwesomeIcons.personRunning),
          visualDensity: const VisualDensity(horizontal: -4),
          title: const Text('Top Runners', style: TextStyle(fontSize: 18.0)),
          children: <Widget>[
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
          ],
        ),
        ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 16, right: 32),
          leading: const FaIcon(FontAwesomeIcons.faceSadTear),
          visualDensity: const VisualDensity(horizontal: -4),
          title: const Text('Worst Performers', style: TextStyle(fontSize: 18.0)),
          children: [
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
          ],
        ),
        ListTile(
          leading: const Icon(Icons.person),
          minLeadingWidth: 0,
          horizontalTitleGap: 20.0,
          title: const Text('Crown Leaders', style: TextStyle(fontSize: 18.0)),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserCrownsPage(autoRegLocal: widget.arl, lls: widget.lls)),
          ),
        ),
        (!kIsWeb && (Platform.isIOS || 10.0 <= dAndroidVersion))
        ? ListTile(
            leading: Padding(padding: const EdgeInsets.only(bottom: 5), child: SizedBox.fromSize(child: widget.wCrown, size: const Size(28, 28))),
            minLeadingWidth: 0,
            title: const Text('Collect', style: TextStyle(fontSize: 18.0)),
            onTap: (EAutoReged.reged == widget.arl.eAutoReged)
              ? () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CrownCollectionPage(wCrown: widget.wCrown, dphi: widget.dphi, arl: widget.arl, lls: widget.lls, iInterval: 0, refreshParent: _refreshHeader)),
                )
              : () { showRunTestFirstTextDialog(context); },
          )
        : const SizedBox.shrink(),
        ListTile(
          leading: const Icon(Icons.settings),
          minLeadingWidth: 0,
          title: const Text('Settings', style: TextStyle(fontSize: 18.0)),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SettingsPage(dphi: widget.dphi, arl: widget.arl, lls: widget.lls, getDpi: widget.getDpi, hfd: widget.hfd, refreshParent: _refreshHeader)),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          minLeadingWidth: 0,
          title: const Text('Info', style: TextStyle(fontSize: 18.0)),
          onTap: () => _navigateToInfoPage(),
        ),
      ],
    );
    return SafeArea(child: Drawer(child: Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 10,
      radius: const Radius.circular(6),
      child: drawerItems,
    )));
  }
}
