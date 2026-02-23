class InAppPurchaseService {
  bool _isInitialized = false;

  final List<String> productIds;
  final Function errorMessageCallback;
  final Function rewardCallback;
  final Function successMessageCallback;
  final Function cancelCallback;

  InAppPurchaseService({
    required this.productIds,
    required this.errorMessageCallback,
    required this.rewardCallback,
    required this.successMessageCallback,
    required this.cancelCallback,
  });

  void init() {
    _isInitialized = true;
  }

  Future<void> purchase(String type) async {
    if (!_isInitialized) {
      init();
    }
    await rewardCallback();
    cancelCallback();
  }

  Future<void> restore() async {
    successMessageCallback('All fruits are already unlocked.');
  }
}
