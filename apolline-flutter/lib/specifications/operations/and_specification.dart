import 'package:apollineflutter/specifications/specification.dart';
import 'package:apollineflutter/specifications/abstract_composite_specification.dart';

class AndSpecification extends AbstractCompositeSpecification {
  Specification leftSpecification;
  Specification rightSpecification;

  AndSpecification(Specification leftSpecification, Specification rightSpecification) {
    this.leftSpecification = leftSpecification;
    this.rightSpecification = rightSpecification;
  }

  @override
  isSatisfiedBy(dynamic candidate) {
    return this.leftSpecification.isSatisfiedBy(candidate) && this.rightSpecification.isSatisfiedBy(candidate);
  }

}