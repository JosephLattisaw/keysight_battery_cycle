import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/profile_sequence/sequence_list_item.dart';

class SequenceListView extends StatelessWidget {
  SequenceListView(
      {Key? key,
      required this.selectedSequence,
      required this.selectedIndex,
      required this.sequenceList,
      required this.sequenceItalic})
      : super(key: key);

  static Color nonSelectedColor = Colors.black.withOpacity(0.8);
  static Color selectedColor = Colors.black.withOpacity(0.4);

  final void Function(int) selectedSequence;
  final int selectedIndex;
  final List<String> sequenceList;
  final List<bool> sequenceItalic;

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
                "Profiles",
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
                italic: !sequenceItalic.elementAt(index),
              );
            },
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
