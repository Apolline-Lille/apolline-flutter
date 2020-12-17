import 'package:flutter_blue/flutter_blue.dart';

class SensorDevice {
  BluetoothDevice _device;

  ///
  ///constructor
  SensorDevice(this._device);

  ///
  ///return the name of sensor device
  String get deviceName {
    return this._device.name;
  }

  ///
  ///get the id of sensor bluetooth
  String get id {
    return this._device.id.toString();
  }

  ///
  ///
  BluetoothDevice get device {
    return this._device;
  }
}