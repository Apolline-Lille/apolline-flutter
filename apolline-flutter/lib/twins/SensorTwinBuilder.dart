import 'package:apollineflutter/twins/SensorTwin.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../gattsample.dart';

class SensorTwinBuilder {
  static Future<SensorTwin> buildSensor (BluetoothDevice device) async {
    BluetoothCharacteristic characteristic = await _retrieveSensorCharacteristic(device);
    return SensorTwin(device: characteristic);
  }

  static Future<BluetoothCharacteristic> _retrieveSensorCharacteristic (BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    BluetoothService sensorService = services.firstWhere((service) => service.uuid.toString().toLowerCase() == BlueSensorAttributes.dustSensorServiceUUID);
    BluetoothCharacteristic characteristic = sensorService.characteristics.firstWhere((char) => char.uuid.toString().toLowerCase() == BlueSensorAttributes.dustSensorCharacteristicUUID);
    return characteristic;
  }
}