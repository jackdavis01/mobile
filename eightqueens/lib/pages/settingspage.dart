import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/adhandler.dart';
import '../middleware/autoregistration.dart';
import '../middleware/listslocalstorage.dart';
import '../parameters/themedata.dart';
import '../widgets/globalwidgets.dart';
import '../widgets/featurediscovery.dart';
import '../apinetisolates/apiprofilehandlerisolatecontroller.dart';
import 'infopage.dart';

class SettingsPage extends StatefulWidget {

  final DioProfileHandlerIsolate dphi;
  final AutoRegLocal arl;
  final ListsLocalStorage lls;
  final DataPackageInfo Function() getDpi;
  final HomeFeatureDiscovery hfd;
  final Future<void> Function() refreshParent;

  const SettingsPage({Key? key, required this.dphi, required this.arl, required this.lls, required this.getDpi, required this.hfd, required this.refreshParent}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final int _minUsernameLength = 4;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userName = "";
  bool? _success;
  bool _available = false;
  final String _initUsernameHelperText = "Min 4 chars.";
  String _usernameHelperText = "";
  TextStyle? _helperStyle;
  final String _initHintText = 'My funny name 🙂';
  String _hintText = "";
  Widget? _suffixIcon;

  @override
  void initState() {
    _usernameHelperText = _initUsernameHelperText;
    _hintText = _initHintText;
    _usernameController.addListener(_onNameChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String _uName = await widget.arl.getUserName();
      setState(() {
        _userName = _uName;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    debugPrint("settingspage.dart, _usernameController.text: ${_usernameController.text}");
    if (_minUsernameLength <= _usernameController.text.length) {
      _isAvailableUsernameAfterWait().then((ldBools) {
        bool? success = ldBools[0];
        bool available = ldBools[1];
        setState(() {
          _success = success;
          _available = available;
          _usernameHelperText = (null == _success) ? _initUsernameHelperText : (_success!) ? _available ? 'Available (Max 22 chars)' : 'Not available' : 'Check the net';
          _helperStyle = TextStyle(color: (null == _success) ? null : _available ? Colors.green : Colors.red);
          _suffixIcon = (null == _success) ? null : _available
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.close, color: Colors.red);
        });
      });
    } else {
      setState(() {
        _success = null;
        _usernameHelperText = _initUsernameHelperText;
        _helperStyle = null;
        _hintText = _initHintText;
        _suffixIcon = null;
      });
    }
  }

  Future<List<dynamic>> _isAvailableUsernameAfterWait() async {
    bool? success;
    bool available = false;
    await Future.delayed(const Duration(seconds: 1));
    if (_minUsernameLength <= _usernameController.text.length) {
      int userId = widget.arl.getUserId();
      String base64username = base64.encode(utf8.encode(_usernameController.text));
      List<dynamic> ldValue = await widget.dphi.callProfileHandlerRetryIsolateApi(2, userId, base64username);
      success = ldValue[0];
      NewProfile newProfile = ldValue[2];
      available = newProfile.available;
    }
    return [success, available];
  } 

  String? _textFormFieldValidator(String? value) {
    String userName = "";
    if (value?.isEmpty ?? false) {
      return 'Name is empty';
    } else if (_minUsernameLength <= (value?.length ?? 0)) {
      userName = value ?? "";
    }
    if (_minUsernameLength <= userName.length) {
      return null;
    } else {
      return _initUsernameHelperText;
    }
  }

  void _submitPressed() { _saveNewUsername(); }

  Future<void> _saveNewUsername() async {
    if (_formKey.currentState?.validate() ?? false) {
      int userId = widget.arl.getUserId();
      String base64username = base64.encode(utf8.encode(_usernameController.text));
      List<dynamic> ldValue = await widget.dphi.callProfileHandlerRetryIsolateApi(3, userId, base64username);
      bool success = ldValue[0];
      NewProfile newProfile = ldValue[2];
      bool updated = newProfile.updated;
      if (success && updated) {
        String newUsername = newProfile.newUsername;
        widget.arl.setUserNameLocal(newUsername);
        _usernameController.clear();
        await widget.refreshParent();
        setState(() {
          _hintText = "Saved 😊";
          _userName = newUsername;
        });
        widget.lls.clearLocalListDates();
      }
    }
  }

  Future<void> _unfocusAndNavigatorPop() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    widget.hfd.checkDiscoveryCompleted();

    return Theme(
      data: blueTheme,
      child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () async {
              _unfocusAndNavigatorPop();
            }),
          backgroundColor: blueTheme.colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'Info Page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfoPage(dpi: widget.getDpi(), dphi: widget.dphi, arl: widget.arl, lls: widget.lls, refreshParent: widget.refreshParent)),
                );
              },
            ),
          ],
        ),
        //backgroundColor: Colors.blue[50],
        body: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
          ListView(
            children: <Widget>[
              Align(
                child: RoundedContainer(
                  width: double.infinity,
                  constraints: const BoxConstraints(minWidth: 296, maxWidth: 496),
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(10),
                  child: Form(key: _formKey, child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minWidth: 276, maxWidth: 476),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("User name:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                      Padding(
                        padding: const EdgeInsets.only(left: 32, bottom: 8),
                        child: Text(_userName,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 17),
                          overflow: TextOverflow.ellipsis)),
                      (EAutoReged.reged == widget.arl.eAutoReged)
                      ? RoundedContainer(
                          width: double.infinity,
                          backgroundcolor: Theme.of(context).hoverColor,
                          constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
                          margin: const EdgeInsets.all(6.0),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: TextFormField(
                                  controller: _usernameController,
                                  validator: _textFormFieldValidator,
                                  maxLength: 22,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    filled: true,
                                    fillColor: Theme.of(context).cardColor,
                                    icon: const Icon(Icons.person),
                                    labelText: 'Enter your new user name',
                                    hintText: _hintText,
                                    helperText: _usernameHelperText,
                                    helperStyle: _helperStyle,
                                    suffixIcon: _suffixIcon,
                                  ),
                                )),
                            ],
                        ))
                      : const SizedBox.shrink(),
                      (EAutoReged.reged == widget.arl.eAutoReged)
                      ? Align(child: Padding(padding: const EdgeInsets.only(top: 8), child:
                            ElevatedButton(
                              onPressed: ((_success ?? false) && _available) ? _submitPressed : null,
                              child: const Text("Submit", style: TextStyle(fontSize: 18))
                            ),
                          ))
                      : RoundedContainer(
                          width: double.infinity,
                          backgroundcolor: Theme.of(context).hoverColor,
                          constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
                          margin: const EdgeInsets.all(6.0),
                          padding: const EdgeInsets.all(14.0),
                          child: const Text('Hello, if you don\'t like the username "Me" and want to change it, '
                                            'please submit a result first by running the test on, for example, '
                                            '2 threads. After that, you will be able to change your username. '
                                            'Don\'t forget to turn on the internet.',
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 17)),
                        ),
                    ]),
                  ),
                ),
              ),
              // Add the new RoundedContainer here
              Center(child: RoundedContainer(
                width: double.infinity,
                backgroundcolor: Colors.white,
                constraints: const BoxConstraints(minWidth: 296, maxWidth: 496),
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.all(10.0),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('Feature discovery:', style: TextStyle(fontSize: 17), maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)),
                    Switch(
                      value: !widget.hfd.bHasAlreadyBeenCompleted,
                      onChanged: (bool value) {
                        setState(() {
                          widget.hfd.setHasAlreadyBeenCompleted(!value);
                        });
                      },
                    ),
                  ],
                )),
              )),
              const SizedBox(height: 64), // ad banner place
            ],
          ),
          const AdBanner(),
        ]),
      ),
    ));
  }

}
