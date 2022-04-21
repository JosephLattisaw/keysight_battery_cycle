import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:keysight_gui/keysight_c_api.dart';

class MeasurementTableWidget extends HookWidget {
  const MeasurementTableWidget({Key? key, this.sequenceNumber = -1})
      : super(key: key);

  final int sequenceNumber;

  @override
  Widget build(BuildContext context) {
    final cApi = Provider.of<KeysightCAPI>(context, listen: false);
    final cellNames = context.select((KeysightCAPI k) => k.cellNames);
    final voltageValues = context.select((KeysightCAPI k) => k.voltageValues);
    final currentValues = context.select((KeysightCAPI k) => k.currentValues);
    final capacityAmpHrs = context.select((KeysightCAPI k) => k.capacityAmpHrs);
    final capacityWattHrs =
        context.select((KeysightCAPI k) => k.capacityWattHrs);

    final tableSize = useState(0);
    final cellIndexing = useState(<List<int>>[]);

    void setTableSize(int size) {
      if (tableSize.value != size) tableSize.value = size;
    }

    int getModuleIndex(int index) {
      if (sequenceNumber == -1)
        return index ~/ 32;
      else {
        return cellIndexing.value.elementAt(index).elementAt(0);
      }
    }

    int getCellIndex(int index) {
      if (sequenceNumber == -1)
        return index % 32;
      else {
        return cellIndexing.value.elementAt(index).elementAt(1);
      }
    }

    if (sequenceNumber == -1) {
      setTableSize(32 * 8);
    } else {
      cellIndexing.value = cApi.getCellsSelected(sequenceNumber);
      setTableSize(cellIndexing.value.length);
    }

    return SingleChildScrollView(
      primary: false,
      child: DataTable(
        headingRowColor:
            MaterialStateColor.resolveWith((states) => Colors.blue.shade900),
        columns: const [
          DataColumn(
            label: Text(
              'Cell Number',
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
              'Capacity (aH)',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Capacity (Wh)',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'State',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Seq',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Step',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        rows: List<DataRow>.generate(
          tableSize.value,
          (index) => DataRow(
            color: MaterialStateProperty.resolveWith<Color>((states) {
              if (index % 2 == 0) return Colors.grey.shade700;
              return Colors.grey.shade800;
            }),
            cells: <DataCell>[
              DataCell(
                Text(
//                  'Data',
                  cellNames
                      .elementAt(getModuleIndex(index))
                      .elementAt(getCellIndex(index))
                      .toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  voltageValues
                      .elementAt(getModuleIndex(index))
                      .elementAt(getCellIndex(index))
                      .toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  currentValues
                      .elementAt(getModuleIndex(index))
                      .elementAt(getCellIndex(index))
                      .toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  capacityAmpHrs
                      .elementAt(getModuleIndex(index))
                      .elementAt(getCellIndex(index))
                      .toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  capacityWattHrs
                      .elementAt(getModuleIndex(index))
                      .elementAt(getCellIndex(index))
                      .toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  "RUNNING",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  "ABORTED",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  "8",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  "256",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
