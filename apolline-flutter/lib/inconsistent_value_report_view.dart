import 'package:apollineflutter/models/data_point_model.dart';
import 'package:apollineflutter/models/indoor_user_actions.dart';
import 'package:apollineflutter/models/outdoor_user_actions.dart';
import 'package:apollineflutter/services/influxdb_client.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'gattsample.dart';

class InconsistentValueReportView extends StatefulWidget {
  final String captor;
  final double value;
  final int time;

  InconsistentValueReportView({Key key, this.captor, this.value, this.time}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InconsistentValueReportViewState();
  }

}

class InconsistentValueReportViewState extends State<InconsistentValueReportView> {
  final _formKey = GlobalKey<FormState>();
  bool _isOutdoor = false;
  String _userCurrentAction = IndoorUserAction.values[0].name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("inconsistentReport.title".tr()),
      ),
      body: _buildForm(),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),
              child: Text(
                "inconsistentReport.message".tr(args: [widget.value.toString(), widget.captor]),
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              )
          ),
          Text("inconsistentReport.form.inOutdoorLabel".tr()),
          ListTile(
            title: Text("inconsistentReport.form.indoor".tr()),
            leading: Radio<bool>(
                value: false,
                groupValue: _isOutdoor,
                onChanged: (bool value) {
                  setState(() {
                    _isOutdoor = value;
                    _userCurrentAction = IndoorUserAction.values[0].name;
                  });
                }
            ),
          ),
          ListTile(
            title: Text("inconsistentReport.form.outdoor".tr()),
            leading: Radio<bool>(
                value: true,
                groupValue: _isOutdoor,
                onChanged: (bool value) {
                  setState(() {
                    _isOutdoor = value;
                    _userCurrentAction = OutdoorUserAction.values[0].name;
                  });
                }
            ),
          ),
          Text("inconsistentReport.form.contextLabel".tr()),
          DropdownButton(
              value: _userCurrentAction,
              onChanged: (String value) {
                setState(() {
                  _userCurrentAction = value;
                });
              },
              items: _getDropdownItems()
          ),
          ElevatedButton(
            onPressed: () {
              if(_formKey.currentState.validate()) {
                SnackBar snackBar = SnackBar(content: Text("inconsistentReport.form.valid".tr()));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                _sendReport();
                Navigator.of(context).pop();
              }
            },
            child: Text("inconsistentReport.form.button".tr()),
          )
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    List<String> availableActions = [];
    if(_isOutdoor) {
      availableActions = OutdoorUserAction.values.map<String>((OutdoorUserAction action) {
        return action.name;
      }).toList();
    } else {
      availableActions = IndoorUserAction.values.map<String>((IndoorUserAction action) {
        return action.name;
      }).toList();
    }

    return availableActions
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
          value: value,
          child: Text(value)
      );
    }).toList();
  }

  _sendReport() async {
    InfluxDBAPI db = InfluxDBAPI();
    List<DataPointModel> models = await SqfLiteService().getDataPointsWithDate(widget.time);

    if(models.length > 0) {
      DataPointModel model = models[0];
      String captorName = _getCaptorDBName();
      String unit = _getUnit();

      String data = "$captorName,"
          "uuid=${BlueSensorAttributes.dustSensorServiceUUID},"
          "device=${model.sensorName},provider=${model.position.provider},"
          "geohash=${model.position.geohash},"
          "transport=${model.position.transport},"
          "unit=$unit,outdoor=$_isOutdoor,"
          "activity=$_userCurrentAction value=${widget.value} ${model.date}";
      db.write(data);
    }
  }

  String _getCaptorDBName() {
    switch(widget.captor) {
      case "PM_1":
        return "pm.01.value";
      case "PM_2_5":
        return "pm.2_5.value";
      case "PM_10":
        return "pm.10.value";
      case "PM_ABOVE_0_3":
        return "pm.0_3.above";
      case "PM_ABOVE_0_5":
        return "pm.0_5.above";
      case "PM_ABOVE_1":
        return "pm.1.above";
      case "PM_ABOVE_2_5":
        return "pm.2_5.above";
      case "PM_ABOVE_5":
        return "pm.5.above";
      case "PM_ABOVE_10":
        return "pm.10.above";
      default:
        return "ERROR";
    }
  }

  String _getUnit() {
    switch (widget.captor) {
      case "PM_1":
      case "PM_2_5":
      case "PM_10":
        return Units.CONCENTRATION_UG_M3;
      case "PM_ABOVE_0_3":
      case "PM_ABOVE_0_5":
      case "PM_ABOVE_1":
      case "PM_ABOVE_2_5":
      case "PM_ABOVE_5":
      case "PM_ABOVE_10":
        return Units.CONCENTRATION_ABOVE;
      default:
        return "ERROR";
    }
  }

}