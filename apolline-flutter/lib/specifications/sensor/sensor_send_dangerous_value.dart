import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

/// Specification to manage dangerous sensor value detection
class SensorSendDangerousValue extends LeafSpecification {
  int dangerThreshold ;

  SensorSendDangerousValue(int dangerThreshold) {
    this.dangerThreshold = dangerThreshold;
  }

  /// Returns `true` if the [candidate] is superior or equal the [dangerThreshold].
  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate >= dangerThreshold;
  }
}