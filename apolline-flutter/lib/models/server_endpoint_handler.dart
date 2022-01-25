import 'package:apollineflutter/models/server_model.dart';
import 'package:apollineflutter/services/influxdb_client.dart';
import 'package:global_configuration/global_configuration.dart';

import '../configuration_key_name.dart';

class ServerEndpointHandler {
  static final _instance = ServerEndpointHandler._internal();
  ServerModel currentServerEndpoint;

  ServerEndpointHandler._internal() {

    currentServerEndpoint = ServerModel(
        GlobalConfiguration().get(ApollineConf.API_URL),
        GlobalConfiguration().get(ApollineConf.PING_URL),
        GlobalConfiguration().get(ApollineConf.USERNAME),
        GlobalConfiguration().get(ApollineConf.PASSWORD),
        GlobalConfiguration().get(ApollineConf.DBNAME),
        isDefault: 1
    );
  }

  factory ServerEndpointHandler() {
    return _instance;
  }

  bool changeCurrentServerEndpoint(ServerModel newEndpoint) {
    ServerModel tmp = currentServerEndpoint;
    currentServerEndpoint = newEndpoint;
    if(InfluxDBAPI().changeEndpointConfiguration()) {
      return true;
    } else { // erreur lors du changement d'endpoint
      currentServerEndpoint = tmp;
      InfluxDBAPI().changeEndpointConfiguration();
      return false; // On essaye de retourner sur l'ancien. Si cela échoue, on ne boucle pas. (prévenir utilisateur)
    }
  }

}