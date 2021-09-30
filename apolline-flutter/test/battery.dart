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
}