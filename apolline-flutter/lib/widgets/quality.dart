import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/widgets/charts/BatteryLevelIndicator.dart';
import 'package:apollineflutter/widgets/charts/RadialGauge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  Widget _getPM1Gauge () {
    return Container(
        child: _buildNewGauge("PM1 (µg/m3)",
            double.parse(lastReceivedData.values[DataPointModel.SENSOR_PM_1]),
            0,
            20) //box
    );
  }

  Widget _getPM25Gauge () {
    return Container(
      child: _buildNewGauge("PM2.5 (µg/m3)",
          double.parse(lastReceivedData.values[DataPointModel.SENSOR_PM_2_5]),
          0,
          20),
    );
  }

  Widget _getPM10Gauge () {
    return Container(
      child: _buildNewGauge("PM10 (µg/m3)",
          double.parse(lastReceivedData.values[DataPointModel.SENSOR_PM_10]),
          0,
          20),
    );
  }

  Widget _getTemperatureInfo () {
    return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(double.parse(lastReceivedData.values[DataPointModel.SENSOR_TEMP]).toStringAsFixed(2) + '°C',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 30)),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
              child: Text(
                "temperature".tr(),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 14),
              ),
            )
          ],
        )
    );
  }

  Widget _getBatteryInfo () {
    return Container(
        child: BatteryLevelIndicator(
            currentBatteryLevel: double.parse(lastReceivedData.values[DataPointModel.SENSOR_VOLT])
        )
    );
  }


  //Build gauges
  @override
  Widget build(BuildContext context) {
    if (lastReceivedData == null)
      return Container();
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        bool isLandscape = orientation == Orientation.landscape;

        if (isLandscape) {
          return Center(
            child: Container (
              child: GridView.count(
                primary: false,
                shrinkWrap: true,
                padding: const EdgeInsets.all(0),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                children: <Widget>[
                  this._getPM1Gauge(),
                  this._getPM25Gauge(),
                  this._getPM10Gauge(),
                  this._getTemperatureInfo(),
                  this._getBatteryInfo()
                ],
              ),
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: this._getPM1Gauge()),
                      Expanded(child: this._getPM25Gauge()),
                    ],
                  ),
                ),
                Expanded(
                  child: this._getPM10Gauge(),
                ),
                Expanded(
                    child: Row(
                      children: [
                        Expanded(child: this._getTemperatureInfo()),
                        Expanded(child: this._getBatteryInfo())
                      ],
                    )
                )
              ],
            )
          );
        }
      },
    );
  }
}
