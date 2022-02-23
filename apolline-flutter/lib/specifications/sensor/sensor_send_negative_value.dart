import 'package:apollineflutter/specifications/operations/leaf_specification.dart';

/// Specification to manage negative sensor value detection
class SensorSendNegativeValue extends LeafSpecification {

  /// Returns `true` if the [candidate] is inferior at 0.
  @override
  bool isSatisfiedBy(dynamic candidate) {
    return candidate < 0;
  }
  
}