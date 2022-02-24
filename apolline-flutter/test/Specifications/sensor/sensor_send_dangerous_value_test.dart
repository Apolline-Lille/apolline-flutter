import 'package:apollineflutter/specifications/sensor/sensor_send_dangerous_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return true when threshold value is equal to sensor value', () {
    int dangerThreshold = 10;
    double sensorValue = 10;
    expect(SensorSendDangerousValue(dangerThreshold).isSatisfiedBy(sensorValue), true);
  });

  test('Should return true when sensor value is superior to the threshold value', () {
    int dangerThreshold = 10;
    double sensorValue = 10.5;
    expect(SensorSendDangerousValue(dangerThreshold).isSatisfiedBy(sensorValue), true);
    sensorValue = 15.2;
    expect(SensorSendDangerousValue(dangerThreshold).isSatisfiedBy(sensorValue), true);
  });

  test('Should return false when threshold value is superior to sensor value', () {
    int dangerThreshold = 10;
    double sensorValue = 9.9;
    expect(SensorSendDangerousValue(dangerThreshold).isSatisfiedBy(sensorValue), false);
    sensorValue = 5.8;
    expect(SensorSendDangerousValue(dangerThreshold).isSatisfiedBy(sensorValue), false);
  });
}