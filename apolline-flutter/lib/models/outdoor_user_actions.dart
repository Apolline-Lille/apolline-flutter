import 'package:easy_localization/easy_localization.dart';

/// Enum that represents outdoors user actions
/// TODO complete with the Jérôme's list (see meeting of 21/01/2022)
enum OutdoorUserAction {
  Subway,
  TrafficJam
}

extension OutdoorUserActionExtenion on OutdoorUserAction {
  String get name {
    switch(this) {
      case OutdoorUserAction.Subway:
        return "userActions.outdoor.subway".tr();
      case OutdoorUserAction.TrafficJam:
        return "userActions.outdoor.trafficJam".tr();
      default:
        return "userActions.outdoor.subway".tr();
    }
  }
}