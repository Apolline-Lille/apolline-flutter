import 'package:apollineflutter/exception/apolline_abstract_exception.dart';


///Author (Issagha BARRY)
///Lost connection exception.
class LostConnectionException extends ApollineAbstractException {

  ///
  ///Constructor.
  ///[this.msg] the error message
  LostConnectionException(String msg): super(msg);

}