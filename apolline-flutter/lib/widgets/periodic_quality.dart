import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/models/user_configuration.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
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

  Widget _getPMValues() {
    Color pm1TextColor = widget.data.pm10value > widget.userConfiguration.getThresholds(PMFilter.PM_1)[0] ? Colors.orange : Colors.black;
    pm1TextColor =  widget.data.pm10value > widget.userConfiguration.getThresholds(PMFilter.PM_1)[1] ? Colors.red : pm1TextColor;

    Color pm25TextColor = widget.data.pm10value > widget.userConfiguration.getThresholds(PMFilter.PM_2_5)[0] ? Colors.orange : Colors.black;
    pm25TextColor =  widget.data.pm10value > widget.userConfiguration.getThresholds(PMFilter.PM_2_5)[1] ? Colors.red : pm25TextColor;

    Color pm10TextColor = widget.data.pm10value > widget.userConfiguration.getThresholds(PMFilter.PM_10)[0] ? Colors.orange : Colors.black;
    pm10TextColor =  widget.data.pm10value > widget.userConfiguration.getThresholds(PMFilter.PM_10)[1] ? Colors.red : pm10TextColor;

    return Padding(
        padding: EdgeInsets.only(top: 100, bottom: 100),
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
                              textAlign: TextAlign.center,
                              style: TextStyle(color: pm1TextColor)
                          ),
                          Text("${widget.data.pm25value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: pm25TextColor),
                          ),
                          Text("${widget.data.pm10value.toStringAsFixed(2)} ${Units.CONCENTRATION_UG_M3}",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: pm10TextColor)
                          )
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
        _getTimer(),
        _getPMValues(),
      ],
    );
  }

}