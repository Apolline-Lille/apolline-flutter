import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DurationPicker extends StatefulWidget {
  final Duration duration;
  final Function(Duration) onChange;
  const DurationPicker({
    Key key,
    @required this.duration,
    @required this.onChange}) : super(key: key);

  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  double _borderWidth = 5;
  double _markerValue = 0;
  double _markerSize = 25;
  double _annotationFontSize = 40;
  double _thickness = 0.06;
  int _minutesCount = 0;

  @override
  void initState() {
    super.initState();
    this._minutesCount = widget.duration.inMinutes;
    this._markerValue = widget.duration.inMinutes / 5;
  }

  /// Cancelled the dragging when pointer value reaching the axis end/start value, greater/less than another
  /// pointer value
  void _handleSecondPointerValueChanging(ValueChangingArgs args) {
    if (args.value <= 0 ||
        (args.value - _markerValue).abs() > 1) {
      args.cancel = true;
    }
  }

  /// Dragged pointer new value is updated to range.
  void _handleSecondPointerValueChanged(double value) {
    setState(() {
      _minutesCount = (5*value).round();
      _markerValue = value;
    });
  }

  // Dragged pointer dragging finished.
  void _handlePointerNewValue(double range) {
    widget.onChange(Duration(minutes: _minutesCount));
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      _markerSize = 25;
      _thickness = 0.06;
      _borderWidth = 5;
    } else {
      _markerSize = 23;
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
                value: _markerValue,
                onValueChanged: _handleSecondPointerValueChanged,
                onValueChanging: _handleSecondPointerValueChanging,
                onValueChangeEnd: _handlePointerNewValue,
                color: Color(0xff42a5f5),
                enableDragging: true,
                borderColor: const Color(0xff42a5f5),
                markerHeight: _markerSize,
                borderWidth: _borderWidth,
                markerWidth: _markerSize,
                markerType: MarkerType.circle,
                overlayColor: const Color(0x8880d6ff),
                overlayRadius: 30),
          ],
          ranges: <GaugeRange>[
            GaugeRange(
                endValue: _markerValue,
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
                        child: Column(
                            children: [
                              Text(
                                  _minutesCount.toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: _annotationFontSize,)
                              ),
                              Text(
                                  'min.',
                                  style: TextStyle(
                                    fontSize: _annotationFontSize-25,)
                              )
                            ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ))),
                positionFactor: 0.05,
                angle: 0)
          ])
    ]);
  }
}