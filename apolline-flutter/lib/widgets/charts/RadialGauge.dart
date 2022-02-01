import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialGauge extends StatefulWidget {
  final String indicatorTitle;

  final double minimumValue;
  final double maximumValue;
  final double currentValue;

  const RadialGauge({Key key,
    @required this.indicatorTitle,
    @required this.minimumValue,
    @required this.maximumValue,
    @required this.currentValue
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RadialGaugeState();
}

class _RadialGaugeState extends State<RadialGauge> {
  @override
  Widget build(BuildContext context) {
    return Center(child: _buildGauge(context));
  }

  Widget _buildGauge(BuildContext context) {
    final double localCurrentValue = widget.currentValue > widget.maximumValue
        ? widget.maximumValue
        : widget.currentValue < widget.minimumValue
            ? widget.minimumValue
            : widget.currentValue;

    return SfRadialGauge(
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
            showLabels: false,
            showTicks: false,
            radiusFactor: 0.8,
            minimum: widget.minimumValue,
            maximum: widget.maximumValue,
            axisLineStyle: const AxisLineStyle(
                cornerStyle: CornerStyle.startCurve, thickness: 5),
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0,
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(widget.currentValue.toStringAsFixed(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 30)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                        child: Text(
                          widget.indicatorTitle,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 14),
                        ),
                      )
                    ],
                  )),
              GaugeAnnotation(
                  angle: 124,
                  positionFactor: 1.1,
                  widget: Container(
                    child: Text(widget.minimumValue.toStringAsFixed(0),
                        style: TextStyle(fontSize: 14)),
                  )),
              GaugeAnnotation(
                  angle: 54,
                  positionFactor: 1.1,
                  widget: Container(
                    child: Text(widget.maximumValue.toStringAsFixed(0),
                        style: TextStyle(fontSize: 14)),
                  )),
            ],
            pointers: <GaugePointer>[
              RangePointer(
                value: localCurrentValue,
                width: 18,
                pointerOffset: -6,
                cornerStyle: CornerStyle.bothCurve,
                color: Theme.of(context).primaryColor,
                gradient: SweepGradient(
                    colors: <Color>[Color.fromRGBO(181, 187, 217, 1), Color.fromRGBO(123, 137, 191, 1)],
                    stops: <double>[0.25, 0.75]),
              ),
              MarkerPointer(
                value: localCurrentValue,
                color: Colors.white,
                markerType: MarkerType.circle,
              ),
            ]),
      ],
    );
  }
}