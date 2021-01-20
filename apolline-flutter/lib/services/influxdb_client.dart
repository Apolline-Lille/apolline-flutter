import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:apollineflutter/exception/bad_request_exception.dart';
import 'package:apollineflutter/exception/lost_connection_exception.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

///Author (Issagha Barry)
///Influx db api.
class InfluxDBAPI {
  ///the address where to save data.
  final String _connectionString = GlobalConfiguration().get("api_url");
  ///the name of database.
  final String _db = GlobalConfiguration().get("dbname");
  ///the user.
  final String _username = GlobalConfiguration().get("username");
  ///the password.
  final String _password = GlobalConfiguration().get("password");
  ///the health url
  final String _pingUrl = GlobalConfiguration().get("ping_url");
  
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
  void write(String data) async {
    client.postSilent("$_connectionString/write?db=$_db&u=$_username&p=$_password", body: data);
  }

  ///
  ///check the address [address].
  void ping() async {
    client.pingSilent("$_pingUrl"); //utilisation de /health car la v2.0 le contient déjà. actu sur v1.8.x
  }

}

///Author(Issagha Barry)
///Influx db private client.
class _InfluxDBClient extends http.BaseClient {
  static const OKSTATUS = [204, 200];
  http.Client _inner;
  
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
      resp = await this.get(url);
      print("server is running"); //TODO supprimé à la fin.
    } on SocketException catch(e) {
      throw LostConnectionException("server is unavailable");
    }
    
    if(!OKSTATUS.contains(resp.statusCode) ) {
      throw LostConnectionException("server is unavailable");
    }
  }

  ///
  ///post.
  void postSilent(url, {Map headers, body, Encoding encoding}) async {
    http.Response resp;
    try{
      resp = await this.post(url, headers: headers, body: body, encoding: encoding);
    } on SocketException catch(e) {
      throw LostConnectionException("server is unavailable ${e.toString()}");
    }
    
    if(!OKSTATUS.contains(resp.statusCode) ) {
      throw BadRequestException("Server not access with status code ${resp.statusCode} and body ${resp.body}");
    }
  }
}