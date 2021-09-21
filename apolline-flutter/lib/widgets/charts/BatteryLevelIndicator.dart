import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BatteryLevelIndicator extends StatefulWidget {
  final double currentBatteryLevel;
  final double minimumLevel = 0;
  final double maximumLevel = 100;
  final double maximumSensorBatteryLevel = 4.20;

  const BatteryLevelIndicator({Key key, @required this.currentBatteryLevel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BatteryLevelIndicatorState();
}

class _BatteryLevelIndicatorState extends State<BatteryLevelIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(child: _buildBatteryIndicator(context));
  }

  /// https://github.com/syncfusion/flutter-examples/blob/master/lib/samples/linear_gauge/showcase/battery_indicator.dart
  Widget _buildBatteryIndicator(BuildContext context) {
    final Brightness _brightness = Theme.of(context).brightness;
    final double batteryLevelPercentage = (widget.currentBatteryLevel * 100) / widget.maximumSensorBatteryLevel;

    final Color _fillColor = batteryLevelPercentage <= 25
        ? const Color(0xffF45656)
        : batteryLevelPercentage <= 50
        ? const Color(0xffFFC93E)
        : Colors.green[400];
    return Container(
        width: 145,
        child: SfLinearGauge(
          minimum: widget.minimumLevel,
          maximum: widget.maximumLevel,
          showLabels: false,
          showTicks: false,
          tickPosition: LinearElementPosition.cross,
          majorTickStyle:
          const LinearTickStyle(color: Colors.green, length: 20),
          minorTickStyle: const LinearTickStyle(color: Colors.red, length: 10),
          axisTrackStyle: const LinearAxisTrackStyle(
              thickness: 1, color: Colors.transparent),
          ranges: <LinearGaugeRange>[
            LinearGaugeRange(
                startValue: widget.minimumLevel,
                startWidth: 70,
                endWidth: 70,
                color: Colors.transparent,
                endValue: widget.maximumLevel - 2,
                position: LinearElementPosition.cross,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                        border: Border.all(
                            color: _brightness == Brightness.light
                                ? const Color(0xffAAAAAA)
                                : const Color(0xff4D4D4D),
                            width: 4),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(12))))),
            LinearGaugeRange(
                startValue: widget.minimumLevel + 5,
                startWidth: 55,
                endWidth: 55,
                endValue: batteryLevelPercentage < widget.maximumLevel / 4
                    ? batteryLevelPercentage
                    : widget.maximumLevel / 4,
                position: LinearElementPosition.cross,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _fillColor,
                        borderRadius: BorderRadius.circular(4)))),
            LinearGaugeRange(
                startValue: batteryLevelPercentage >= (widget.maximumLevel / 4 + 2)
                    ? (widget.maximumLevel / 4 + 2)
                    : widget.minimumLevel + 5,
                endValue: batteryLevelPercentage < (widget.maximumLevel / 4 + 2)
                    ? widget.minimumLevel + 5
                    : batteryLevelPercentage <= widget.maximumLevel / 2
                    ? batteryLevelPercentage
                    : widget.maximumLevel / 2,
                startWidth: 55,
                endWidth: 55,
                position: LinearElementPosition.cross,
                edgeStyle: LinearEdgeStyle.bothFlat,
                rangeShapeType: LinearRangeShapeType.flat,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _fillColor,
                        borderRadius: BorderRadius.circular(4)))),
            LinearGaugeRange(
                startValue: batteryLevelPercentage >= (widget.maximumLevel / 2 + 2)
                    ? (widget.maximumLevel / 2 + 2)
                    : widget.minimumLevel + 5,
                endValue: batteryLevelPercentage < (widget.maximumLevel / 2 + 2)
                    ? widget.minimumLevel + 5
                    : batteryLevelPercentage <= (widget.maximumLevel * 3 / 4)
                    ? batteryLevelPercentage
                    : (widget.maximumLevel * 3 / 4),
                startWidth: 55,
                endWidth: 55,
                position: LinearElementPosition.cross,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _fillColor,
                        borderRadius: BorderRadius.circular(4)))),
            LinearGaugeRange(
                startValue: batteryLevelPercentage >= (widget.maximumLevel * 3 / 4 + 2)
                    ? (widget.maximumLevel * 3 / 4 + 2)
                    : widget.minimumLevel + 5,
                endValue: batteryLevelPercentage < (widget.maximumLevel * 3 / 4 + 2)
                    ? widget.minimumLevel + 5
                    : batteryLevelPercentage < widget.maximumLevel
                    ? batteryLevelPercentage
                    : widget.maximumLevel - 7,
                startWidth: 55,
                endWidth: 55,
                position: LinearElementPosition.cross,
                color: Colors.transparent,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _fillColor,
                        borderRadius: BorderRadius.circular(4)))),
          ],
          markerPointers: <LinearMarkerPointer>[
            LinearWidgetPointer(
                value: widget.maximumLevel,
                enableAnimation: false,
                markerAlignment: LinearMarkerAlignment.start,
                child: Container(
                    height: 38,
                    width: 16,
                    decoration: BoxDecoration(
                        color: _brightness == Brightness.light
                            ? Colors.transparent
                            : const Color(0xff232323),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                            color: _brightness == Brightness.light
                                ? const Color(0xffAAAAAA)
                                : const Color(0xff4D4D4D),
                            width: 4),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6)))))
          ],
          barPointers: <LinearBarPointer>[
            LinearBarPointer(
              value: 100,
              thickness: 30,
              position: LinearElementPosition.outside,
              offset: 50,
              enableAnimation: false,
              color: Colors.transparent,
              child: Center(
                child: Text(
                    batteryLevelPercentage.toStringAsFixed(0) + '%',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25)
                ),
              ),
            ),
          ],
        ));
  }
}