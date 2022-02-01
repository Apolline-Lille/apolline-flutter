import 'package:apollineflutter/exception/apolline_abstract_exception.dart';


///Author (Issagha BARRY)
///bad request exception.
class BadRequestException extends ApollineAbstractException {

  ///
  ///Constructor.
  ///[this.msg] the error message
  BadRequestException(String msg): super(msg);

}