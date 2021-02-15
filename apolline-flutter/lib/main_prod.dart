import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:apollineflutter/services/service_locator.dart';
import 'package:apollineflutter/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config_prod.json");
  setupServiceLocator();
  runApp(ApollineApp());
}