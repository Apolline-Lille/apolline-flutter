import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:apollineflutter/exception/bad_request_exception.dart';
import 'package:apollineflutter/exception/lost_connection_exception.dart';
import 'package:apollineflutter/models/server_endpoint_handler.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';
import 'package:apollineflutter/utils/sensor_events/SensorEventType.dart';
import 'package:http/http.dart' as http;


///Author (Issagha Barry)
///Influx db api.
class InfluxDBAPI {
  ///the address where to save data.
  String _connectionString = ServerEndpointHandler().currentServerEndpoint.apiURL;
  ///the name of database.
  String _db = ServerEndpointHandler().currentServerEndpoint.dbName;
  ///the user.
  String _username = ServerEndpointHandler().currentServerEndpoint.username;
  ///the password.
  String _password = ServerEndpointHandler().currentServerEndpoint.password;
  ///the health url
  String _pingUrl = ServerEndpointHandler().currentServerEndpoint.pingURL;

  static final InfluxDBAPI _instance = InfluxDBAPI._internal();
  _InfluxDBClient client = _InfluxDBClient(http.Client());

  ///
  ///private constructor
  InfluxDBAPI._internal();

  ///
  ///factory
  factory InfluxDBAPI() {
    return _instance;
  }

  ///
  ///write data to influx database
  Future<void> write(String data, {String token = "", required String deviceName}) async {
    bool useTokenAuth = token.isNotEmpty;

    if (!useTokenAuth) {
      // TODO find out why this happens
      print("This should NEVER happen anymore.");
    }

    return useTokenAuth
        ? await client.postSilent("$_connectionString/write?db=$_db", deviceName, body: data, headers: {'Authorization': 'Token $token'}, encoding: Encoding.getByName("utf-8")!)
        : await client.postSilent("$_connectionString/write?db=$_db&u=$_username&p=$_password", deviceName, body: data, headers: {}, encoding: Encoding.getByName("utf-8")!);
  }

  ///
  ///check the address [address].
  Future<void> ping() async {
    return client.pingSilent("$_pingUrl"); //utilisation de /health car la v2.0 le contient déjà. actu sur v1.8.x
  }

  bool changeEndpointConfiguration() {
    _connectionString = ServerEndpointHandler().currentServerEndpoint.apiURL;
    _db = ServerEndpointHandler().currentServerEndpoint.dbName;
    _username = ServerEndpointHandler().currentServerEndpoint.username;
    _password = ServerEndpointHandler().currentServerEndpoint.password;
    _pingUrl = ServerEndpointHandler().currentServerEndpoint.pingURL;
    try {
      this.ping();
    } on LostConnectionException catch (_) {
      return false;
    }
    return true;
  }
}

///Author(Issagha Barry)
///Influx db private client.
class _InfluxDBClient extends http.BaseClient {
  static const OKSTATUS = [204, 200];
  http.Client _inner;
  final UserConfigurationService _ucS = locator<UserConfigurationService>();

  ///
  ///constructor
  _InfluxDBClient(this._inner);

  ///
  ///
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    //request.headers["Authorization"] = "Basic ${CryptoUtils.bytesToBase64(utf8.encode("$_username:$_password"))}";
    //request.headers["Content-Type"] = "application/x-www-form-urlencoded";
    return _inner.send(request);
  }

  ///
  ///ping.
  void pingSilent(String url) async {
    http.Response resp;
    try{
      resp = await this.get(Uri.parse(url));
    } on SocketException catch(_) {
      throw LostConnectionException("server is unavailable");
    }

    if(!OKSTATUS.contains(resp.statusCode) ) {
      throw LostConnectionException("server is unavailable");
    }
  }

  ///
  ///post.
  Future<void> postSilent(url, String deviceName, {required Map<String, String> headers, body, required Encoding encoding}) async {
    http.Response resp;
    try{
      resp = await this.post(Uri.parse(url), headers: headers, body: body, encoding: encoding);
    } on SocketException catch(e) {
      throw LostConnectionException("server is unavailable ${e.toString()}");
    }

    // log event
    _ucS.userConf.addSensorEvent(
        deviceName,
        resp.statusCode == 204
            ? SensorEventType.DataSendingOk
            : SensorEventType.DataSendingFail
    );
    print(resp.body);

    if(!OKSTATUS.contains(resp.statusCode) ) {
      throw BadRequestException("Server not access with status code ${resp.statusCode} and body ${resp.body}");
    }
  }
}