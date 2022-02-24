import 'package:apollineflutter/specifications/specification.dart';
import 'package:apollineflutter/specifications/abstract_composite_specification.dart';

/// Implements `not` boolean operation for the specification design pattern
class NotSpecification extends AbstractCompositeSpecification {
  Specification specification;

  /// Computes the opposite of : [specification]
  NotSpecification(Specification specification) {
    this.specification = specification;
  }

  /// Returns ![specification.isSatisfiedBy]
  @override
  bool isSatisfiedBy(dynamic candidate) {
    return !this.specification.isSatisfiedBy(candidate);
  }
}
