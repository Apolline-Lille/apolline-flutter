import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:global_configuration/global_configuration.dart';

import 'bluetoothDevicesPage.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromPath("assets/config_dev.json");
  setupServiceLocator();
  setupBackgroundConfig();
  await setupNotificationService();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'GB'), Locale('fr', 'FR')],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'GB'),
        child: ApollineApp()
    ),
  );
}
// This acts as the landing window of the app.
// Scans and displays Bluetooth devices in range, and allows to connect to them.

class ApollineApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Apolline',
      theme: ThemeData(
        primaryColor: Colors.green,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Colors.lightGreen)
      ),
      home: BluetoothDevicesPage(),
    );
  }
}

void setupBackgroundConfig () async {
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Capteur connecté",
    notificationText: "Apolline est actuellement en train de récupérer des données. ",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(name: 'logo_apolline', defType: 'drawable'),
  );
  FlutterBackground.initialize(androidConfig: androidConfig);
}

Future<void> setupNotificationService () async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('logo_apolline');
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification
  );
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}
Future onDidReceiveLocalNotification (
    int id, String title, String body, String payload
) async {
  debugPrint('notification payload: $payload');
}