import 'package:apollineflutter/exception/server_credentials_exception.dart';
import 'package:apollineflutter/services/sqflite_service.dart';

class ServerModel {
  String apiURL;
  String pingURL;
  String username;
  String password;
  String token;
  String dbName;
  int isDefault;

  ServerModel(this.apiURL, this.pingURL, this.username, this.dbName, {int isDefault = 0, String password, String token}) {
    if(password == null && token == null) {
      throw new ServerCredentialsException("Need to have either token or password");
    } else {
      this.password = password;
      this.token = token;
    }

    this.isDefault = isDefault;
  }

  ServerModel.fromJson(Map<String, dynamic> serverConfig) :
        this(
          serverConfig[SqfLiteService.columnApiUrl],
          serverConfig[SqfLiteService.columnPingUrl],
          serverConfig[SqfLiteService.columnUsername],
          serverConfig[SqfLiteService.columnDBName],
          isDefault : serverConfig[SqfLiteService.columnIsDefault],
          password : serverConfig[SqfLiteService.columnPassword],
          token : serverConfig[SqfLiteService.columnToken]
      );

  Map<String, dynamic> toJson() {
    return {
      SqfLiteService.columnApiUrl: this.apiURL,
      SqfLiteService.columnPingUrl: this.pingURL,
      SqfLiteService.columnUsername: this.username,
      SqfLiteService.columnDBName: this.dbName,
      SqfLiteService.columnIsDefault: this.isDefault,
      SqfLiteService.columnPassword: this.password,
      SqfLiteService.columnToken: this.token
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServerModel &&
            runtimeType == other.runtimeType &&
            apiURL == other.apiURL &&
            pingURL == other.pingURL &&
            username == other.username &&
            password == other.password &&
            token == other.token &&
            dbName == other.dbName;
  }

  @override
  int get hashCode {
    return apiURL.hashCode ^ pingURL.hashCode ^ username.hashCode ^ password.hashCode ^ dbName.hashCode;
  }
}