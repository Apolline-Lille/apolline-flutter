import 'package:apollineflutter/specifications/operations/LeafSpecification.dart';

class SensorSendDangerousValue extends LeafSpecification {
  int dangerThreshold ;

  SensorSendDangerousValue(int dangerThreshold) {
    this.dangerThreshold = dangerThreshold;

  }

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate >= dangerThreshold;
  }
}