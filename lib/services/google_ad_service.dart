import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/screens/toot_loot_screen.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toast_service.dart';
import 'package:tootfruit/services/toot_service.dart';

import '../env.dart';

class GoogleAdService {
  late final _navService = Locator.get<NavigationService>();
  late final _tootService = Locator.get<TootService>();

  String get iosRewardedTest => Env.isProduction
      ? 'ca-app-pub-8425430181155588/2476319674'
      : 'ca-app-pub-3940256099942544/1712485313';
  String get androidRewardedTest => Env.isProduction
      ? 'ca-app-pub-8425430181155588/7852769432'
      : 'ca-app-pub-3940256099942544/5224354917';

  static const AdRequest request = AdRequest(
    // keywords: <String>['foo', 'bar'],
    // contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  static const int _maxFailedLoadAttempts = 3;

  Future<void> createRewardedAd() async {
    await RewardedAd.load(
        adUnitId: Platform.isAndroid ? androidRewardedTest : iosRewardedTest,
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            if (kDebugMode) {
              print('$ad loaded.');
            }
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('RewardedAd failed to load: $error');
            }
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < _maxFailedLoadAttempts) {
              createRewardedAd();
            }
          },
        ));
  }

  void showRewardedAd() {
    if (_rewardedAd == null) {
      ToastService.error(message: "Attempted to show ad before loading completed.");
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        if (kDebugMode) {
          print('ad onAdShowedFullScreenContent.');
        }
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        if (kDebugMode) {
          print('$ad onAdDismissedFullScreenContent.');
        }
        ad.dispose();
        createRewardedAd();
        if (_tootService.isRewarded) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _navService.current.pushNamed(TootLootScreen.route);
          });
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        if (kDebugMode) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
        }
        ad.dispose();
        createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
      if (kDebugMode) {
        print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      }
      await _tootService.reward();
    });
    _rewardedAd = null;
  }
}
