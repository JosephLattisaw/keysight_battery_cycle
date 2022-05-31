import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/instrument_connection/instrument_list_view.dart';

class InstrumentWidget extends StatelessWidget {
  const InstrumentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Padding(
          padding: EdgeInsets.only(
            top: 8.0,
            left: 8.0,
            bottom: 8.0,
          ),
          child: Text(
            "Select Instrument(s) to Control:",
            style: TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(child: InstrumentListView()),
      ],
    );
  }
}