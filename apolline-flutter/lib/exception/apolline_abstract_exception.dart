

///Author (Issagha BARRY)
///Abstract class Exception.
abstract class ApollineAbstractException implements Exception {
  ///Error message.
  String msg;

  ///
  ///Constructor.
  ///[this.msg] the error message
  ApollineAbstractException(this.msg);

  ///
  ///return the error message.
  String errorMsg() {
    return this.msg;
  }
}