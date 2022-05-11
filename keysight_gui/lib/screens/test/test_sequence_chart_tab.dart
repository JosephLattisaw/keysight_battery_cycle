import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math';

class TestSequenceChartTab extends HookWidget {
  TestSequenceChartTab({Key? key}) : super(key: key);

  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  ChartSeriesController? _chartSeriesController;

  late ValueNotifier<int> ctr;

  void _updateDataSource() {
    if (chartData.length == 3600) {
      chartData.removeAt(0);
      for (int i = 0; i < csc.length; i++) {
        csc.elementAt(i)?.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
          removedDataIndexes: <int>[0],
        );
      }
    } else {
      for (int i = 0; i < csc.length; i++) {
        csc.elementAt(i)?.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
        );
      }
    }
    count += 1;
  }

  void _updateData() {
    var random = Random();
    chartData.add(_ChartData(count, 10 + random.nextInt(100 - 10).toDouble()));
    count += 1;
  }

  Future<void> _updateDataSourceAsync() async {
    await Future.delayed(Duration(seconds: 60));
    print("future was called");
    _updateDataSource();
    _updateDataSourceAsync();
    return;
  }

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(_updateDataSourceAsync);
    final snapshot = useFuture(future);

    _trackballBehavior = TrackballBehavior(
      enable: true,
      // Displays the trackball on single tap
      activationMode: ActivationMode.singleTap,
      lineColor: Colors.white,
    );

    _zoomPanBehavior =
        ZoomPanBehavior(enableMouseWheelZooming: true, enablePanning: true);

    ctr = useState(0);

    return SfCartesianChart(
      backgroundColor: Colors.grey.shade900,
      //trackballBehavior: _trackballBehavior,
      //zoomPanBehavior: _zoomPanBehavior,
      legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
      series: List<FastLineSeries<_ChartData, int>>.generate(
        256,
        (index) => FastLineSeries(
          onRendererCreated: (controller) => csc[index] = controller,
          dataSource: chartData,
          xValueMapper: (_ChartData sales, _) => sales.x,
          yValueMapper: (_ChartData sales, _) => sales.y,
          name: "Cell $index Voltage",
          xAxisName: "Time",
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final int? x;
  final double? y;
}

int count = 3580;

List<ChartSeriesController?> csc = List.generate(256, (index) => null);

List<_ChartData> chartData =
    List<_ChartData>.generate(3580, (index) => _ChartData(index, 42));

/*
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
*/
