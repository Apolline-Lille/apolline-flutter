import 'package:apollineflutter/models/indoor_user_actions.dart';
import 'package:apollineflutter/models/outdoor_user_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class InconsistentValueReportView extends StatefulWidget {
  final String captor;
  final double value;

  InconsistentValueReportView({Key key, this.captor, this.value}) : super(key: key);

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
                //TODO send data to db
                print("data : {'isOutdoor': $_isOutdoor, 'activity': $_userCurrentAction}");
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

}