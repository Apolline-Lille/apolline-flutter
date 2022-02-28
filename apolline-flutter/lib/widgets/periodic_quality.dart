import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/models/user_configuration.dart';
import 'package:apollineflutter/widgets/charts/BatteryLevelIndicator.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PeriodicQuality extends StatefulWidget {
  final DataPointModel data;
  final UserConfiguration userConfiguration;

  PeriodicQuality({Key key, this.data, this.userConfiguration}) : super(key: key);

  @override
  PeriodicQualityState createState() {
    return PeriodicQualityState();
  }
}

class PeriodicQualityState extends State<PeriodicQuality> {
  CountDownController _countDownController = CountDownController();
  int _timerDuration = 300;
  DateTime _lastSyncDate = DateTime.now();

  Widget _getTimer() {
    return Column(
        children: [
          Text("periodicView.nextSync".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Padding(padding: EdgeInsets.only(bottom: 20, top: 20),
              child: CircularCountDownTimer(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 4,
                ringColor: Theme.of(context).primaryColor,
                fillColor: Colors.blue,
                duration: _timerDuration,
                controller: _countDownController,
                isReverseAnimation: false,
                isReverse: true,
                isTimerTextShown: true,
                strokeCap: StrokeCap.round,
                strokeWidth: 20,
                onStart: () {
                  _lastSyncDate = DateTime.now();
                },
                onComplete: () {
                  _countDownController.restart();
                  setState(() {});
                },
              )
          ),
          Text("periodicView.previousSync".tr(args: [_getLastSync()]),
              style: TextStyle(fontStyle: FontStyle.italic)
          ),
        ]
    );
  }

  String _getLastSync() {
    return "${_lastSyncDate.hour}:${_lastSyncDate.minute}";
  }

  Widget _getTemperatureInfo () {
    return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.data.temperature.toStringAsFixed(2) + '°C',
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
        currentBatteryLevel: double.parse(widget.data.values[DataPointModel.SENSOR_VOLT]),
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
        child: Column(
            children: [
              Text("periodicView.tableAverageTitle".tr(),
                  style: TextStyle(fontStyle: FontStyle.italic)
              ),
              Table(
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
                          Text("${widget.data.pm1value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                              textAlign: TextAlign.center),
                          Text("${widget.data.pm25value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                              textAlign: TextAlign.center),
                          Text("${widget.data.pm10value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                              textAlign: TextAlign.center)
                        ]
                    ),
                  ]
              )
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Padding(
        //     padding: EdgeInsets.only(top: 20),
        //     child: Text("periodicView.description".tr(args: ["5"]),
        //         textAlign: TextAlign.center,
        //         style: TextStyle(fontWeight: FontWeight.bold)
        //     )
        // ),
        _getTimer(),
        _getPMValues(),
        _getTempAndBatteryInfo()
      ],
    );
  }

}