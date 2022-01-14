import 'package:apollineflutter/specifications/Specification.dart';
import 'package:apollineflutter/specifications/AbstractCompositeSpecification.dart';

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