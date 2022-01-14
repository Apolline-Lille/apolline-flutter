import 'package:apollineflutter/specifications/abstract_composite_specification.dart';

abstract class LeafSpecification extends AbstractCompositeSpecification {
  bool isSatisfiedBy(dynamic candidate);
}