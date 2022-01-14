import 'package:apollineflutter/specifications/AbstractCompositeSpecification.dart';

abstract class LeafSpecification extends AbstractCompositeSpecification {
  bool isSatisfiedBy(Object candidate);
}