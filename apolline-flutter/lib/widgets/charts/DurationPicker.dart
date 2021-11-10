import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DurationPicker extends StatefulWidget {
  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  double _borderWidth = 5;
  double _secondMarkerValue = 8;
  double _markerSize = 25;
  double _annotationFontSize = 25;
  double _thickness = 0.06;
  double _overlayRadius = 30;
  bool _enableDragging = true;
  int _minutesCount = 15;

  /// Cancelled the dragging when pointer value reaching the axis end/start value, greater/less than another
  /// pointer value
  void _handleSecondPointerValueChanging(ValueChangingArgs args) {
    if (args.value <= 0 ||
        (args.value - _secondMarkerValue).abs() > 1) {
      args.cancel = true;
    }
  }

  /// Dragged pointer new value is updated to range.
  void _handleSecondPointerValueChanged(double value) {
    setState(() {
      _minutesCount = (5*value).round();
      _secondMarkerValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      _markerSize = 25;
      _annotationFontSize = 25;
      _thickness = 0.06;
      _borderWidth = 5;
    } else {
      _markerSize = 23;
      _annotationFontSize = 15;
      _thickness = 0.1;
      _borderWidth = 4;
    }

    return SfRadialGauge(axes: <RadialAxis>[
      RadialAxis(
          axisLineStyle: AxisLineStyle(
              thickness: _thickness,
              thicknessUnit: GaugeSizeUnit.factor),
          radiusFactor: 0.8,
          minorTicksPerInterval: 4,
          showFirstLabel: false,
          minimum: 0,
          maximum: 12,
          interval: 1,
          startAngle: 270,
          endAngle: 270,
          pointers: <GaugePointer>[
            MarkerPointer(
                value: 0,
                enableDragging: false,
                color: Colors.transparent),
            MarkerPointer(
                value: _secondMarkerValue,
                onValueChanged: _handleSecondPointerValueChanged,
                onValueChanging: _handleSecondPointerValueChanging,
                color: Color(0xff42a5f5),
                enableDragging: _enableDragging,
                borderColor: const Color(0xff42a5f5),
                markerHeight: _markerSize,
                borderWidth: _borderWidth,
                markerWidth: _markerSize,
                markerType: MarkerType.circle,
                overlayColor: const Color(0x8880d6ff),
                overlayRadius: _overlayRadius),
          ],
          ranges: <GaugeRange>[
            GaugeRange(
                endValue: _secondMarkerValue,
                color: Color(0xff80d6ff),
                sizeUnit: GaugeSizeUnit.factor,
                startValue: 0,
                startWidth: _thickness,
                endWidth: _thickness)
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                    child: Center(
                        child: Text(
                          '$_minutesCount mins',
                          style: TextStyle(
                              fontSize: _annotationFontSize,)
                              // fontFamily: 'Times',
                              //fontWeight: FontWeight.bold),
                        ))),
                positionFactor: 0.05,
                angle: 0)
          ])
    ]);
  }
}