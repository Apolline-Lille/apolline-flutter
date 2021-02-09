import 'package:apollineflutter/models/sensormodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Quality extends StatelessWidget {
  final SensorModel lastReceivedData;

  Quality({Key key, this.lastReceivedData}) : super(key: key);

  SfRadialGauge _buildGauge(String title, String data, String unit, Color color,
      BoxDecoration boxDecoration) {
    return SfRadialGauge(title: GaugeTitle(text: title), axes: <RadialAxis>[
      RadialAxis(
          interval: 10,
          startAngle: 0,
          endAngle: 360,
          showTicks: false,
          showLabels: false,
          axisLineStyle: AxisLineStyle(thickness: 20),
          pointers: <GaugePointer>[
            RangePointer(
                value: double.parse(data),
                width: 20,
                color: color,
                enableAnimation: true,
                cornerStyle: CornerStyle.bothCurve)
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Column(
                  children: <Widget>[
                    Container(
                        width: 50.00, height: 50.00, decoration: boxDecoration),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        child: Text(data + unit,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25)),
                      ),
                    )
                  ],
                ),
                angle: 270,
                positionFactor: 0.9,
                verticalAlignment: GaugeAlignment.near)
          ])
    ]);
  }

  SfRadialGauge _buildGaugeBattery(String title, String data) {
    String level;
    double pointer;
    if (double.parse(data) > 3.97) {
      //80 100
      level = "100";
      pointer = 100;
    } else if (double.parse(data) >= 3.87) {
      //60 80
      level = "80";
      pointer = 80;
    } else if (double.parse(data) >= 3.79) {
      //60 80
      level = "60";
      pointer = 60;
    } else if (double.parse(data) >= 3.70) {
      //40 60
      level = "40";
      pointer = 40;
    } else {
      //0 20
      level = "20";
      pointer = 20;
    }
    return SfRadialGauge(title: GaugeTitle(text: title), axes: <RadialAxis>[
      RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
        GaugeRange(
            startValue: 0,
            endValue: 20,
            color: Colors.red,
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 20,
            endValue: 40,
            color: Colors.orange,
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 40,
            endValue: 60,
            color: Colors.green[200],
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 60,
            endValue: 80,
            color: Colors.green[300],
            startWidth: 10,
            endWidth: 10),
        GaugeRange(
            startValue: 80,
            endValue: 100,
            color: Colors.green,
            startWidth: 10,
            endWidth: 10)
      ], pointers: <GaugePointer>[
        NeedlePointer(value: pointer)
      ], annotations: <GaugeAnnotation>[
        GaugeAnnotation(
            widget: Container(
                child: Text(level,
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
            angle: 90,
            positionFactor: 0.5)
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (BuildContext builContext, Orientation orientation) {
          return Center(
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(0),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: orientation == Orientation.landscape ? 3 : 2,
              children: <Widget>[
                Container(
                  child: _buildGauge(
                      "PM1",
                      lastReceivedData.values[SensorModel.SENSOR_PM_1],
                      "µg/m3",
                      Colors.blueGrey,
                      new BoxDecoration()),
                ),
                Container(
                  child: _buildGauge(
                      "PM2.5",
                      lastReceivedData.values[SensorModel.SENSOR_PM_2_5],
                      "µg/m3",
                      Colors.blueGrey,
                      new BoxDecoration()),
                ),
                Container(
                  child: _buildGauge(
                      "PM10",
                      lastReceivedData.values[SensorModel.SENSOR_PM_10],
                      "µg/m3",
                      Colors.blueGrey,
                      new BoxDecoration()),
                ),
                Container(
                  child: _buildGauge(
                      "TEMPERATURE",
                      lastReceivedData.values[SensorModel.SENSOR_TEMP],
                      "°C",
                      Color(0xFFFFCD60),
                      new BoxDecoration(
                          image: new DecorationImage(
                              image: ExactAssetImage('assets/sun.png'),
                              fit: BoxFit.fitHeight))),
                ),
                Container(
                    child: _buildGaugeBattery("BAT",
                        lastReceivedData.values[SensorModel.SENSOR_VOLT]))
              ],
            ),
          );
        },
      ),
    );
  }
}
