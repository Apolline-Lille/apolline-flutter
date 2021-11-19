enum SensorEventType {
  Connection, Disconnection, LiveData
}

extension SensorEventTypeUtils on SensorEventType {
  static final Map<SensorEventType, String> _labels = {
    SensorEventType.Connection: "Connected to sensor",
    SensorEventType.Disconnection: "Disconnection from sensor",
    SensorEventType.LiveData: "Air quality data received (live)"
  };

  String get label {
    if (SensorEventTypeUtils._labels[this] == null)
      throw RangeError("This SensorEventType has no associated label.");
    return SensorEventTypeUtils._labels[this];
  }
}