import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SequenceStepTable extends HookWidget {
  const SequenceStepTable({Key? key, required this.table}) : super(key: key);

  final List<List<dynamic>> table;

  String modeName(int action) {
    String result = "";

    if (action == 0) {
      result = "Rest";
    } else if (action == 1) {
      result = "Charge at";
    } else if (action == 2) {
      result = "Discharge at";
    }

    return result;
  }

  String voltageString(double value) {
    String result = "";
    result = value.toString() + "V";

    return result;
  }

  String currentString(double value) {
    String result = "";
    result = value.toString() + "A";

    return result;
  }

  String secondsString(int value) {
    String result = "";
    result = value.toString() + "s";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final dataTableSelectedIndex = useState(-1);

    return DataTable(
      headingRowColor:
          MaterialStateColor.resolveWith((states) => Colors.blue.shade900),
      showCheckboxColumn: false,
      columns: [
        DataColumn(
          label: Text(
            'Function',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Step',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Action / Step Type',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Voltage (V)',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Current (A)',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Time',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      rows: List<DataRow>.generate(
        table.length,
        (index) => DataRow(
          color: MaterialStateProperty.resolveWith<Color>((states) {
            if (index == dataTableSelectedIndex.value) return Colors.blue;
            if (index % 2 == 0) return Colors.grey.shade700;
            return Colors.grey.shade800;
          }),
          onSelectChanged: (value) {
            if (value == false)
              dataTableSelectedIndex.value = -1;
            else
              dataTableSelectedIndex.value = index;
          },
          selected: index == dataTableSelectedIndex.value,
          cells: <DataCell>[
            DataCell(
              Text(
                'Step',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                (index + 1).toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                modeName(table.elementAt(index).elementAt(0)),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                voltageString(table.elementAt(index).elementAt(3)),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                currentString(table.elementAt(index).elementAt(2)),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                secondsString(table.elementAt(index).elementAt(1)),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
