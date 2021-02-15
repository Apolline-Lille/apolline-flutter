import 'package:get_it/get_it.dart';

import 'realtime_data_service.dart';
import 'realtime_data_service_impl.dart';
import 'package:apollineflutter/services/user_configuration_service.dart';


GetIt locator = GetIt.instance;

/// setup locator
setupServiceLocator() {
  locator.registerLazySingleton<RealtimeDataService>(
      () => RealtimeDataServiceImpl());
  
  locator.registerSingleton<UserConfigurationService>(UserConfigurationService(), signalsReady: true);
}
