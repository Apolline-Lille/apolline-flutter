import 'package:apollineflutter/specifications/Specification.dart';
import 'package:apollineflutter/specifications/AbstractCompositeSpecification.dart';

class NotSpecification extends AbstractCompositeSpecification {
  Specification specification;

  NotSpecification(Specification specification) {
    this.specification = specification;
  }

  @override
  bool isSatisfiedBy(candidate) {
    return !this.specification.isSatisfiedBy(candidate);
  }
}
