import 'package:apollineflutter/specifications/specification.dart';
import 'package:apollineflutter/specifications/operations/and_specification.dart';
import 'package:apollineflutter/specifications/operations/not_specification.dart';
import 'package:apollineflutter/specifications/operations/or_specification.dart';

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