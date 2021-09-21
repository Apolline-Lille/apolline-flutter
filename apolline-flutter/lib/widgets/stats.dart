import 'dart:async';
import 'dart:core';

import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/services/realtime_data_service.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/utils/time_filter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class Stats extends StatefulWidget {
  Stats({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return StatsState();
  }
}

class StatsState extends State<Stats> {
  StatsState({Key key});
  RealtimeDataService _dataService = locator<RealtimeDataService>();
  Stream<DataPointModel> _dataStream = locator<RealtimeDataService>().dataStream;
  StreamSubscription<DataPointModel> _streamSubscription;
  List<DataPointModel> _data;
  TimeFilter _dataDurationFilter;
  SqfLiteService _sqfLiteService;
  ValueNotifier<bool> _isDialOpen;

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    this._data = [];
    this._dataDurationFilter = TimeFilter.LAST_5_MIN;
    this._sqfLiteService = SqfLiteService();
    this._isDialOpen = ValueNotifier(false);

    this._sqfLiteService.getAllDataPointsAfterDate(this._dataDurationFilter)
        .then((points){
          setState(() {
            this._data = points;
          });
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
        body: _getChart(),
        floatingActionButton: SpeedDial(
          icon: Icons.settings,
          overlayColor: theme.primaryColor,
          spacing: 25,
          spaceBetweenChildren: 10,
          openCloseDial: _isDialOpen,
          children: [
            SpeedDialChild(
                label: _dataService.isRunning ? "Pause data gathering" : "Resume data gathering",
                child: FloatingActionButton(
                  onPressed: () {
                    _isDialOpen.value = false;
                    _dataService.isRunning ? _dataService.stop() : _dataService.start();
                  },
                  child: Icon(_dataService.isRunning ? Icons.pause : Icons.play_arrow),
                )
            ),
            SpeedDialChild(
                label: "Display data from last minute",
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isDialOpen.value = false;
                      this._dataDurationFilter = TimeFilter.LAST_MIN;
                    });
                  },
                  child: Icon(Icons.filter_list),
                )
            ),
            SpeedDialChild(
                label: "Display data from last 5 minutes",
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isDialOpen.value = false;
                      this._dataDurationFilter = TimeFilter.LAST_5_MIN;
                    });
                  },
                  child: Icon(Icons.filter_list),
                )
            ),
            SpeedDialChild(
                label: "Display data from last 15 minutes",
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isDialOpen.value = false;
                      this._dataDurationFilter = TimeFilter.LAST_15_MIN;
                    });
                  },
                  child: Icon(Icons.filter_list),
                )
            ),
          ],
        )
    );
  }

  String _getPointTimeLabel (DataPointModel point) =>
      DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(point.date));

  Widget _getChart () {
    return SfCartesianChart(

        primaryXAxis: CategoryAxis(),
        // Chart title
        title: ChartTitle(text: 'Pollution exposition'),
        // Enable legend
        legend: Legend(isVisible: true),

        series: <LineSeries<DataPointModel, String>>[
          LineSeries<DataPointModel, String>(
              dataSource: this._data,
              xValueMapper: (DataPointModel point, _) => _getPointTimeLabel(point),
              yValueMapper: (DataPointModel point, _) => double.parse(point.values[PMFilter.PM_1.getRowIndex()]),
              dataLabelSettings: DataLabelSettings(isVisible: true),
              name: "PM1",
              color: Colors.black
          ),
          LineSeries<DataPointModel, String>(
              dataSource: this._data,
              xValueMapper: (DataPointModel point, _) => _getPointTimeLabel(point),
              yValueMapper: (DataPointModel point, _) => double.parse(point.values[PMFilter.PM_2_5.getRowIndex()]),
              dataLabelSettings: DataLabelSettings(isVisible: true),
              name: "PM2.5",
              color: Colors.red
          ),
          LineSeries<DataPointModel, String>(
              dataSource: this._data,
              xValueMapper: (DataPointModel point, _) => _getPointTimeLabel(point),
              yValueMapper: (DataPointModel point, _) => double.parse(point.values[PMFilter.PM_10.getRowIndex()]),
              dataLabelSettings: DataLabelSettings(isVisible: true),
              name: "PM10",
              color: Colors.yellow
          )
        ]
    );
  }
}
