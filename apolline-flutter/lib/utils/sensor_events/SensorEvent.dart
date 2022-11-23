import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';

class SensorEvent {
  SensorEventType type;
  late DateTime time;

  SensorEvent(this.type, {String time = ""}) {
    this.type = type;
    this.time = time.length == 0
        ? DateTime.now()
        : DateTime.parse(time);
  }

  SensorEvent.fromJson(Map<String, dynamic> json)
      : type = SensorEventType.values[json['type']],
        time = DateTime.parse(json['time']);

  Map<String, dynamic> toJson() => {
    'type': this.type.index,
    'time': this.time.toIso8601String(),
  };
}