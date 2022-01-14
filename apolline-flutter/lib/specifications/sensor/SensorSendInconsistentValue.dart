import 'package:apollineflutter/specifications/operations/LeafSpecification.dart';

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