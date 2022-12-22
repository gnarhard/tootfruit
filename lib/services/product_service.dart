import 'dart:async';
import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tootfruit/services/toast_service.dart';

class ProductService {
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  static const String productId = 'all_toot_fruits';

  void init() {
    if (Platform.isIOS) {
      final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
      _purchaseSubscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _purchaseSubscription.cancel();
      }, onError: (err) {
        ToastService.error(message: "Failed to update purchase.", devError: err);
      }) as StreamSubscription<List<PurchaseDetails>>;
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // todo: _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          ToastService.error(
              message: "Failed to purchase product.", devError: purchaseDetails.error.toString());
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {}
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> purchase() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      // The store cannot be reached or accessed.
      ToastService.error(message: "The App Store cannot be reached.");
    }

    final ProductDetails? productDetails = await getProduct();

    if (productDetails == null) {
      ToastService.error(message: "The App Store couldn't find this product.");

      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    // Subscriptions are non-consumable.
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    // From here the purchase flow will be handled by the underlying store.
    // Updates will be delivered to the `InAppPurchase.instance.purchaseStream`.
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
