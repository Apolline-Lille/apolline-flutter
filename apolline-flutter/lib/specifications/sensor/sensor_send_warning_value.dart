import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

class SensorSendWarningValue extends LeafSpecification {
  int warningThreshold ;

  SensorSendWarningValue(int warningThreshold) {
    this.warningThreshold = warningThreshold;
  }

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate >= warningThreshold;
  }

}