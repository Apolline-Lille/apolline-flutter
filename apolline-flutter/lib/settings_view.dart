import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/pm_card.dart';
import 'package:apollineflutter/utils/pm_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:easy_localization/easy_localization.dart';

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

  @override
  initState () {
    this._showWarningNotifications = widget.ucS.userConf.showWarningNotifications;
    this._showDangerNotifications = widget.ucS.userConf.showDangerNotifications;
    this._notificationIntervalDuration = widget.ucS.userConf.exposureNotificationsTimeInterval;
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
            trailing: Container(
              margin: EdgeInsets.only(right: 6),
                child: Text(_printDuration(_notificationIntervalDuration))
            ),
            onTap: () => showDialog(context: context, builder: (context) => AlertDialog(
              title: const Text('settings.setTimeInterval').tr(),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Container (
                      margin: EdgeInsets.only(bottom: 30),
                      child: Text("settings.setTimeIntervalBody").tr()
                    ),
                    DurationPicker(
                      duration: _notificationIntervalDuration,
                      onChange: (val) {
                        setState(() => _notificationIntervalDuration = val);
                        widget.ucS.userConf.exposureNotificationsTimeInterval = val;
                        widget.ucS.update();
                      }
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('devicesView.analysisButton.cancel').tr(),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
              )),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      _buildInformationWidget(),
      _buildNotificationConfigurationWidget(),
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