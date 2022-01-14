import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

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