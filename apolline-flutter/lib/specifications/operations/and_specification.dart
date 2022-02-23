import 'package:apollineflutter/specifications/specification.dart';
import 'package:apollineflutter/specifications/abstract_composite_specification.dart';

/// Implements `and` boolean operation for the specification design pattern
class AndSpecification extends AbstractCompositeSpecification {
  Specification leftSpecification;
  Specification rightSpecification;

  /// Computes the operation : [leftSpecification] `and` [rightSpecification]
  AndSpecification(Specification leftSpecification, Specification rightSpecification) {
    this.leftSpecification = leftSpecification;
    this.rightSpecification = rightSpecification;
  }

  /// Returns the result of the `and` operator between [leftSpecification] `and` [rightSpecification] by calling [leftSpecification.isSatisfiedBy] and [rightSpecification.isSatisfiedBy] methods.
  @override
  isSatisfiedBy(dynamic candidate) {
    return this.leftSpecification.isSatisfiedBy(candidate) && this.rightSpecification.isSatisfiedBy(candidate);
  }

}