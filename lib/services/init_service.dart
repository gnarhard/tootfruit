import 'dart:io';

import 'package:ad_service/ad_service.dart';
import 'package:connectivity_service/connectivity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_service/in_app_purchase_service.dart';
import 'package:tootfruit/services/storage_service.dart';
import 'package:tootfruit/services/toot_service.dart';
import 'package:tootfruit/services/user_service.dart';

import '../locator.dart';
import '../screens/toot_screen.dart';
import 'navigation_service.dart';

class InitService {
  late final _navService = Locator.get<NavigationService>();
  late final _tootService = Locator.get<TootService>();
  late final _userService = Locator.get<UserService>();
  late final _storageService = Locator.get<StorageService>();
  late final _adService = Locator.get<AdService>();
  late final _connectivityService = Locator.get<ConnectivityService>();
  late final _inAppPurchaseService = Locator.get<InAppPurchaseService>();

  bool isSmallScreen = false;

  Future<void> init() async {
    if (kDebugMode) {
      await _storageService.deleteStorageFile();
    }
    _connectivityService.init();
    await _userService.init();
    await _tootService.init();

    if (Platform.isIOS || Platform.isAndroid) {
      MobileAds.instance.initialize();
      MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
        maxAdContentRating: MaxAdContentRating.g,
      ));

      await _adService.createRewardedAd();
      _inAppPurchaseService.init();
    }

    _navService.current.pushNamed(TootScreen.route);
    // if (kDebugMode) {
    //   _navService.current.pushNamed(TootFairyScreen.route);
    // }
  }
}
