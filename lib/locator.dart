import 'package:ad_service/ad_service.dart';
import 'package:connectivity_service/connectivity_service.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_service/in_app_purchase_service.dart';
import 'package:navigation_service/navigation_service.dart';
import 'package:toast_service/toast_service.dart';
import 'package:tootfruit/screens/toot_loot_screen.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/audio_service.dart';
import 'package:tootfruit/services/init_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

import 'env.dart';

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
      final toastService = Locator.get<ToastService>();
      toastService.error(message: 'Services already registered.');
      return;
    }

    // Order is important.
    Locator.register(UserService());
    Locator.register(InitService());
    Locator.registerLazy(() => NavigationService());
    Locator.registerLazy(() => ConnectivityService());
    Locator.registerLazy(() => StorageService());
    Locator.register(TootService());
    Locator.registerLazy(() => AdService(
          iosAppId: Env.isProduction
              ? 'ca-app-pub-8425430181155588/2476319674'
              : 'ca-app-pub-3940256099942544/1712485313',
          androidAppId: Env.isProduction
              ? 'ca-app-pub-8425430181155588/7852769432'
              : 'ca-app-pub-3940256099942544/5224354917',
          adRequest: const AdRequest(
            // keywords: <String>['foo', 'bar'],
            // contentUrl: 'http://foo.com/bar.html',
            nonPersonalizedAds: true,
          ),
          beforeRewardCallback: () async {
            final tootService = Locator.get<TootService>();
            await tootService.reward();
          },
          rewardCallback: () async {
            final tootService = Locator.get<TootService>();
            final navService = Locator.get<NavigationService>();
            if (tootService.isRewarded) {
              Future.delayed(const Duration(milliseconds: 500), () {
                navService.current.pushNamed(TootLootScreen.route);
              });
            }
          },
          errorMessageCallback: (String message) {
            final toastService = Locator.get<ToastService>();
            toastService.error(message: message);
          },
        ));
    Locator.registerLazy(() => InAppPurchaseService(
          errorMessageCallback: (String message) {
            final toastService = Locator.get<ToastService>();
            toastService.error(message: message);
          },
          rewardCallback: () async {
            final tootService = Locator.get<TootService>();
            final navService = Locator.get<NavigationService>();
            await tootService.rewardAll();
            tootService.loading$.add(false);
            navService.current.pushNamed(TootScreen.route);
          },
          successMessageCallback: (String message) {
            final toastService = Locator.get<ToastService>();
            toastService.success(message: message);
          },
          cancelCallback: () {
            final tootService = Locator.get<TootService>();
            tootService.loading$.add(false);
          },
          productIds: ['all_toot_fruits'],
        ));
    Locator.register(AudioService());
    _initialized = true;
  }

  static isRegistered<T extends Object>(T instance) {
    return GetIt.I
        .isRegistered<T>(instance: instance, instanceName: instance.toString());
  }
}
