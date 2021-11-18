import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';

class SensorEvent {
  SensorEventType type;
  DateTime time;

  SensorEvent(this.type) {
    this.type = type;
    this.time = DateTime.now();
  }
}