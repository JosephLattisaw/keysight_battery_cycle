import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TestSequenceChartTab extends HookWidget {
  TestSequenceChartTab({Key? key}) : super(key: key);

  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  Widget build(BuildContext context) {
    _trackballBehavior = TrackballBehavior(
        enable: true,
        // Displays the trackball on single tap
        activationMode: ActivationMode.singleTap,
        lineColor: Colors.white);

    _zoomPanBehavior =
        ZoomPanBehavior(enableMouseWheelZooming: true, enablePanning: true);

    return SfCartesianChart(
      backgroundColor: Colors.grey.shade900,
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          position: LegendPosition.bottom),
      series: <LineSeries<_ChartData, int>>[
        LineSeries(
            dataSource: chartData,
            xValueMapper: (_ChartData sales, _) => sales.x,
            yValueMapper: (_ChartData sales, _) => sales.y,
            name: "Cell 0 Voltage"),
        LineSeries(
            dataSource: chartData2,
            xValueMapper: (_ChartData sales, _) => sales.x,
            yValueMapper: (_ChartData sales, _) => sales.y)
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final int? x;
  final double? y;
}

List<_ChartData> chartData = <_ChartData>[
  _ChartData(0, 42),
  _ChartData(1, 47),
  _ChartData(2, 33),
  _ChartData(3, 49),
  _ChartData(4, 54),
  _ChartData(5, 41),
  _ChartData(6, 58),
  _ChartData(7, 51),
  _ChartData(8, 98),
  _ChartData(9, 41),
  _ChartData(10, 53),
  _ChartData(11, 72),
  _ChartData(12, 86),
  _ChartData(13, 52),
  _ChartData(14, 94),
  _ChartData(15, 92),
  _ChartData(16, 86),
  _ChartData(17, 72),
  _ChartData(18, 94),
];

List<_ChartData> chartData2 = <_ChartData>[
  _ChartData(0, 10),
  _ChartData(1, 2),
  _ChartData(2, 12),
  _ChartData(3, 42),
  _ChartData(4, 342),
  _ChartData(5, 32),
  _ChartData(6, 32),
  _ChartData(7, 32),
  _ChartData(8, 45),
  _ChartData(9, 21),
  _ChartData(10, 67),
  _ChartData(11, 45),
  _ChartData(12, 7),
  _ChartData(13, 54),
  _ChartData(14, 77),
  _ChartData(15, 45),
  _ChartData(16, 54),
  _ChartData(17, 34),
  _ChartData(18, 34),
];
