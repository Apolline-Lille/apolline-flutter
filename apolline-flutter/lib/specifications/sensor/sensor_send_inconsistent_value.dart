import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

class SensorSendInconsistentValue extends LeafSpecification {
  int inconsistentThreshold;

  SensorSendInconsistentValue(int threshold) {
    inconsistentThreshold = threshold;
  }

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate >= inconsistentThreshold;
  }

}