import 'package:easy_localization/easy_localization.dart';

enum IndoorUserAction {
  Kitchen,
  Aspirator
}

extension IndoorUserActionExtenion on IndoorUserAction {
  String get name {
    switch(this) {
      case IndoorUserAction.Kitchen:
        return "userActions.indoor.kitchen".tr();
      case IndoorUserAction.Aspirator:
        return "userActions.indoor.aspirator".tr();
      default:
        return "userActions.indoor.kitchen".tr();
    }
  }
}