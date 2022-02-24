import 'package:apollineflutter/specifications/abstract_composite_specification.dart';

/// This class gives methods to implement to defines custom operators
abstract class LeafSpecification extends AbstractCompositeSpecification {
  bool isSatisfiedBy(dynamic candidate);
}