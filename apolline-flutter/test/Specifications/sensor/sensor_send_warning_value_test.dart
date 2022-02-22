import 'package:apollineflutter/specifications/sensor/sensor_send_warning_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return true when threshold value is equal to sensor value', () {
    int warningThreshold = 10;
    double sensorValue = 10;
    expect(SensorSendWarningValue(warningThreshold).isSatisfiedBy(sensorValue), true);
  });

  test('Should return true when sensor value is superior to the threshold value', () {
    int threshold = 10;
    double sensorValue = 10.5;
    expect(SensorSendWarningValue(threshold).isSatisfiedBy(sensorValue), true);
    sensorValue = 15.2;
    expect(SensorSendWarningValue(threshold).isSatisfiedBy(sensorValue), true);
  });

  test('Should return false when threshold value is superior to sensor value', () {
    int threshold = 10;
    double sensorValue = 9.9;
    expect(SensorSendWarningValue(threshold).isSatisfiedBy(sensorValue), false);
    sensorValue = 5.8;
    expect(SensorSendWarningValue(threshold).isSatisfiedBy(sensorValue), false);
  });
}