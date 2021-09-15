import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:global_configuration/global_configuration.dart';

import 'bluetoothDevicesPage.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromPath("assets/config_dev.json");
  setupServiceLocator();
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
  final Color mainColor = Color.fromRGBO(47, 56, 92, 1);
  final Color secondaryColor = Color.fromRGBO(123, 137, 191, 1);
  final Color tertiaryColor = Color.fromRGBO(181, 187, 217, 1);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Apolline',
      theme: ThemeData(
        primaryColor: mainColor,
        backgroundColor: mainColor,
        appBarTheme: AppBarTheme(backgroundColor: mainColor),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: secondaryColor),
        toggleableActiveColor: tertiaryColor
      ),
      home: BluetoothDevicesPage(),
    );
  }
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