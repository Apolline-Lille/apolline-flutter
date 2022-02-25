import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/models/user_configuration.dart';
import 'package:apollineflutter/widgets/charts/BatteryLevelIndicator.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PeriodicQuality extends StatelessWidget {
  final DataPointModel data;
  final UserConfiguration userConfiguration;

  PeriodicQuality({Key key, this.data, this.userConfiguration}) : super(key: key);

  Widget _getTemperatureInfo () {
    return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(data.temperature.toStringAsFixed(2) + '°C',
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

  Widget _getBatteryInfo() {
    return Container(
      child: BatteryLevelIndicator(
        currentBatteryLevel: double.parse(data.values[DataPointModel.SENSOR_VOLT]),
      ),
    );
  }

  Widget _getTempAndBatteryInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _getTemperatureInfo(),
        _getBatteryInfo()
      ],
    );
  }

  Widget _getPMValues() {
    return Padding(
        padding: EdgeInsets.only(top: 75, bottom: 75),
        child: Table(
            children: [
              TableRow(
                  children: [
                    Text("PM 1",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text("PM 2.5",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    Text("PM 10",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold)
                    )
                  ]
              ),
              TableRow(
                  children: [
                    Text("${data.pm1value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                        textAlign: TextAlign.center),
                    Text("${data.pm25value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                        textAlign: TextAlign.center),
                    Text("${data.pm10value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                        textAlign: TextAlign.center)
                  ]
              ),

            ])
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text("periodicView.description".tr(args: ["5"]),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)
            )
        ),
        _getPMValues(),
        _getTempAndBatteryInfo()
      ],
    );
  }

}