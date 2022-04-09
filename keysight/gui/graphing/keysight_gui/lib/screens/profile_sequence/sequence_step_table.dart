import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/screens/profile_sequence/common_profile_sequence.dart';

class SequenceStepTable extends HookWidget {
  SequenceStepTable(
      {Key? key, required this.table, required this.onIndexChanged})
      : super(key: key) {
    totalTableLength = getTableTotalLength();
  }

  final List<List<dynamic>> table;
  late final int totalTableLength;

  final void Function(int) onIndexChanged;

  String modeName(int action) {
    return modeDescription.elementAt(action);
  }

  String testName(int action) {
    return testTypeDescription.elementAt(action).elementAt(0);
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

  int getTableTotalLength() {
    int result = 0;

    for (var element in table) {
      result++;
      for (var second in element.elementAt(4)) {
        result++;
      }
    }

    return result;
  }

  //TODO this exact function is in profile sequence widget
  List<int> getTableMapping(int index) {
    List<int> result = List.filled(2, 0, growable: false);

    int mainIndex = 0;
    int secondIndex = -1;
    int totalIndex = 0;
    bool nestedBreak = false;

    for (var element in table) {
      secondIndex = -1;

      if (totalIndex == index) {
        break;
      }

      for (var second in element.elementAt(4)) {
        secondIndex++;
        totalIndex++;
        if (totalIndex == index) {
          nestedBreak = true;
          break;
        }
      }

      if (nestedBreak) break;
      mainIndex++;
      totalIndex++;
    }

    result[0] = mainIndex;
    result[1] = secondIndex;

    return result;
  }

  String getFunctionType(int index) {
    String result = "";

    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      result = "Test";
    } else {
      result = "Step";
    }

    return result;
  }

  String getStepNumber(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      dynamic map = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1));

      int timeType = map.elementAt(3);

      return timeTypeDescription.elementAt(timeType).elementAt(0);
    } else {
      return (mapping.elementAt(0) + 1).toString();
    }
  }

  String getActionType(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      int testType = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1))
          .elementAt(0);
      return testName(testType);
    } else {
      return modeName(table.elementAt(mapping.elementAt(0)).elementAt(0));
    }
  }

  String getVoltageString(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      dynamic map = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1));

      int testType = map.elementAt(0);

      if (testType >= 0 && testType <= 1) {
        double voltage = map.elementAt(2);
        return voltage.toString() + "V";
      } else
        return "";
    } else {
      dynamic element = table.elementAt(mapping.elementAt(0)).elementAt(3);
      return element.toString() + "V";
    }
  }

  String getCurrentString(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      dynamic map = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1));

      int testType = map.elementAt(0);

      if (testType >= 2 && testType <= 3) {
        double voltage = map.elementAt(2);
        return voltage.toString() + "A";
      } else
        return "";
    } else {
      dynamic element = table.elementAt(mapping.elementAt(0)).elementAt(2);
      return element.toString() + "A";
    }
  }

  String getOtherString(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      dynamic map = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1));

      int testType = map.elementAt(0);
      if (testType > 3) {
        double value = map.elementAt(2);
        return value.toString();
      } else
        return "";
    } else {
      return "";
    }
  }

  String getTimeString(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      dynamic map = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1));
      int testType = map.elementAt(0);
      int value = map.elementAt(4);
      return value.toString() + "s";
    } else {
      dynamic element = table.elementAt(mapping.elementAt(0)).elementAt(1);
      return element.toString() + "s";
    }
  }

  String getTestString(int index) {
    List<int> mapping = getTableMapping(index);

    if (mapping.elementAt(1) >= 0) {
      dynamic map = table
          .elementAt(mapping.elementAt(0))
          .elementAt(4)
          .elementAt(mapping.elementAt(1));

      int value = map.elementAt(1);

      return testActionDescriptions.elementAt(value).elementAt(0);
    } else {
      return "";
    }
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
            'Action',
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
            'Other',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Time',
            style: TextStyle(color: Colors.white),
          ),
        ),
        DataColumn(
          label: Text(
            'Test',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      rows: List<DataRow>.generate(
        totalTableLength,
        (index) => DataRow(
          color: MaterialStateProperty.resolveWith<Color>((states) {
            if (index == dataTableSelectedIndex.value) return Colors.blue;
            if (index % 2 == 0) return Colors.grey.shade700;
            return Colors.grey.shade800;
          }),
          onSelectChanged: (value) {
            if (value == false) {
              dataTableSelectedIndex.value = -1;
            } else {
              dataTableSelectedIndex.value = index;
            }

            onIndexChanged(dataTableSelectedIndex.value);
          },
          selected: index == dataTableSelectedIndex.value,
          cells: <DataCell>[
            DataCell(
              Text(
                getFunctionType(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getStepNumber(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getActionType(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getVoltageString(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getCurrentString(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getOtherString(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getTimeString(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataCell(
              Text(
                getTestString(index),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
