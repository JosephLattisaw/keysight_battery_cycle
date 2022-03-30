import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_list_item.dart';

class SequenceListView extends StatelessWidget {
  const SequenceListView(
      {Key? key, required this.selectedSequence, required this.selectedIndex})
      : super(key: key);

  static const sequenceList = <String>["Sequence 1", "Sequence 2"];
  static Color nonSelectedColor = Colors.black.withOpacity(0.8);
  static Color selectedColor = Colors.black.withOpacity(0.4);

  final void Function(int) selectedSequence;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(180),
      child: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Sequences",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ListView.builder(
            itemCount: sequenceList.length,
            itemBuilder: (context, index) {
              return SequenceListItem(
                title: sequenceList.elementAt(index),
                onTap: () {
                  selectedSequence(index);
                },
                color:
                    selectedIndex == index ? selectedColor : nonSelectedColor,
              );
            },
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
