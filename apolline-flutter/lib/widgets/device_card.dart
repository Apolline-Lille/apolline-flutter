import 'package:apollineflutter/utils/sensor_events/events_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceCard extends StatefulWidget {
  DeviceCard({required this.device, required this.connectionCallback, this.enabled = true});
  final BluetoothDevice device;
  final Function(BluetoothDevice) connectionCallback;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.device.name),
        subtitle: Text(widget.device.id.toString()),
        onTap: () {
          widget.connectionCallback(widget.device);
        },
        onLongPress: () {
          showSensorEventsDialog(context, widget.device.name);
        },
        enabled: widget.enabled,
        trailing: widget.enabled ? null : Icon(Icons.bluetooth_disabled_outlined),
      )
    );
  }
}