import 'dart:async';
import 'dart:core';

import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/services/realtime_data_service.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/time_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class Stats extends StatefulWidget {
  Stats({required Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return StatsState(key: key!);
  }
}

class StatsState extends State<Stats> {
  StatsState({required Key key});
  RealtimeDataService _dataService = locator<RealtimeDataService>();
  Stream<DataPointModel> _dataStream = locator<RealtimeDataService>().dataStream;
  StreamSubscription<DataPointModel>? _streamSubscription;
  late List<DataPointModel> _data;
  late TimeFilter _dataDurationFilter;
  late SqfLiteService _sqfLiteService;
  late ValueNotifier<bool> _isDialOpen;

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    this._data = [];
    this._dataDurationFilter = TimeFilter.LAST_5_MIN;
    this._sqfLiteService = SqfLiteService();
    this._isDialOpen = ValueNotifier(false);

    this._updateDataFrom(this._dataDurationFilter).then((value) {
      _streamSubscription = _dataStream.listen((newData) {
        int timeDelta = DateTime.now().millisecondsSinceEpoch - 60000*this._dataDurationFilter.toMinutes();
        setState(() {
          _data.add(newData);
          _data = _data.where((element) => element.date > timeDelta).toList();
        });
      });
    });
    super.initState();
  }

  Future<void> _updateDataFrom(TimeFilter filter) async {
    List<DataPointModel> points = await this._sqfLiteService.getAllDataPointsAfterDate(filter);
    setState(() {
      this._data = points;
    });
  }

  List<SpeedDialChild> _getSpeedDialButtons () {
    List<SpeedDialChild> buttons = [
      SpeedDialChild(
          label: _dataService.isRunning
              ? "statsView.pauseGathering".tr()
              : "statsView.resumeGathering".tr(),
          child: FloatingActionButton(
            onPressed: () {
              _isDialOpen.value = false;
              _dataService.isRunning ? _dataService.stop() : _dataService.start();
            },
            child: Icon(_dataService.isRunning ? Icons.pause : Icons.play_arrow),
          )
      )
    ];

    final ThemeData theme = Theme.of(context);

    [
      TimeFilter.LAST_MIN,
      TimeFilter.LAST_5_MIN,
      TimeFilter.LAST_15_MIN
    ]
    .forEach((element) {
      buttons.add(SpeedDialChild(
          label: element.labelKey.tr(),
          child: FloatingActionButton(
            backgroundColor: theme.toggleableActiveColor,
            onPressed: () {
              _isDialOpen.value = false;
              setState(() {
                this._dataDurationFilter = element;
              });
              this._updateDataFrom(element);
            },
            child: Icon(Icons.filter_list),
          )
      ));
    });

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        body: Container(
          child: this._data.isEmpty
              ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container (
                        child: CupertinoActivityIndicator(),
                        margin: EdgeInsets.only(bottom: 10)
                    ),
                    Text("connectionMessages.waiting").tr()
                  ],
                )
              )
              : _getChart(),
          margin: EdgeInsets.only(top: 15, bottom: 40, right: 10)
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.settings,
          overlayColor: theme.primaryColor,
          spacing: 25,
          spaceBetweenChildren: 10,
          openCloseDial: _isDialOpen,
          children: this._getSpeedDialButtons(),
        )
    );
  }

  String _getPointTimeLabel (DataPointModel point) =>
      DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(point.date));

  Widget _getChart () {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        legend: Legend(isVisible: true),

        series: <LineSeries<DataPointModel, String>>[
          LineSeries<DataPointModel, String>(
              dataSource: this._data,
              xValueMapper: (DataPointModel point, _) => _getPointTimeLabel(point),
              yValueMapper: (DataPointModel point, _) => double.parse(point.values[PMFilter.PM_1.getRowIndex()]),
              name: "PM1",
              color: Colors.black
          ),
          LineSeries<DataPointModel, String>(
              dataSource: this._data,
              xValueMapper: (DataPointModel point, _) => _getPointTimeLabel(point),
              yValueMapper: (DataPointModel point, _) => double.parse(point.values[PMFilter.PM_2_5.getRowIndex()]),
              name: "PM2.5",
              color: Colors.red
          ),
          LineSeries<DataPointModel, String>(
              dataSource: this._data,
              xValueMapper: (DataPointModel point, _) => _getPointTimeLabel(point),
              yValueMapper: (DataPointModel point, _) => double.parse(point.values[PMFilter.PM_10.getRowIndex()]),
              name: "PM10",
              color: Colors.yellow
          )
        ]
    );
  }
}
