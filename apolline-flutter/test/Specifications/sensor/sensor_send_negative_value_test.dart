import 'package:apollineflutter/specifications/sensor/sensor_send_negative_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return false when sensor value is positive', () {
    double sensorValue = 10;
    expect(SensorSendNegativeValue().isSatisfiedBy(sensorValue), false);
    sensorValue = 0;
    expect(SensorSendNegativeValue().isSatisfiedBy(sensorValue), false);
    sensorValue = 0.1;
    expect(SensorSendNegativeValue().isSatisfiedBy(sensorValue), false);
  });

  test('Should return true when sensor value negative', () {
    double sensorValue = -10.5;
    expect(SensorSendNegativeValue().isSatisfiedBy(sensorValue), true);
    sensorValue = -0.1;
    expect(SensorSendNegativeValue().isSatisfiedBy(sensorValue), true);
    sensorValue = -0;
    expect(SensorSendNegativeValue().isSatisfiedBy(sensorValue), true);
  });
}