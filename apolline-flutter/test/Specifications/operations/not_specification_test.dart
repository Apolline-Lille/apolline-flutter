import 'package:apollineflutter/specifications/operations/not_specification.dart';
import 'package:apollineflutter/specifications/sensor/sensor_send_negative_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return true when sensor send positive value', () {
    expect(NotSpecification(SensorSendNegativeValue()).isSatisfiedBy(15), true);
  });

  test('Should return false when sensor send negative value', () {
    expect(NotSpecification(SensorSendNegativeValue()).isSatisfiedBy(-15), false);
  });

}