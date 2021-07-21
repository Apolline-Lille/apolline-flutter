import 'package:flutter_blue/flutter_blue.dart';

/// Authors BARRY Issagha, GDISSA Ramy
/// 
class SensorDevice {
  BluetoothDevice _device;
  String _name;

  /// Authors BARRY Issagha, GDISSA Ramy
  ///constructor
  SensorDevice(this._device);

  SensorDevice.fromNameAndUId(name, uuid) {
    this._name = name;
  }

  ///
  ///return the name of sensor device
  String get deviceName {
    return this._device?.name ?? this._name;
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
