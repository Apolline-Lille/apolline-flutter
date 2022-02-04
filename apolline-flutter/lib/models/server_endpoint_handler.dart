import 'package:apollineflutter/models/server_model.dart';
import 'package:apollineflutter/services/influxdb_client.dart';
import 'package:apollineflutter/services/sqflite_service.dart';
import 'package:global_configuration/global_configuration.dart';

import '../configuration_key_name.dart';

class ServerEndpointHandler {
  static final _instance = ServerEndpointHandler._internal();
  ServerModel currentServerEndpoint;

  ServerEndpointHandler._internal();

  factory ServerEndpointHandler() {
    return _instance;
  }

  setDefaultConfig() async {
    ServerModel mainConfig = ServerModel(
        GlobalConfiguration().get(ApollineConf.API_URL),
        GlobalConfiguration().get(ApollineConf.PING_URL),
        GlobalConfiguration().get(ApollineConf.USERNAME),
        GlobalConfiguration().get(ApollineConf.DBNAME),
        password: GlobalConfiguration().get(ApollineConf.PASSWORD),
        token: null
    ); // Retrieving config of config_dev.json file

    ServerModel defaultConfig = await SqfLiteService().getDefaultEndpoint(); // If any default config has been saved, she become current config. Else, setting current config as mainConfig
    if(defaultConfig == null) {
      mainConfig.isDefault = 1;
      currentServerEndpoint = mainConfig;
    } else {
      currentServerEndpoint = defaultConfig;
    }

    SqfLiteService().addServerEndpoint(mainConfig); // Updates the main config or add it in local database (first opening app)
    InfluxDBAPI().changeEndpointConfiguration();
  }

  bool changeCurrentServerEndpoint(ServerModel newEndpoint) {
    //ServerModel tmp = currentServerEndpoint;
    currentServerEndpoint = newEndpoint;
    if(InfluxDBAPI().changeEndpointConfiguration()) {
      SqfLiteService().setDefaultEndpoint(newEndpoint);
      return true;
    } //else { // change endpoint error
    //   currentServerEndpoint = tmp;
    //   InfluxDBAPI().changeEndpointConfiguration();
    //   return false; // Trying to return to the last config
    // }
    SqfLiteService().setDefaultEndpoint(newEndpoint);

    return true;
  }

}