import 'package:apollineflutter/specifications/abstract_composite_specification.dart';
import 'package:apollineflutter/specifications/specification.dart';

/// Computes the operation : [leftSpecification] `or` [rightSpecification]
class OrSpecification extends AbstractCompositeSpecification {
  Specification leftSpecification;
  Specification rightSpecification;

  /// Computes the operation : [leftSpecification] or [rightSpecification]
  OrSpecification(Specification leftSpecification, Specification rightSpecification) {
    this.leftSpecification = leftSpecification;
    this.rightSpecification = rightSpecification;
  }

  /// Returns the result of the `or` operator between [leftSpecification] `or` [rightSpecification] by calling [leftSpecification.isSatisfiedBy] and [rightSpecification.isSatisfiedBy] methods.
  @override
  bool isSatisfiedBy(dynamic candidate) {
    return this.leftSpecification.isSatisfiedBy(candidate) || this.rightSpecification.isSatisfiedBy(candidate);
  }
}
