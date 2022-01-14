abstract class Specification {

  bool isSatisfiedBy(dynamic candidate);
  Specification and(Specification specification);
  Specification or(Specification specification);
  Specification not();
}