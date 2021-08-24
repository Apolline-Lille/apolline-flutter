import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import 'bluetoothDevicesPage.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromPath("assets/config_dev.json");
  setupServiceLocator();
  runApp(ApollineApp());
}
// This acts as the landing window of the app.
// Scans and displays Bluetooth devices in range, and allows to connect to them.

class ApollineApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apolline',
      theme: ThemeData(
        primaryColor: Colors.green,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.lightGreen)
      ),
      home: BluetoothDevicesPage(title: 'Apolline - Sensors'),
    );
  }
}
