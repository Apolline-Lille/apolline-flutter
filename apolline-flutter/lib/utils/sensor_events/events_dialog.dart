import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

final UserConfigurationService ucS = locator<UserConfigurationService>();
final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');

void showSensorEventsDialog(BuildContext context, String deviceName) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deviceName),
          contentPadding: EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 20),
          content: _hasEventsForSensor(deviceName) ? Container(
              height: 300,
              width: 300,
              child: ListView(
                children: _getEventCards(deviceName),
              )
          ) : ListTile(
            title: Text("events.noEventsText").tr(),
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
        title: Text(event.type.label),
        subtitle: Text(formatter.format(event.time).toString()),
        tileColor: event.type == SensorEventType.Connection
            ? Colors.green.shade100
            : event.type == SensorEventType.Disconnection
              ? Colors.red.shade100
              : Colors.white
      )
    );
  });
  return widgets.reversed.toList();
}