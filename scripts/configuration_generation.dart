import 'dart:io';

Future<void> main() async {
  final filename = 'apolline-flutter/assets/cfg/config_dev.json';
  File(filename).writeAsString(
      """{
    "api_url": "http://192.168.0.33",
    "ping_url": "http://192.168.0.33/health",
    "password": "apollineapp",
    "username": "apollineapp",
    "dbname": "apolline",
    "minPmValues": [1, 2, 3, 4, 5, 6, 7, 8, 9],
    "maxPmValues": [9, 10, 11, 12, 13, 14, 15, 16, 17]
}"""
  );
}