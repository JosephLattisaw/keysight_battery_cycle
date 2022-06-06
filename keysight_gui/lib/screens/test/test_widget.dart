import 'package:flutter/material.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:keysight_gui/tab_widget.dart';
import 'package:keysight_gui/screens/test/test_tabbed_widget.dart';
import 'package:provider/provider.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({Key? key}) : super(key: key);

  Color? getTabTextColor(int status) {
    switch (status) {
      case 3:
        return Colors.red;
      case 4:
        return Colors.amber;
      case 5:
        return Colors.green;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotStatuses = context.select((KeysightCAPI k) => k.slotStatuses);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabWidget(
              tabs: List.generate(
                  8,
                  (index) => Text(
                        "Test #${index + 1}",
                        style: TextStyle(
                          color: getTabTextColor(slotStatuses.elementAt(index)),
                        ),
                      )),
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
