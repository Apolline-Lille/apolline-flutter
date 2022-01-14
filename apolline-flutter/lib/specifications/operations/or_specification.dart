import 'package:apollineflutter/specifications/abstract_composite_specification.dart';
import 'package:apollineflutter/specifications/specification.dart';

class OrSpecification extends AbstractCompositeSpecification {
  Specification leftSpecification;
  Specification rightSpecification;

  OrSpecification(Specification leftSpecification, Specification rightSpecification) {
    this.leftSpecification = leftSpecification;
    this.rightSpecification = rightSpecification;
  }

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return this.leftSpecification.isSatisfiedBy(candidate) || this.rightSpecification.isSatisfiedBy(candidate);
  }
}
