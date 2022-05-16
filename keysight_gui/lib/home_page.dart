import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:keysight_gui/load_sequences.dart';
import 'package:keysight_gui/system.dart';
import 'package:keysight_gui/system_safety.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:keysight_gui/screens/instrument_connection/instrument_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/profile_sequence_widget.dart';
import 'package:keysight_gui/screens/measurements/measurement_widget.dart';
import 'package:keysight_gui/screens/test/test_widget.dart';
import 'package:keysight_gui/expandable_table.dart';
import 'package:provider/provider.dart';

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  bool amberAlertShown = false;
  bool amberAlertReady = true;
  bool criticalAlertShown = false;

  Timer? timer;

  void updateTimer() {
    amberAlertReady = true;
  }

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: 4, vsync: ticker));

    final keysightConnectionStatus =
        context.select((KeysightCAPI k) => k.keysightConnectionStatus);

    final backend = Provider.of<KeysightCAPI>(context, listen: false);

    useMemoized(() {
      backend.limitHit = (bool critical) {
        if (!criticalAlertShown &&
            ((!amberAlertShown && amberAlertReady) || critical)) {
          critical ? (criticalAlertShown = true) : (amberAlertShown = true);

          if (critical && amberAlertShown) {
            amberAlertShown = false;
            Navigator.pop(context);
          }

          showModalBottomSheet<void>(
            isDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                color: critical ? Colors.red : Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        critical
                            ? "HARD LIMIT WAS REACHED, TEST WAS STOPPED\nPLEASE CHECK TEST!"
                            : 'SOFT LIMIT WAS HIT PLEASE CHECK TEST!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        child: const Text('Continue'),
                        onPressed: () {
                          if (amberAlertShown && amberAlertReady) {
                            amberAlertReady = false;
                            timer =
                                Timer(const Duration(seconds: 20), updateTimer);
                          }

                          critical
                              ? (criticalAlertShown = false)
                              : (amberAlertShown = false);

                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      };
    });

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
                    Spacer(),
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
                      SystemSafety(),
                      const ProfileSequenceWidget(),
                      LoadSequences(),
                      const TestWidget(),
                      SystemPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
