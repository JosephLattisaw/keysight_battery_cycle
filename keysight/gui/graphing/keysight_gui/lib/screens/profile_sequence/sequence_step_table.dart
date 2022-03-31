import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SequenceStepTable extends HookWidget {
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
        5,
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
                '1',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                'Charge at',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                '4.0V',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                '20A',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                '1200s',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
