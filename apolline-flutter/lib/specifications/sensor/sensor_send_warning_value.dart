import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

/// Specification to manage warning sensor value detection
class SensorSendWarningValue extends LeafSpecification {
  int warningThreshold ;

  SensorSendWarningValue(int warningThreshold) {
    this.warningThreshold = warningThreshold;
  }

  /// Returns `true` if the [candidate] is superior or equal the [warningThreshold].
  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate >= warningThreshold;
  }

}