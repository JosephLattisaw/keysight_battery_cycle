import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:keysight_gui/c_api/keysight_c_api.dart';
import 'package:keysight_gui/screens/instrument_connection/instrument_widget.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: 4, vsync: ticker));

    final keysightConnectionStatus =
        context.select((KeysightCAPI k) => k.keysightConnectionStatus);

    useEffect(() {
      return tabController.dispose;
    }, const []);

    return Scaffold(
      appBar: PreferredSize(
        child: const ApplicationBar(),
        preferredSize: AppBar().preferredSize,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      keysightConnectionStatus
                          ? "Status: Connected"
                          : "Status: Disconnected",
                      style: TextStyle(
                        color: keysightConnectionStatus
                            ? Colors.green
                            : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Emergency Shutoff"),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    ),
                    /*Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TabWidget(
                          tabs: const [
                            Text("Instrument Connection",
                                style: TextStyle(color: null)),
                            Text("System Safety Limits"),
                            Text("Create/Edit Profile Sequences",
                                textAlign: TextAlign.center),
                            Text("Load Sequences"),
                            Text("Test Management"),
                            Text("System Telemetry"),
                          ],
                          tabWidgets: [
                            Text("joe"),
                            Text("joe"),
                            Text("joe"),
                            Text("joe"),
                            Text("joe"),
                            Text("joe"),
                          ],
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabWidget(
                  tabs: const [
                    Text("Instrument Connection",
                        style: TextStyle(color: null)),
                    Text("System Safety Limits"),
                    Text("Create/Edit Profile Sequences",
                        textAlign: TextAlign.center),
                    Text("Load Sequences"),
                    Text("Test Management"),
                    Text("System Telemetry"),
                  ],
                  tabWidgets: [
                    const InstrumentWidget(),
                    Container(),
                    Container(),
                    Container(),
                    Container(),
                    Container(),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
