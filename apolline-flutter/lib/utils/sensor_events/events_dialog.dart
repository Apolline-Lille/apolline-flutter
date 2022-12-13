import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'SensorEvent.dart';

final UserConfigurationService ucS = locator<UserConfigurationService>();
final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');

void showSensorEventsDialog(BuildContext context, String deviceName) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventsDialog(
          deviceName: deviceName,
          events: ucS.userConf.getSensorEvents(deviceName)
        );
      }
  );
}


class EventsDialog extends StatefulWidget {
  final String deviceName;
  final List<SensorEvent> events;
  EventsDialog({required this.deviceName, required this.events});

  @override
  State<StatefulWidget> createState() => _EventsDialogState();
}

class _EventsDialogState extends State<EventsDialog> {
  bool _showLiveDataEvents = true;

  bool _hasEvents() {
    return widget.events.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.deviceName),
      contentPadding: EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 20),
      content: _hasEvents() ? Container(
          height: 300,
          width: 300,
          child: ListView(
            children:  widget.events
                .where((element) => !_showLiveDataEvents || _showLiveDataEvents && element.type != SensorEventType.LiveData)
                .map((event) => ListTile(
                    title: Text(event.type.label),
                    dense: event.type == SensorEventType.LiveData,
                    subtitle: Text(formatter.format(event.time).toString()),
                    tileColor: event.type == SensorEventType.Connection
                        ? Colors.green.shade100
                        : event.type == SensorEventType.Disconnection
                        ? Colors.red.shade100
                        : Colors.white
                )).toList().reversed.toList(),
          )
      ) : ListTile(
        title: Text("events.noEventsText").tr(),
      ),
    );
  }
}