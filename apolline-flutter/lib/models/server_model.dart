import 'package:apollineflutter/services/sqflite_service.dart';

class ServerModel {
  String apiURL;
  String pingURL;
  String username;
  String _password;
  String dbName;
  int isDefault; // 0 false | 1 true

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  ServerModel(this.apiURL, this.pingURL, this.username, String password, this.dbName, {int isDefault = 0}) {
    this.password = password;
    this.isDefault = isDefault;
  }

  ServerModel.fromJson(Map<String, dynamic> serverConfig) :
        this(
          serverConfig[SqfLiteService.columnApiUrl],
          serverConfig[SqfLiteService.columnPingUrl],
          serverConfig[SqfLiteService.columnUsername],
          serverConfig[SqfLiteService.columnPassword],
          serverConfig[SqfLiteService.columnDBName],
          isDefault : serverConfig[SqfLiteService.columnIsDefault]
      );

  Map<String, dynamic> toJson() {
    return {
      SqfLiteService.columnApiUrl: this.apiURL,
      SqfLiteService.columnPingUrl: this.pingURL,
      SqfLiteService.columnUsername: this.username,
      SqfLiteService.columnPassword: this.password,
      SqfLiteService.columnDBName: this.dbName,
      SqfLiteService.columnIsDefault: this.isDefault
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
            dbName == other.dbName;
  }

  @override
  int get hashCode {
    return apiURL.hashCode ^ pingURL.hashCode ^ username.hashCode ^ password.hashCode ^ dbName.hashCode;
  }
}