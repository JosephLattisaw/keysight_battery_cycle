import 'package:flutter/material.dart';

class LoadSequences extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                    items: const [
                      DropdownMenuItem(child: Text("1 Second"), value: 0),
                      DropdownMenuItem(child: Text("10 Seconds"), value: 1),
                      DropdownMenuItem(child: Text("30 Seconds"), value: 2),
                      DropdownMenuItem(child: Text("60 seconds"), value: 3),
                      DropdownMenuItem(child: Text("5 minutes"), value: 4),
                      DropdownMenuItem(child: Text("10 minutes"), value: 5),
                    ],
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
