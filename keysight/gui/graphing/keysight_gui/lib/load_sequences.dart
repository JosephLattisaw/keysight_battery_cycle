import 'package:flutter/material.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:provider/provider.dart';

class LoadSequences extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final savedSequences = context.select((KeysightCAPI k) => k.savedSequences);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        primary: false,
        child: DataTable(
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.blue.shade900),
          columns: [
            DataColumn(
              label: Text(
                'Sequence #',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Currently Loaded Profile',
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
                'In Use?',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Select Profile to Load',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Load',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          rows: List<DataRow>.generate(
            8,
            (index) => DataRow(
              color: MaterialStateProperty.resolveWith<Color>((states) {
                if (index % 2 == 0) return Colors.grey.shade700;
                return Colors.grey.shade800;
              }),
              cells: <DataCell>[
                DataCell(
                  Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    "",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    "Yes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    "No",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                DataCell(IntrinsicWidth(
                  child: DropdownButtonFormField(
                    value: 0,
                    items: List.generate(
                      savedSequences.length,
                      (index) => DropdownMenuItem(
                        child: Text(savedSequences.elementAt(index)),
                        value: index,
                      ),
                    ),
                    onChanged: (int? value) {},
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.blueAccent,
                    iconEnabledColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.4),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      fillColor: Colors.blueAccent,
                      isDense: true,
                      contentPadding: const EdgeInsets.all(8.0),
                    ),
                  ),
                )),
                DataCell(
                  ElevatedButton(
                    child: Text("Load Profile"),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
