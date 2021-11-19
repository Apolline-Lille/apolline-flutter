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
              child: _hasEventsForSensor(deviceName) ? ListView(
                children: _getEventCards(deviceName),
              ) : ListTile(
                title: Text("No events registered for this device."),
              )
          ),
        );
      }
  );
}

bool _hasEventsForSensor(String deviceName) {
  return ucS.userConf.getSensorEvents(deviceName) != null;
}

List<Widget> _getEventCards (String deviceName) {
  List<Widget> widgets = [];
  ucS.userConf.getSensorEvents(deviceName).forEach((event) {
    widgets.add(
      ListTile(
        title: Text(event.type.toString()),
        subtitle: Text(event.time.toString()),
      )
    );
  });
  return widgets.reversed.toList();
}