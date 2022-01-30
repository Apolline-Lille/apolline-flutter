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
        GlobalConfiguration().get(ApollineConf.PASSWORD),
        GlobalConfiguration().get(ApollineConf.DBNAME)
    ); // Récupération de la config du fichier config_dev.json

    ServerModel defaultConfig = await SqfLiteService().getDefaultEndpoint(); // Si une configuration par defaut à déjà été enregistré, on la met sinon on met la config du fichier config_dev.json
    if(defaultConfig == null) {
      mainConfig.isDefault = 1;
      currentServerEndpoint = mainConfig;
    } else {
      currentServerEndpoint = defaultConfig;
    }

    SqfLiteService().addServerEndpoint(mainConfig); // met à jour la config du ficher config_dev.json ou l'ajoute dans la bdd si premier lancement de l'appli
    InfluxDBAPI().changeEndpointConfiguration();
  }

  bool changeCurrentServerEndpoint(ServerModel newEndpoint) {
    //ServerModel tmp = currentServerEndpoint;
    currentServerEndpoint = newEndpoint;
    if(InfluxDBAPI().changeEndpointConfiguration()) {
      SqfLiteService().setDefaultEndpoint(newEndpoint);
      return true;
    } //else { // erreur lors du changement d'endpoint
    //   currentServerEndpoint = tmp;
    //   InfluxDBAPI().changeEndpointConfiguration();
    //   return false; // On essaye de retourner sur l'ancien. Si cela échoue, on ne boucle pas. (prévenir utilisateur)
    // }
    SqfLiteService().setDefaultEndpoint(newEndpoint);

    return true;
  }

}