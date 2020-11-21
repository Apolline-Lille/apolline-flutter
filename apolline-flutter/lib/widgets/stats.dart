import 'dart:async';
import 'dart:core';

import 'package:apollineflutter/services/realtime_data_service.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:apollineflutter/sensormodel.dart';
import 'package:mp_chart/mp/core/value_formatter/value_formatter.dart';

class Stats extends StatefulWidget {
  Stats({Key key, this.dataSensor}) : super(key: key);
  SensorModel dataSensor;
  @override
  State<StatefulWidget> createState() {
    return StatsState(datas: dataSensor);
  }
}

class StatsState extends State<Stats> implements OnChartValueSelectedListener {
  StatsState({Key key, this.datas});
  RealtimeDataService _dataService = locator<RealtimeDataService>();
  Stream<SensorModels> _dataStream = locator<RealtimeDataService>().dataStream;
  StreamSubscription<SensorModels> _streamSubscription;
  LineChartController controller;
  SensorModel datas;
  ILineDataSet setPM1;
  ILineDataSet setPM2_5;
  ILineDataSet setPM10;
  bool intialized = false;
  double i0 = 0;
  double i1 = 0;
  double i2 = 0;

  List<String> _dataTimeX = List();
  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _initController();
    _streamSubscription = _dataStream.listen((newData) {
      if (intialized) {
        _addEntry(
            0, i0++, double.parse(newData.values[SensorModel.SENSOR_PM_1]));
        _addEntry(
            1, i1++, double.parse(newData.values[SensorModel.SENSOR_PM_2_5]));
        _addEntry(
            2, i2++, double.parse(newData.values[SensorModel.SENSOR_PM_10]));
        _dataTimeX.add(newData.values[SensorModel.SENSOR_DATE]);
        setState(() {});
      }
    });
    super.initState();
    Timer(Duration(milliseconds: 0), () {
      LineData data = controller?.data;
      data = LineData();
      controller.data = data;
      setPM1 = _createSet();
      data.addDataSet(setPM1);
      setPM2_5 = _createSet2();
      data.addDataSet(setPM2_5);
      setPM10 = _createSet3();
      data.addDataSet(setPM10);
      intialized = true;
    });
  }

  void _togglePulsar() {
    if (_dataService.isRunning) {
      _dataService.stop();
    } else {
      _dataService.start();
    }
    setState(() {});
  }

  @override
  Widget getBody() {
    return Stack(children: <Widget>[
      Positioned(
        right: 0,
        left: 0,
        top: 0,
        bottom: 0,
        child: LineChart(controller),
      ),
      Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: _togglePulsar,
          child: Icon(
            _dataService.isRunning ? Icons.pause : Icons.play_arrow,
            color: Color.fromARGB(0xff, 0x17, 0x0b, 0x0f),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..drawGridLines = (false)
            ..setAxisMinimum(0);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight
            ..drawGridLines = (false)
            ..setAxisMinimum(0);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..wordWrapEnabled = (true)
            ..drawInside = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..position = (XAxisPosition.BOTH_SIDED)
            ..setAxisMinimum(0)
            ..setGranularity(1)
            ..setValueFormatter(A(_dataTimeX))
            ..setAxisMaximum(
                controller.data == null ? 0 : controller.data.xMax + 0.25);
        },
        // noDataText:
        //     "No chart data available. \nUse the menu to add entries and data sets!",
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        selectionListener: this,
        pinchZoomEnabled: true,
        infoBgColor: ColorUtils.HOLO_GREEN_LIGHT,
        description: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  final List<Color> colors = ColorUtils.VORDIPLOM_COLORS;

  void _addEntry(int setIndex, double x, double y) {
    LineData data = controller?.data;

    if (data == null) {
      data = LineData();
      controller.data = data;
    }
    data.addEntry(Entry(x: x, y: y), setIndex);
    data.notifyDataChanged();

    controller.setVisibleXRangeMaximum(6);
    controller.moveViewTo(
        (data.getEntryCount() - 7).toDouble(), 50, AxisDependency.LEFT);
    controller.state?.setStateIfNotDispose();
  }

  LineDataSet _createSet() {
    LineDataSet set = LineDataSet(null, "PM 1");
    set.setLineWidth(2.5);
    set.setCircleRadius(4.5);
    set.setColor1(Color.fromARGB(255, 240, 99, 99));
    set.setCircleColor(Color.fromARGB(255, 240, 99, 99));
    set.setHighLightColor(Color.fromARGB(255, 190, 190, 190));
    set.setAxisDependency(AxisDependency.LEFT);
    set.setValueTextSize(10);
    return set;
  }

  LineDataSet _createSet2() {
    LineDataSet set = LineDataSet(null, "PM 2.5");
    set.setLineWidth(2.5);
    set.setCircleRadius(4.5);
    set.setColor1(Color.fromARGB(100, 0, 255, 99));
    set.setCircleColor(Color.fromARGB(255, 240, 99, 99));
    set.setHighLightColor(Color.fromARGB(255, 190, 190, 190));
    set.setAxisDependency(AxisDependency.LEFT);
    set.setValueTextSize(10);
    return set;
  }

  LineDataSet _createSet3() {
    LineDataSet set = LineDataSet(null, "PM 10");
    set.setLineWidth(2.5);
    set.setCircleRadius(4.5);
    set.setColor1(Color.fromARGB(120, 0, 99, 99));
    set.setCircleColor(Color.fromARGB(255, 240, 99, 99));
    set.setHighLightColor(Color.fromARGB(255, 190, 190, 190));
    set.setAxisDependency(AxisDependency.LEFT);
    set.setValueTextSize(10);
    return set;
  }
}

class A extends ValueFormatter {
  A(this._dataTimeX) : super();

  final List<String> _dataTimeX;
  @override
  String getFormattedValue1(double value) {
    List<String> timeX =
        _dataTimeX[value.toInt() % _dataTimeX.length].split('_');
    return timeX[3] + ':' + timeX[4] + ':' + timeX[5];
  }
}
