import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tootfruit/locator.dart';
import 'package:tootfruit/screens/toot_screen.dart';
import 'package:tootfruit/services/navigation_service.dart';
import 'package:tootfruit/services/toast_service.dart';
import 'package:tootfruit/services/toot_service.dart';

class InAppPurchaseService {
  late final _tootService = Locator.get<TootService>();
  late final _navService = Locator.get<NavigationService>();

  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  static const String productId = 'all_toot_fruits';

  void init() {
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;

    _purchaseSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _purchaseSubscription.cancel();
      _tootService.loading$.add(false);
    }, onError: (err) {
      ToastService.error(message: "Failed to update purchase.", devError: err);
      _tootService.loading$.add(false);
    }) as StreamSubscription<List<PurchaseDetails>>;
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        ToastService.error(
            message: "Failed to purchase product.", devError: purchaseDetails.error.toString());
        _tootService.loading$.add(false);
        return;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        _tootService.loading$.add(false);
      }

      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }

        await _tootService.rewardAll();
        _tootService.loading$.add(false);
        _navService.current.pushNamed(TootScreen.route);
      }
    }
  }

  Future<void> purchase(String type) async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed.
      ToastService.error(message: "The App Store cannot be reached.");
      _tootService.loading$.add(false);
    }

    final ProductDetails? productDetails = await getProduct();

    if (productDetails == null) {
      ToastService.error(message: "The App Store couldn't find this product.");
      _tootService.loading$.add(false);
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    if (type == 'consumable') {
      InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    } else if (type == 'nonconsumable') {
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restore() async {
    await InAppPurchase.instance.restorePurchases();
    ToastService.success(message: "Purchases restored.");
  }

  Future<ProductDetails?> getProduct() async {
    final Set<String> kIds = <String>{productId};

    final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(kIds);

    if (response.notFoundIDs.isNotEmpty) {
      ToastService.error(message: "Can't find selected product in App Store.");
    }
    List<ProductDetails> products = response.productDetails;

    if (products.isNotEmpty) {
      return products.first;
    }

    return null;
  }
}
