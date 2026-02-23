class AdService {
  final String androidAppId;
  final String iosAppId;
  final bool isDebugMode;

  AdService({
    required this.androidAppId,
    required this.iosAppId,
    this.isDebugMode = false,
  });

  bool _hasLoadedRewardedAd = false;

  bool get hasLoadedRewardedAd => _hasLoadedRewardedAd;

  Future<void> createRewardedAd([
    void Function()? onAdLoaded,
    void Function()? onAdFailed,
  ]) async {
    _hasLoadedRewardedAd = true;
    onAdLoaded?.call();
  }

  void showRewardedAd(
    Function rewardCallback,
    Function beforeRewardCallback,
    Function(String message) errorMessageCallback, {
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
  }) {
    rewardCallback();
    onAdDismissed?.call();
  }

  void disposeRewardedAd() {
    _hasLoadedRewardedAd = false;
  }
}
