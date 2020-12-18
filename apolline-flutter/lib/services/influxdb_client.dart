import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

///
///
class InfluxDBAPI {
  final String _connectionString = GlobalConfiguration().get("api_url");
  final String _db = GlobalConfiguration().get("dbname");
  final String _username = GlobalConfiguration().get("username");
  final String _password = GlobalConfiguration().get("password");
  
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
  write(String data) async {
    client.postSilent("$_connectionString/write?db=$_db&u=$_username&p=$_password", body: data);
  }

}

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
  ///
  postSilent(url, {Map headers, body, Encoding encoding}) async {
    http.Response resp;
    try{
      resp = await this.post(url, headers: headers, body: body, encoding: encoding);
    } on SocketException catch(e) {
      throw Exception("server is unavailable ${e.message}");
    }
    
    if(!OKSTATUS.contains(resp.statusCode) ) {
      throw Exception("Server not access with status code ${resp.statusCode} and body ${resp.body}");
    }
  }
}