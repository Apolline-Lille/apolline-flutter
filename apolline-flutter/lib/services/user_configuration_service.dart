import 'package:apollineflutter/models/user_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:apollineflutter/services/local_persistant_service.dart';
import 'package:apollineflutter/services/service_locator.dart';

///Author (Issagha BARRY)
///
class UserConfigurationService extends ChangeNotifier{
  static const USER_CONF_KEY = "userconf";
  //user configuration
  UserConfiguration userConf;
  //help to know if data is load from local storage
  bool isReady = false;

  ///
  ///constructor load data et signal data is ready.
  UserConfigurationService() {

    //load data from localStorage.
    LocalKeyValuePersistance.getObject(UserConfigurationService.USER_CONF_KEY).then((json) {
      this.isReady = true;
      this.userConf = json == null ? UserConfiguration() : UserConfiguration.fromJson(json);
      locator.signalReady(this);
    });
  }

  ///
  ///notify all listener user configuration is update
  void update() {
    this.notifyListeners();
  }
}