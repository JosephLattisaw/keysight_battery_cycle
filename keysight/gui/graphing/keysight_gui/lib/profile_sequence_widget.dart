import 'package:flutter/material.dart';
import 'package:keysight_gui/sequence_list_view.dart';

class ProfileSequenceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
              child: SequenceListView(),
            ),
          ),
          Expanded(
              flex: 3,
              child: Container(
                height: double.infinity,
                color: Colors.white,
                child: TextFormField(),
              )),
        ],
      ),
    );
  }
}
