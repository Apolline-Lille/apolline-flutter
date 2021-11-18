import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final UserConfigurationService ucS = locator<UserConfigurationService>();

void showSensorEventsDialog(BuildContext context, String deviceName) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deviceName),
          contentPadding: EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 20),
          content: Container(
              height: 300,
              width: 300,
              child: ListView(
                children: _getEventCards(),
              )
          ),
        );
      }
  );
}

List<Widget> _getEventCards () {
  List<Widget> widgets = [];
  ucS.userConf.sensorEvents.forEach((event) {
    widgets.add(
      ListTile(
        title: Text(event.type.toString()),
        subtitle: Text(event.time.toString()),
      )
    );
  });
  return widgets.reversed.toList();
}