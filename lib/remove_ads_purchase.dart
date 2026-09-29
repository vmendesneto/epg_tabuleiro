import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const removeAdsProductId = 'remove_ads';

abstract class RemoveAdsPurchaseController extends ChangeNotifier {
  String? get price;
  bool get isLoading;
  bool get isPurchased;
  bool get canBuy;
  String? get errorMessage;

  Future<void> initialize();
  Future<void> buy();
}

class PlayRemoveAdsPurchaseController extends RemoveAdsPurchaseController {
  PlayRemoveAdsPurchaseController({InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _product;
  bool _initialized = false;
  bool _isLoading = true;
  bool _isPurchased = false;
  bool _purchasePending = false;
  String? _errorMessage;

  @override
  String? get price => _product?.price;

  @override
  bool get isLoading => _isLoading || _purchasePending;

  @override
  bool get isPurchased => _isPurchased;

  @override
  bool get canBuy =>
      _product != null && !_isLoading && !_purchasePending && !_isPurchased;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _subscription = _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _purchasePending = false;
        _errorMessage = 'Não foi possível concluir a compra.';
        notifyListeners();
      },
    );

    try {
      final available = await _store.isAvailable();
      if (!available) {
        _errorMessage = 'A Play Store não está disponível.';
        return;
      }

      final response = await _store.queryProductDetails({removeAdsProductId});
      if (response.error != null || response.productDetails.isEmpty) {
        _errorMessage = 'Preço indisponível na Play Store.';
        return;
      }

      _product = response.productDetails.firstWhere(
        (product) => product.id == removeAdsProductId,
      );
      await _store.restorePurchases();
    } catch (_) {
      _errorMessage = 'Não foi possível consultar a Play Store.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> buy() async {
    final product = _product;
    if (product == null || !canBuy) return;

    _purchasePending = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final started = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        _purchasePending = false;
        _errorMessage = 'A compra não foi iniciada.';
        notifyListeners();
      }
    } catch (_) {
      _purchasePending = false;
      _errorMessage = 'Não foi possível abrir a compra.';
      notifyListeners();
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      if (purchase.productID != removeAdsProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // A validação em servidor pode ser adicionada antes da entrega para
          // proteger a compra contra adulterações fora da Play Store.
          _isPurchased = true;
          _purchasePending = false;
          _errorMessage = null;
          break;
        case PurchaseStatus.error:
          _purchasePending = false;
          _errorMessage = 'A compra não foi concluída.';
          break;
        case PurchaseStatus.canceled:
          _purchasePending = false;
          break;
      }

      if (purchase.pendingCompletePurchase &&
          purchase.status != PurchaseStatus.pending) {
        await _store.completePurchase(purchase);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    final subscription = _subscription;
    if (subscription != null) unawaited(subscription.cancel());
    super.dispose();
  }
}
