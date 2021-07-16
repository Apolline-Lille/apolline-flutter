import 'dart:io';

Future<void> main() async {
  final filename = 'apolline-flutter/assets/cfg/config_dev.json';
  File(filename).writeAsString(
      """{
    "api_url": "${Platform.environment['APOLLINE_API_URL']}",
    "ping_url": "${Platform.environment['APOLLINE_API_URL']}/health",
    "password": "${Platform.environment['APOLLINE_PASSWORD']}",
    "username": "${Platform.environment['APOLLINE_USERNAME']}",
    "dbname": "${Platform.environment['APOLLINE_DBNAME']}",
    "minPmValues": [1, 2, 3, 4, 5, 6, 7, 8, 9],
    "maxPmValues": [9, 10, 11, 12, 13, 14, 15, 16, 17]
}"""
  );
}