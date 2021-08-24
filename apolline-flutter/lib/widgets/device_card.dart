import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceCard extends StatefulWidget {
  DeviceCard({this.deviceName, this.deviceId, this.connectionCallback});
  final String deviceName;
  final String deviceId;
  final Function(String, String) connectionCallback;

  @override
  State<StatefulWidget> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.deviceName),
        subtitle: Text(widget.deviceId),
        onTap: () {
          widget.connectionCallback(widget.deviceName, widget.deviceId;
        },
      )
    );
  }
}