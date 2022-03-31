import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: SfCartesianChart(
        backgroundColor: Colors.grey.shade900,
      ),
    );
  }
}
