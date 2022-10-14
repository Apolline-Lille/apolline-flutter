import 'package:easy_localization/easy_localization.dart';

enum SensorEventType {
  Connection, Disconnection, LiveData
}

extension SensorEventTypeUtils on SensorEventType {
  static final Map<SensorEventType, String> _labels = {
    SensorEventType.Connection: "events.types.connection",
    SensorEventType.Disconnection: "events.types.disconnection",
    SensorEventType.LiveData: "events.types.liveData"
  };

  String get label {
    if (SensorEventTypeUtils._labels[this] == null)
      throw RangeError("This SensorEventType has no associated label.");
    return SensorEventTypeUtils._labels[this]!.tr();
  }
}