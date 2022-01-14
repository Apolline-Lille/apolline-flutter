import 'package:apollineflutter/specifications/AbstractCompositeSpecification.dart';
import 'package:apollineflutter/specifications/Specification.dart';

class OrSpecification extends AbstractCompositeSpecification {
  Specification leftSpecification;
  Specification rightSpecification;

  OrSpecification(Specification leftSpecification, Specification rightSpecification) {
    this.leftSpecification = leftSpecification;
    this.rightSpecification = rightSpecification;
  }

  @override
  bool isSatisfiedBy(candidate) {
    return this.leftSpecification.isSatisfiedBy(candidate) || this.rightSpecification.isSatisfiedBy(candidate);
  }
}
