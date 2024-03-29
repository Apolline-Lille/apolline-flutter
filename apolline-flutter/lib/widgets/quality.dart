import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/widgets/charts/BatteryLevelIndicator.dart';
import 'package:apollineflutter/widgets/charts/RadialGauge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


class Quality extends StatelessWidget {
  final DataPointModel? lastReceivedData;

  Quality({required Key key, required this.lastReceivedData}) : super(key: key);

  Widget _buildNewGauge(String title, double data, double minimumValue, double maximumValue) {
    return RadialGauge(
        indicatorTitle: title,
        minimumValue: minimumValue,
        maximumValue: maximumValue,
        currentValue: data,
      key: this.key!,
    );
  }

  Widget _getPM1Gauge () {
    return Container(
        child: _buildNewGauge("PM1 (µg/m3)",
            double.parse(lastReceivedData!.values[DataPointModel.SENSOR_PM_1]),
            0,
            20) //box
    );
  }

  Widget _getPM25Gauge () {
    return Container(
      child: _buildNewGauge("PM2.5 (µg/m3)",
          double.parse(lastReceivedData!.values[DataPointModel.SENSOR_PM_2_5]),
          0,
          20),
    );
  }

  Widget _getPM10Gauge () {
    return Container(
      child: _buildNewGauge("PM10 (µg/m3)",
          double.parse(lastReceivedData!.values[DataPointModel.SENSOR_PM_10]),
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
            // Lower displayed temperature by 2 degrees, as Jerome told sensor is still influenced by internal battery warmth
            Text((double.parse(lastReceivedData!.values[DataPointModel.SENSOR_TEMP_AM2320]) - 2).toStringAsFixed(2) + '°C',
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
            currentBatteryLevel: double.parse(lastReceivedData!.values[DataPointModel.SENSOR_VOLT]),
            key: this.key!,
        )
    );
  }

  Widget _getHumidityInfo () {
    return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(double.parse(lastReceivedData!.values[DataPointModel.SENSOR_HUMI_AM2320]).toStringAsFixed(2) + '%',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 30)),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
              child: Text(
                "humidity".tr(),
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
                  this._getHumidityInfo(),
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
                        Expanded(child: Transform.translate(child: this._getTemperatureInfo(), offset: Offset(10, 0),)),
                        Expanded(child: Transform.translate(offset: Offset(10, 0), child: Transform.scale(child: this._getBatteryInfo(), scale: 0.7,))),
                        Expanded(child: Transform.translate(child: this._getHumidityInfo(), offset: Offset(-5, 0),))
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
