import 'package:flutter/material.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';

const Color primaryColor = Color(0xFF1e2f36); //corner
const Color accentColor = Color(0xFF0d2026); //background
const TextStyle textStyle = TextStyle(color: Colors.white);
const TextStyle textStyleSubItems = TextStyle(color: Colors.grey);

class JoeHomePage extends StatefulWidget {
  const JoeHomePage({Key? key}) : super(key: key);

  _JoeHomePageState createState() => _JoeHomePageState();
}

class _JoeHomePageState extends State<JoeHomePage> {
  ExpandableTable _buildExpandableTable() {
    const int COLUMN_COUNT = 20;
    const int SUB_COLUMN_COUNT = 5;
    const int ROW_COUNT = 6;

    //Creation header
    ExpandableTableHeader subHeader = ExpandableTableHeader(
        firstCell: Container(
            color: primaryColor,
            margin: EdgeInsets.all(1),
            child: Center(
                child: Text(
              'Expandable Column',
              style: textStyleSubItems,
            ))),
        children: List.generate(
            SUB_COLUMN_COUNT,
            (index) => Container(
                color: primaryColor,
                margin: EdgeInsets.all(1),
                child: Center(
                    child: Text(
                  'Sub Column $index',
                  style: textStyleSubItems,
                )))));

    //Creation header
    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            color: primaryColor,
            margin: EdgeInsets.all(1),
            child: Center(
                child: Text(
              'Expandable\nTable',
              style: textStyle,
            ))),
        children: List.generate(
            COLUMN_COUNT - 1,
            (index) => index == 6
                ? subHeader
                : Container(
                    color: primaryColor,
                    margin: EdgeInsets.all(1),
                    child: Center(
                        child: Text(
                      'Column $index',
                      style: textStyle,
                    )))));

    //Creation sub rows
    List<ExpandableTableRow> subTows1 = List.generate(
        ROW_COUNT,
        (rowIndex) => ExpandableTableRow(
              height: 10,
              firstCell: Container(
                  color: primaryColor,
                  margin: EdgeInsets.all(1),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Sub Sub Row $rowIndex',
                      style: textStyleSubItems,
                    ),
                  )),
              children: List<Widget>.generate(
                  COLUMN_COUNT + SUB_COLUMN_COUNT - 1,
                  (columnIndex) => Container(
                      color: primaryColor,
                      margin: EdgeInsets.all(1),
                      child: Center(
                          child: Text(
                        'Cell $rowIndex:$columnIndex',
                        style: textStyleSubItems,
                      )))),
            ));
    List<ExpandableTableRow> subTows = List.generate(
        ROW_COUNT,
        (rowIndex) => ExpandableTableRow(
            height: 50,
            firstCell: Container(
                color: primaryColor,
                margin: EdgeInsets.all(1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Sub Row $rowIndex',
                      style: textStyleSubItems,
                    ),
                  ),
                )),
            children: subTows1,
            legend: Container(
              color: primaryColor,
              margin: EdgeInsets.all(1),
              child: Center(
                child: Text(
                  'Expandible sub Row...',
                  style: textStyle,
                ),
              ),
            )));
    //Creation rows
    List<ExpandableTableRow> rows = List.generate(
        ROW_COUNT,
        (rowIndex) => ExpandableTableRow(
              height: 50,
              firstCell: Container(
                  color: primaryColor,
                  margin: EdgeInsets.all(1),
                  child: Center(
                      child: Text(
                    'Row $rowIndex',
                    style: textStyle,
                  ))),
              legend: rowIndex == 0
                  ? Container(
                      color: primaryColor,
                      margin: EdgeInsets.all(1),
                      child: Center(
                        child: Text(
                          'Expandible Row...',
                          style: textStyle,
                        ),
                      ),
                    )
                  : null,
              children: rowIndex == 0
                  ? subTows
                  : List<Widget>.generate(
                      COLUMN_COUNT + SUB_COLUMN_COUNT - 1,
                      (columnIndex) => Container(
                          color: primaryColor,
                          margin: EdgeInsets.all(1),
                          child: Center(
                              child: Text(
                            'Cell $rowIndex:$columnIndex',
                            style: textStyle,
                          )))),
            ));

    return ExpandableTable(
      rows: rows,
      header: header,
      scrollShadowColor: accentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accentColor,
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildExpandableTable(),
          )),
        ],
      ),
    );
  }
}
