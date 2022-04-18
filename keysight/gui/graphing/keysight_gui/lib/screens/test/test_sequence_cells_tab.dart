import 'package:flutter/material.dart';

class TestSequenceCellsTab extends StatelessWidget {
  String getCellString(int module, int index) {
    String res = "";

    res += module.toString();

    if (index < 10)
      res += "00";
    else
      res += "0";

    res += index.toString();

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: ScrollController(),
        itemCount: 32,
        itemBuilder: (BuildContext context, int c_idx) {
          return Row(
            children: List.generate(
                8,
                (l_idx) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: TestCellsCheckboxWidget(
                          cellNumber: getCellString(l_idx + 1, c_idx + 1),
                        ),
                      ),
                    )),
          );
        });
  }
}

class TestCellsCheckboxWidget extends StatelessWidget {
  TestCellsCheckboxWidget({Key? key, required this.cellNumber})
      : super(key: key);

  final String cellNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
      ),
      child: CheckboxListTile(
        title: Text("Cell $cellNumber",
            style: TextStyle(
              color: Colors.white,
            )),
        value: false,
        onChanged: (newValue) {},
        controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
    );
  }
}
