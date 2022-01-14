import 'package:apollineflutter/specifications/operations/and_specification.dart';
import 'package:apollineflutter/specifications/sensor/sensor_send_dangerous_value.dart';
import 'package:apollineflutter/specifications/sensor/sensor_send_inconsistent_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return true when sensor send dangerous value and inconsistent value', () {
    int threshold = 10;
    expect(AndSpecification(SensorSendDangerousValue(threshold), SensorSendInconsistentValue(threshold)).isSatisfiedBy(15), true);
  });

  test('Should return false when sensor send dangerous value but not inconsistent value', () {
    int dangerThreshold = 10;
    int inconsistentThreshold = 20;
    expect(AndSpecification(SensorSendDangerousValue(dangerThreshold), SensorSendInconsistentValue(inconsistentThreshold)).isSatisfiedBy(15), false);
  });

  test('Should return false when sensor don\'t send dangerous value but an inconsistent value', () {
    int dangerThreshold = 20;
    int inconsistentThreshold = 10;
    expect(AndSpecification(SensorSendDangerousValue(dangerThreshold), SensorSendInconsistentValue(inconsistentThreshold)).isSatisfiedBy(15), false);
  });

  test('Should return false when sensor don\'t send dangerous value and not inconsistent value', () {
    int dangerThreshold = 20;
    int inconsistentThreshold = 20;
    expect(AndSpecification(SensorSendDangerousValue(dangerThreshold), SensorSendInconsistentValue(inconsistentThreshold)).isSatisfiedBy(15), false);
  });
}