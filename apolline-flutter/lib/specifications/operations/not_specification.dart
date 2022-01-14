import 'package:apollineflutter/specifications/specification.dart';
import 'package:apollineflutter/specifications/abstract_composite_specification.dart';

class NotSpecification extends AbstractCompositeSpecification {
  Specification specification;

  NotSpecification(Specification specification) {
    this.specification = specification;
  }

  @override
  bool isSatisfiedBy(dynamic candidate) {
    return !this.specification.isSatisfiedBy(candidate);
  }
}
