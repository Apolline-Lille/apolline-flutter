import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceCard extends StatefulWidget {
  DeviceCard({this.device, this.connectionCallback});
  final BluetoothDevice device;
  final Function(BluetoothDevice) connectionCallback;

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
      )
    );
  }
}