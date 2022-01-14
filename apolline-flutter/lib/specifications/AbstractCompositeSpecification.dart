import 'package:apollineflutter/specifications/Specification.dart';
import 'package:apollineflutter/specifications/operations/AndSpecification.dart';
import 'package:apollineflutter/specifications/operations/NotSpecification.dart';
import 'package:apollineflutter/specifications/operations/OrSpecification.dart';

abstract class AbstractCompositeSpecification implements Specification {
  Specification and(Specification specification) {
    return AndSpecification(this, specification);
  }

  Specification or(Specification specification) {
    return OrSpecification(this, specification);
  }

  Specification not() {
    return NotSpecification(this);
  }

  bool isSatisfiedBy(dynamic candidate);
}