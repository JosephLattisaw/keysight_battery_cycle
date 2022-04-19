import 'package:flutter/material.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:keysight_gui/screens/test/test_tabbed_widget.dart';

class TestWidget extends StatelessWidget {
  TestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabWidget(
              tabs: List.generate(8, (index) => Text("Test #${index + 1}")),
              tabWidgets: List.generate(
                  8,
                  (index) => TestTabbedWidget(
                        sequenceNumber: index,
                      )),
            ),
          ),
        ),
      ],
    );
  }
}
