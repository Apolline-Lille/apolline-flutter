import 'package:flutter/cupertino.dart';

class BatteryLevelStep {
  final int percentage;
  final double voltageValue;
  BatteryLevelStep({required this.percentage, required this.voltageValue});
}

final List<BatteryLevelStep> _steps = [
  BatteryLevelStep(percentage: 0, voltageValue: 3),
  BatteryLevelStep(percentage: 5, voltageValue: 3.3),
  BatteryLevelStep(percentage: 10, voltageValue: 3.6),
  BatteryLevelStep(percentage: 20, voltageValue: 3.70),
  BatteryLevelStep(percentage: 30, voltageValue: 3.75),
  BatteryLevelStep(percentage: 40, voltageValue: 3.79),
  BatteryLevelStep(percentage: 50, voltageValue: 3.83),
  BatteryLevelStep(percentage: 60, voltageValue: 3.87),
  BatteryLevelStep(percentage: 70, voltageValue: 3.92),
  BatteryLevelStep(percentage: 80, voltageValue: 3.97),
  BatteryLevelStep(percentage: 90, voltageValue: 4.1),
  BatteryLevelStep(percentage: 100, voltageValue: 4.2)
];

int getBatteryPercentageFromVoltageValue(double voltageValue) {
  final BatteryLevelStep minStep = _steps.first;
  final BatteryLevelStep maxStep = _steps.last;

  if (voltageValue <= minStep.voltageValue)
    return minStep.percentage;
  if (voltageValue >= maxStep.voltageValue)
    return maxStep.percentage;

  for (int i=0; i<_steps.length-1; i++) {
    final inferiorStep = _steps[i];
    final superiorStep = _steps[i+1];

    if (voltageValue >= inferiorStep.voltageValue
        && voltageValue < superiorStep.voltageValue) {
      double coefficient = (voltageValue - inferiorStep.voltageValue) / (superiorStep.voltageValue - inferiorStep.voltageValue);
      int percentageDiff = superiorStep.percentage - inferiorStep.percentage;
      return (inferiorStep.percentage + percentageDiff*coefficient).round();
    }
  }

  return -1;
}