import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/instrument_widget.dart';

class TabWidget extends HookWidget {
  const TabWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticker = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: 4, vsync: ticker));

    useEffect(() {
      return tabController.dispose;
    }, const []);

    return Column(
      children: [
        Container(
          color: Color(Colors.black.value).withOpacity(0.95),
          child: TabBar(
            tabs: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Instrument Connection"),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Profile Sequence"),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Measurements"),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Test"),
              ),
            ],
            controller: tabController,
            indicator: BoxDecoration(color: Colors.blue.shade900),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              boxShadow: [
                BoxShadow(
                  blurRadius: 5,
                  spreadRadius: 4,
                  color: Colors.black.withOpacity(0.8),
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: TabBarView(
              children: [
                InstrumentWidget(),
                Text("tab 2"),
                Text("tab 3"),
                Text("tab 4"),
              ],
              controller: tabController,
            ),
          ),
        ),
      ],
    );
  }
}
