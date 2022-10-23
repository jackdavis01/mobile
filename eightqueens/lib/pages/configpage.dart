import 'package:flutter/material.dart';
import 'package:renderer_switcher/renderer_switcher.dart';
import '../widgets/globalwidgets.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  @override
  void initState() {
    getCurrentWebRenderer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: null,
        title: Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
                icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          ),
          const Expanded(
              child: Text("Config", textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 18)
        ]),
      ),
      backgroundColor: Colors.blue[50],
      body: ListView(
        children: <Widget>[
          Align(
              child: RoundedContainer(
                  width: double.infinity,
                  constraints: const BoxConstraints(minWidth: 296, maxWidth: 396),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  backgroundcolor: Colors.blue.shade100,
                  child: Column(
                    children: <Widget>[
                      // remove const if you uncomment widgets below
                      Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minWidth: 276, maxWidth: 376),
                          child: const Padding(
                              padding: EdgeInsets.fromLTRB(12, 16, 12, 12),
                              child: Text("Web Config:",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
                      RoundedContainer(
                          width: double.infinity,
                          constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Text("Web Renderer: ",
                                            style: TextStyle(fontSize: 20),
                                            overflow: TextOverflow.ellipsis))),
                                Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: DropdownButton(
                                        items: GC.lsWebRenderers.map((String item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(item,
                                                style: const TextStyle(
                                                    fontSize: 18, fontWeight: FontWeight.bold)),
                                          );
                                        }).toList(),
                                        value: (WebRenderer.auto == GC.wrSwitch)
                                            ? GC.lsWebRenderers[0]
                                            : (WebRenderer.html == GC.wrSwitch)
                                                ? GC.lsWebRenderers[1]
                                                : (WebRenderer.canvaskit == GC.wrSwitch)
                                                    ? GC.lsWebRenderers[2]
                                                    : GC.lsWebRenderers[0],
                                        onChanged: switchWebRenderer,
                                        focusColor: Colors.white)),
                              ])
                            ],
                          )),
                      /*Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minWidth: 276, maxWidth: 376),
                          child: const Padding(
                              padding: EdgeInsets.fromLTRB(12, 32, 12, 12),
                              child: Text("Import Replace:", style: TextStyle(fontSize: 20)))),*/
                    ],
                  ))) //)
        ],
      ),
    );
  }

  Future<void> getCurrentWebRenderer() async {
    // Returns WebRenderer.html, WebRenderer.canvaskit or WebRenderer.auto
    WebRenderer wrSwitch = await RendererSwitcher.getCurrentWebRenderer();
    setState(() {
      GC.wrSwitch = wrSwitch;
    });
  }

  void switchWebRenderer(String? value) {
    WebRenderer newValue = WebRenderer.auto;
    if (value == GC.lsWebRenderers[0]) {
      newValue = WebRenderer.auto;
    } else if (value == GC.lsWebRenderers[1]) {
      newValue = WebRenderer.html;
    } else if (value == GC.lsWebRenderers[2]) {
      newValue = WebRenderer.canvaskit;
    }
    // Switches web renderer to value and reloads the window.
    RendererSwitcher.switchWebRenderer(newValue);
    GC.wrSwitch = newValue;
  }
}
