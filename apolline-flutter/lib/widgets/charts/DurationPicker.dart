import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DurationPicker extends StatefulWidget {
  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  double _borderWidth = 5;
  double _firstMarkerValue = 2;
  double _secondMarkerValue = 8;
  double _markerSize = 25;
  double _annotationFontSize = 25;
  double _thickness = 0.06;
  String _annotationValue = '06';
  String _minutesValue = '40';
  double _overlayRadius = 30;
  bool _enableDragging = true;

  /// Dragged pointer new value is updated to range.
  void _handleFirstPointerValueChanged(double value) {
    setState(() {
      _firstMarkerValue = value;
      final int _value = (_firstMarkerValue - _secondMarkerValue).abs().toInt();
      final String _hourValue = '$_value';
      _annotationValue = _hourValue.length == 1 ? '0' + _hourValue : _hourValue;
      _calculateMinutes(_value);
    });
  }

  /// Cancelled the dragging when pointer value reaching the axis end/start value, greater/less than another
  /// pointer value
  void _handleFirstPointerValueChanging(ValueChangingArgs args) {
    if (args.value >= _secondMarkerValue ||
        (args.value - _firstMarkerValue).abs() > 1) {
      args.cancel = true;
    }
  }

  /// Cancelled the dragging when pointer value reaching the axis end/start value, greater/less than another
  /// pointer value
  void _handleSecondPointerValueChanging(ValueChangingArgs args) {
    if (args.value <= _firstMarkerValue ||
        (args.value - _secondMarkerValue).abs() > 1) {
      args.cancel = true;
    }
  }

  /// Dragged pointer new value is updated to range.
  void _handleSecondPointerValueChanged(double value) {
    setState(() {
      _secondMarkerValue = value;
      final int _value = (_firstMarkerValue - _secondMarkerValue).abs().toInt();
      final String _hourValue = '$_value';
      _annotationValue = _hourValue.length == 1 ? '0' + _hourValue : _hourValue;
      _calculateMinutes(_value);
    });
  }

  /// Calculate the minutes value from pointer value to update in annotation.
  void _calculateMinutes(int _value) {
    final double _minutes =
        (_firstMarkerValue - _secondMarkerValue).abs() - _value;
    final List<String> _minList = _minutes.toStringAsFixed(2).split('.');
    double _currentMinutes = double.parse(_minList[1]);
    _currentMinutes =
    _currentMinutes > 60 ? _currentMinutes - 60 : _currentMinutes;
    final String _actualValue = _currentMinutes.toInt().toString();
    _minutesValue =
    _actualValue.length == 1 ? '0' + _actualValue : _actualValue;
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
                value: _firstMarkerValue,
                onValueChanged: _handleFirstPointerValueChanged,
                onValueChanging: _handleFirstPointerValueChanging,
                enableDragging: _enableDragging,
                borderColor: const Color(0xFFFFCD60),
                borderWidth: _borderWidth,
                color: Colors.black.withOpacity(0.8),
                markerHeight: _markerSize,
                markerWidth: _markerSize,
                markerType: MarkerType.circle,
                overlayColor: const Color.fromRGBO(255, 205, 96, 0.3),
                overlayRadius: _overlayRadius),
            MarkerPointer(
                value: _secondMarkerValue,
                onValueChanged: _handleSecondPointerValueChanged,
                onValueChanging: _handleSecondPointerValueChanging,
                color: Colors.black.withOpacity(0.8),
                enableDragging: _enableDragging,
                borderColor: const Color(0xFFFFCD60),
                markerHeight: _markerSize,
                borderWidth: _borderWidth,
                markerWidth: _markerSize,
                markerType: MarkerType.circle,
                overlayColor: const Color.fromRGBO(255, 205, 96, 0.3),
                overlayRadius: _overlayRadius),
          ],
          ranges: <GaugeRange>[
            GaugeRange(
                endValue: _secondMarkerValue,
                sizeUnit: GaugeSizeUnit.factor,
                startValue: _firstMarkerValue,
                startWidth: _thickness,
                endWidth: _thickness)
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                    child: Center(
                        child: Text(
                          '${_annotationValue}hr ${_minutesValue}m',
                          style: TextStyle(
                              fontSize: _annotationFontSize,
                              fontFamily: 'Times',
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00A8B5)),
                        ))),
                positionFactor: 0.05,
                angle: 0)
          ])
    ]);
  }
}