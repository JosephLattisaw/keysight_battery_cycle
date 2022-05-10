import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:keysight_gui/load_sequences.dart';
import 'package:keysight_gui/system.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:keysight_gui/screens/instrument_connection/instrument_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/profile_sequence_widget.dart';
import 'package:keysight_gui/screens/measurements/measurement_widget.dart';
import 'package:keysight_gui/screens/test/test_widget.dart';
import 'package:keysight_gui/expandable_table.dart';

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: 4, vsync: ticker));

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
                      "Disconnected from Keysight",
                      style: TextStyle(
                        color: Colors.red,
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
                      Text("Instrument Connection"),
                      Text("Create/Edit Profile Sequences"),
                      Text("Load Sequences"),
                      Text("Test Management"),
                      //Text("Measurements"),
                      //Text("System"),

                      Text("System Telemetry"),
                    ],
                    tabWidgets: [
                      const InstrumentWidget(),
                      const ProfileSequenceWidget(),
                      LoadSequences(),
                      const TestWidget(),

                      /*MeasurementWidget(
                        key: UniqueKey(),
                      ),*/
                      //JoeHomePage(),

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
