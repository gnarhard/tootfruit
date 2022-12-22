import 'package:get_it/get_it.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/connectivity_service.dart';
import 'package:tootfruit/services/google_ad_service.dart';
import 'package:tootfruit/services/in_app_purchase_service.dart';
import 'package:tootfruit/services/init_service.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toast_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

typedef LocatorFactory<T> = T Function();

class Locator {
  static bool _initialized = false;
  Locator._();

  static void register<T extends Object>(T instance) {
    GetIt.I.registerSingleton<T>(instance);
  }

  static void registerLazy<T extends Object>(LocatorFactory<T> factory) {
    GetIt.I.registerLazySingleton<T>(factory);
  }

  static T get<T extends Object>() {
    return GetIt.I.get<T>();
  }

  static void registerAll() {
    if (_initialized) {
      ToastService.error(message: 'Services already registered.');
      return;
    }

    // Order is important.
    Locator.register(UserService());
    Locator.register(InitService());
    Locator.registerLazy(() => NavigationService());
    Locator.registerLazy(() => ConnectivityService());
    Locator.registerLazy(() => StorageService());
    Locator.registerLazy(() => GoogleAdService());
    Locator.registerLazy(() => InAppPurchaseService());
    Locator.register(TootService());
    Locator.register(AudioService());
    _initialized = true;
  }

  static isRegistered<T extends Object>(T instance) {
    return GetIt.I.isRegistered<T>(instance: instance, instanceName: instance.toString());
  }
}
