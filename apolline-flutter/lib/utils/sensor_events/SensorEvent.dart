import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';

class SensorEvent {
  SensorEventType type;
  DateTime time;

  SensorEvent(this.type, {String time = ""}) {
    this.type = type;
    this.time = time.length == 0
        ? DateTime.now()
        : DateTime.parse(time);
  }
}