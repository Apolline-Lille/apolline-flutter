import 'package:apollineflutter/models/server_endpoint_handler.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/pm_card.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:apollineflutter/widgets/endpointSelector/server_endpoint_selector_dialog.dart';
import 'package:apollineflutter/widgets/endpointSelector/server_endpoint_selector_qr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'models/server_model.dart';

class SettingsPanel extends StatefulWidget {
  final EdgeInsets padding = EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10);
  final UserConfigurationService ucS;

  SettingsPanel({@required this.ucS});

  @override
  State<StatefulWidget> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  bool _showWarningNotifications = true;
  bool _showDangerNotifications = true;
  Duration _notificationIntervalDuration = Duration(minutes: 5);
  List<List<String>> pickerData = [
    new List<String>.generate(24, (i) => (i).toString() + 'h'),
    new List<String>.generate(60, (i) => (i).toString() + 'min')
  ];
  ServerModel _dropdownValue = ServerEndpointHandler().currentServerEndpoint;
  Future<List<ServerModel>> _serverEndpoints;

  @override
  initState () {
    this._showWarningNotifications = widget.ucS.userConf.showWarningNotifications;
    this._showDangerNotifications = widget.ucS.userConf.showDangerNotifications;
    this._notificationIntervalDuration = widget.ucS.userConf.exposureNotificationsTimeInterval;
    _serverEndpoints = SqfLiteService().getAllServerEndpoints();
    super.initState();
  }

  List<Widget> _buildAllPMCards () {
    return PMFilter.values.map((value) => PMCard(ucS: widget.ucS, indicator: value)).toList();
  }

  Widget _buildInformationWidget () {
    return Container (
      child: Text("settings.description").tr(),
    );
  }

  // https://stackoverflow.com/a/54775297/11243782
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }

  Widget _buildNotificationConfigurationWidget () {
    Function updateWarningState = (bool value) {
      widget.ucS.userConf.showWarningNotifications = value;
      widget.ucS.update();
      setState(() {
        _showWarningNotifications = value;
      });
    };

    Function updateDangerState = (bool value) {
      widget.ucS.userConf.showDangerNotifications = value;
      widget.ucS.update();
      setState(() {
        _showDangerNotifications = value;
      });
    };

    return Container (
        margin: EdgeInsets.only(top: 30),
        child: Column(
          children: [
            ListTile(
              title: Text("settings.receiveWarning").tr(),
              onTap: () => updateWarningState(!_showWarningNotifications),
              trailing: Checkbox(
                value: _showWarningNotifications,
                onChanged: updateWarningState,
              ),
            ),
            ListTile(
              title: Text("settings.receiveDanger").tr(),
              onTap: () => updateDangerState(!_showDangerNotifications),
              trailing: Checkbox(
                value: _showDangerNotifications,
                onChanged: updateDangerState,
              ),
            ),
            ListTile(
                enabled: _showWarningNotifications || _showDangerNotifications,
                title: Text("settings.timeInterval").tr(),
                subtitle: Text('(' + "settings.sameType".tr() + ')'),
                trailing: Container(
                    margin: EdgeInsets.only(right: 6),
                    child: Text(_printDuration(_notificationIntervalDuration))
                ),
                onTap: () => showPickerModal(context)
            )
          ],
        )
    );
  }

  showPickerModal(BuildContext context) {
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: pickerData, isArray: true),
        changeToFirst: true,
        hideHeader: false,
        confirmText: 'OK',
        cancelText: 'devicesView.analysisButton.cancel'.tr(),
        selecteds: [
          _notificationIntervalDuration.inHours,
          _notificationIntervalDuration.inMinutes % 60
        ],
        onConfirm: (Picker picker, List value) {
          String hoursValue = pickerData[0][value[0]];
          String minutesValue = pickerData[1][value[1]];

          Duration newDuration = Duration(
              hours: int.parse(hoursValue.substring(0, hoursValue.length-1)),
              minutes: int.parse(minutesValue.substring(0, minutesValue.length-3))
          );

          setState(() => _notificationIntervalDuration = newDuration);
          widget.ucS.userConf.exposureNotificationsTimeInterval = newDuration;
          widget.ucS.update();
        }
    ).showModal(context); //_scaffoldKey.currentState);
  }

  Widget _buildEndpointSelector() {
    List<Widget> widgets = [];

    widgets.add(
        FutureBuilder<List<ServerModel>>(
          future: _serverEndpoints,
          builder: (BuildContext context, AsyncSnapshot<List<ServerModel>> snapshot) {
            if(snapshot.hasData) {
              return DropdownButton(
                  value: _dropdownValue,
                  onChanged: (value) {
                    if(ServerEndpointHandler().changeCurrentServerEndpoint(value)){
                      _updateDropdown();
                      Fluttertoast.showToast(msg: "settings.endpointSelector.confirmationSnackbar".tr());
                    } else {
                      Fluttertoast.showToast(msg: "settings.endpointSelector.errorSnackbar".tr());
                    }
                  },
                  items: snapshot.data
                      .map<DropdownMenuItem<ServerModel>>((ServerModel endpoint) {
                    return DropdownMenuItem<ServerModel>(
                        value: endpoint,
                        child: Row(
                            children: <Widget>[
                              Text(endpoint.dbName),
                              IconButton(
                                icon: Icon(
                                    Icons.delete_forever,
                                    color: Colors.redAccent
                                ),
                                onPressed: () {
                                  SqfLiteService().deleteEndpoint(endpoint).then((numberOfRowsDeleted) {
                                    if(numberOfRowsDeleted >= 1) {
                                      _updateDropdown();
                                      Fluttertoast.showToast(
                                          msg: "endpoint.remove".tr(
                                              args: [endpoint.dbName]));
                                      Navigator.pop(
                                          context); // close dropdown menu
                                    } else {
                                      Fluttertoast.showToast(msg: "endpoint.removeError".tr());
                                    }
                                  });

                                },
                              )
                            ]
                        )
                    );
                  }).toList()
              );
            }
            else if(snapshot.hasError) {
              return Text("endpoint.dataLoadError".tr());
            }
            return CircularProgressIndicator();
          },
        )
    );

    widgets.add(
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget> [
              ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if(states.contains(MaterialState.pressed)) {
                      return Theme
                          .of(context)
                          .primaryColor
                          .withOpacity(0.5);
                    }
                    return Theme.of(context).primaryColor;
                  })),
                  child: Column(
                      children: <Widget>[
                        Icon(Icons.qr_code_scanner_outlined),
                        Text("settings.endpointSelector.qrCodeButton".tr(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12)
                        )
                      ]
                  ),
                  onPressed: () =>
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ServerEndpointSelectorQr(),
                            fullscreenDialog: false))
                        .then((value) {
                      if (value != null) {
                        Fluttertoast.showToast(msg: value.toString());
                        _updateDropdown();
                      }
                    })
                  }
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if(states.contains(MaterialState.pressed)) {
                          return Theme
                              .of(context)
                              .primaryColor
                              .withOpacity(0.5);
                        }
                        return Theme.of(context).primaryColor;
                      })),
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ServerEndpointSelectorDialog(), fullscreenDialog: true))
                            .then((value) {
                          if(value != null) {
                            Fluttertoast.showToast(msg: value.toString());
                            _updateDropdown();
                          }
                        })
                      },
                      child: Text("settings.endpointSelector.manualButton".tr(),
                        overflow: TextOverflow.ellipsis,)
                  )
              )
            ])
    );

    return Column(children: widgets);
  }

  void _updateDropdown() {
    setState(() {
      SqfLiteService().getDefaultEndpoint().then((value) {
        _dropdownValue = value;
      });
      _serverEndpoints = SqfLiteService().getAllServerEndpoints();
    });
  }


  @override
  Widget build(BuildContext context)  {
    List<Widget> widgets = [
      _buildInformationWidget(),
      _buildNotificationConfigurationWidget(),
      _buildEndpointSelector(),
      Divider(height: 70)
    ];
    widgets.addAll(_buildAllPMCards());

    return Container(
      child: ListView(
          children: widgets,
          padding: widget.padding
      ),
    );
  }
}