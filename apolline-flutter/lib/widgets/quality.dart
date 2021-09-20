import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/widgets/charts/BatteryLevelIndicator.dart';
import 'package:apollineflutter/widgets/charts/RadialGauge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:easy_localization/easy_localization.dart';


class Quality extends StatelessWidget {
  final DataPointModel lastReceivedData;

  Quality({Key key, this.lastReceivedData}) : super(key: key);

  Widget _buildNewGauge(String title, double data, double minimumValue, double maximumValue) {
    return RadialGauge(
        indicatorTitle: title,
        minimumValue: minimumValue,
        maximumValue: maximumValue,
        currentValue: data
    );
  }

  //Commun method to create similar gauge (PM1, PM2.5 , PM10 and TEMPERATURE)
  Widget _buildGauge(String title, String data, String unit, Color color,
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

  //Build gauges
  @override
  Widget build(BuildContext context) {
    if (lastReceivedData == null)
      return Container();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: OrientationBuilder(
        builder: (BuildContext builContext, Orientation orientation) {
          return Center(
            child: Container (
              child: GridView.count(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                //displays 3 gauges when screen is horizontal and 2 when is vertical
                crossAxisCount: orientation == Orientation.landscape ? 3 : 2,
                children: <Widget>[
                  Container(
                    child: _buildNewGauge("PM1 (µg/m3)",
                        double.parse(lastReceivedData.values[DataPointModel.SENSOR_PM_1]),
                        0,
                        20) //box
                  ),
                  Container(
                    child: _buildNewGauge("PM2.5 (µg/m3)",
                        double.parse(lastReceivedData.values[DataPointModel.SENSOR_PM_2_5]),
                        0,
                        20),
                  ),
                  Container(
                    child: _buildNewGauge("PM10 (µg/m3)",
                        double.parse(lastReceivedData.values[DataPointModel.SENSOR_PM_10]),
                        0,
                        20),
                  ),
                  //creates TEMPERATURE gauge
                  Container(
                    child: _buildGauge(
                        "temperature".tr(),
                        lastReceivedData.values[DataPointModel.SENSOR_TEMP],
                        "°C",
                        Color(0xFFFFCD60),
                        new BoxDecoration(
                            image: new DecorationImage(
                                image: ExactAssetImage(
                                    'assets/sun.png'), //creates image for temperature gauge
                                fit: BoxFit.fitHeight))),
                  ),
                  //creates BATTERY gauge
                  Container(
                      child: BatteryLevelIndicator(
                          currentBatteryLevel: double.parse(lastReceivedData.values[DataPointModel.SENSOR_VOLT])
                      )
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
