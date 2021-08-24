import 'package:apollineflutter/gattsample.dart';
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
  Future<bool> _isDeviceDustSensor() async {
    Future<bool> returnValue;

    await widget.device.connect(autoConnect: false)
        .timeout(Duration(seconds: 5), onTimeout: (){
      returnValue = Future.value(false);
    }).catchError((e) {
      returnValue = Future.value(false);
    });

    if(returnValue == null) {
      var services = await widget.device.discoverServices();
      returnValue = Future.value(services.where((service) => service.uuid.toString().toLowerCase() == BlueSensorAttributes.dustSensorServiceUUID).length != 0);
    }

    await widget.device.disconnect();
    return returnValue;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(true), //_isDeviceDustSensor(), TODO implement
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Card(
          child: ListTile(
            title: Text(widget.device.name),
            subtitle: Text(widget.device.id.toString()),
            enabled: snapshot.connectionState == ConnectionState.done && snapshot.data,
            onTap: () {
              widget.connectionCallback(widget.device);
            },
          )
        );
      });
  }
}