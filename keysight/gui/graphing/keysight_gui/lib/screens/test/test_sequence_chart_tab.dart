import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TestSequenceChartTab extends StatelessWidget {
  const TestSequenceChartTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      backgroundColor: Colors.grey.shade900,
    );
  }
}
