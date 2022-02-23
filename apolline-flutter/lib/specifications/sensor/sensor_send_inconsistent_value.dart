import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

/// Specification to manage inconsistent sensor value detection
class SensorSendInconsistentValue extends LeafSpecification {
  int inconsistentThreshold;

  SensorSendInconsistentValue(int threshold) {
    inconsistentThreshold = threshold;
  }

  /// Returns `true` if the [candidate] is superior or equal the [inconsistentThreshold].
  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate >= inconsistentThreshold;
  }

}