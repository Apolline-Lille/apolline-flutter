import 'package:easy_localization/easy_localization.dart';

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
    }
  }
}