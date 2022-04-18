import 'package:flutter/material.dart';

class MeasurementTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: DataTable(
        headingRowColor:
            MaterialStateColor.resolveWith((states) => Colors.blue.shade900),
        columns: [
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
              'Status',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        rows: List<DataRow>.generate(
          32,
          (index) => DataRow(
            color: MaterialStateProperty.resolveWith<Color>((states) {
              if (index % 2 == 0) return Colors.grey.shade700;
              return Colors.grey.shade800;
            }),
            cells: <DataCell>[
              DataCell(
                Text(
                  'Data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  'Data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  'Data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  'Data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  'Data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
