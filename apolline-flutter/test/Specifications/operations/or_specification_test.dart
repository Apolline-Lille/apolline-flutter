import 'package:apollineflutter/specifications/operations/or_specification.dart';
import 'package:apollineflutter/specifications/sensor/sensor_send_inconsistent_value.dart';
import 'package:apollineflutter/specifications/sensor/sensor_send_warning_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should return true when sensor send warning value or inconsistent value when they are equal', () {
    int threshold = 10;
    expect(OrSpecification(SensorSendWarningValue(threshold), SensorSendInconsistentValue(threshold)).isSatisfiedBy(15), true);
  });

  test('Should return true when sensor send warning value but not inconsistent value', () {
    int warningThreshold = 10;
    int inconsistentThreshold = 20;
    expect(OrSpecification(SensorSendWarningValue(warningThreshold), SensorSendInconsistentValue(inconsistentThreshold)).isSatisfiedBy(15), true);
  });

  test('Should return true when sensor don\'t send warning value but an inconsistent value', () {
    int warningThreshold = 20;
    int inconsistentThreshold = 10;
    expect(OrSpecification(SensorSendWarningValue(warningThreshold), SensorSendInconsistentValue(inconsistentThreshold)).isSatisfiedBy(15), true);
  });

  test('Should return false when sensor don\'t send warning value and not inconsistent value', () {
    int warningThreshold = 20;
    int inconsistentThreshold = 20;
    expect(OrSpecification(SensorSendWarningValue(warningThreshold), SensorSendInconsistentValue(inconsistentThreshold)).isSatisfiedBy(15), false);
  });
}