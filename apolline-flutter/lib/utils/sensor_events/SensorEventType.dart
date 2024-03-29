import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum SensorEventType {
  Connection, Disconnection, LiveData,
  DataSendingOk, DataSendingFail
}

class _SensorEventTypeData {
  final String label;
  final Color color;
  _SensorEventTypeData(this.label, this.color);
}

extension SensorEventTypeUtils on SensorEventType {
  static final Map<SensorEventType, _SensorEventTypeData> _labels = {
    SensorEventType.Connection: _SensorEventTypeData("events.types.connection", Colors.green.shade100),
    SensorEventType.Disconnection: _SensorEventTypeData("events.types.disconnection", Colors.red.shade100),
    SensorEventType.LiveData: _SensorEventTypeData("events.types.liveData", Colors.white),
    SensorEventType.DataSendingOk: _SensorEventTypeData("events.types.dataSendingOk", Colors.blue.shade50),
    SensorEventType.DataSendingFail: _SensorEventTypeData("events.types.dataSendingFailed", Colors.red.shade100)
  };

  String get label {
    if (SensorEventTypeUtils._labels[this] == null)
      throw RangeError("This SensorEventType has no associated data.");
    return SensorEventTypeUtils._labels[this]!.label.tr();
  }

  Color get color {
    if (SensorEventTypeUtils._labels[this] == null)
      throw RangeError("This SensorEventType has no associated data.");
    return SensorEventTypeUtils._labels[this]!.color;
  }
}