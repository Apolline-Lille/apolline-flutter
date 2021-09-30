import 'package:apollineflutter/utils/battery_level_computer.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  test('should return battery level of 0% for low voltage', () {
    const currentVoltage = 2.5;
    final int percentageResult = getBatteryPercentageFromVoltageValue(currentVoltage);
    expect(percentageResult, 0);
  });

  test('should return battery level of 0% for negative voltage', () {
    const currentVoltage = -42.0;
    final int percentageResult = getBatteryPercentageFromVoltageValue(currentVoltage);
    expect(percentageResult, 0);
  });

  test('should return battery level of 100% for high voltage', () {
    const currentVoltage = 6.42;
    final int percentageResult = getBatteryPercentageFromVoltageValue(currentVoltage);
    expect(percentageResult, 100);
  });

  test('should return battery level of 95%', () {
    const currentVoltage = 4.15;  // between 4.1V (90%) and 4.2V (100%) steps
    final int percentageResult = getBatteryPercentageFromVoltageValue(currentVoltage);
    expect(percentageResult, 95);
  });
}