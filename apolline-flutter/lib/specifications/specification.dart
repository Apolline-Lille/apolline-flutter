/// Interface that represents the entry point of the specification design pattern.
///
/// Specification design pattern allows to simplify the management of business rules of this app.
/// That defines boolean actions : and, or, not. And a method to executes this actions : isSatisfiedBy
abstract class Specification {

  /// Return true if the specification is satisfied by the candidate.
  bool isSatisfiedBy(dynamic candidate);

  /// Defines the "and" operation behaviour.
  Specification and(Specification specification);

  /// Defines the "or" operation behaviour.
  Specification or(Specification specification);

  /// Defines the "not" operation behaviour.
  Specification not();
}