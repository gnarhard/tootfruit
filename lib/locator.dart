import 'package:get_it/get_it.dart';
import 'package:tooty_fruity/services/audio_service.dart';
import 'package:tooty_fruity/services/connectivity_service.dart';
import 'package:tooty_fruity/services/init_service.dart';
import 'package:tooty_fruity/services/navigation_service.dart';
import 'package:tooty_fruity/services/storage_service.dart';
import 'package:tooty_fruity/services/theme_service.dart';
import 'package:tooty_fruity/services/toast_service.dart';
import 'package:tooty_fruity/services/toot_service.dart';
import 'package:tooty_fruity/services/user_service.dart';

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
    Locator.registerLazy(() => ThemeService());
    Locator.register(TootService());
    Locator.register(AudioService());
    _initialized = true;
  }

  static isRegistered<T extends Object>(T instance) {
    return GetIt.I.isRegistered<T>(instance: instance, instanceName: instance.toString());
  }
}
