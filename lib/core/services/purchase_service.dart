import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

/// Purchase callback type
typedef PurchaseCallback = void Function(PurchaseDetails purchaseDetails);

/// Play Store satın alma servisi
/// Karma ve Premium abonelik satın alma işlemlerini yönetir
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<ProductDetails> _subscriptions = [];

  // Product IDs - Play Console'da tanımlanmalı
  // Karma paketleri
  static const String karma10 = 'karma_10';
  static const String karma25 = 'karma_25';
  static const String karma50 = 'karma_50';
  
  // Premium abonelikler
  static const String premiumWeekly = 'premium_weekly';
  static const String premiumMonthly = 'premium_monthly';
  static const String premiumYearly = 'premium_yearly';
  
  // Paketler
  static const String package75 = 'package_75';
  static const String package100 = 'package_100';
  static const String package250 = 'package_250';

  // Purchase callback handlers
  PurchaseCallback? onPurchaseSuccess;
  PurchaseCallback? onPurchaseError;

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  List<ProductDetails> get subscriptions => _subscriptions;

  bool _isInitialized = false;

  /// Initialize purchase service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      if (kDebugMode) {
        print('⚠️ In-App Purchase not available');
      }
      return;
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        if (kDebugMode) {
          print('❌ Purchase stream error: $error');
        }
      },
    );

    _isInitialized = true;
    
    // Load products
    await loadProducts();
  }

  /// Load available products from Play Store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    const Set<String> productIds = {
      karma10,
      karma25,
      karma50,
      package75,
      package100,
      package250,
    };

    const Set<String> subscriptionIds = {
      premiumWeekly,
      premiumMonthly,
      premiumYearly,
    };

    if (kDebugMode) {
     
    }

    final ProductDetailsResponse productResponse = 
        await _inAppPurchase.queryProductDetails(productIds);
    
    final ProductDetailsResponse subscriptionResponse = 
        await _inAppPurchase.queryProductDetails(subscriptionIds);

    if (productResponse.error != null) {
      // Error loading products
    } else {
      _products = productResponse.productDetails;
    }

    if (subscriptionResponse.error != null) {
      // Don't clear existing subscriptions on error, keep what we have
    } else {
      _subscriptions = subscriptionResponse.productDetails;
    }
  }

  /// Purchase a product (karma or package)
  Future<bool> purchaseProduct(String productId) async {
    if (!_isAvailable) {
      throw Exception('Satın alma şu anda kullanılamıyor');
    }

    // Ensure products are loaded
    if (_products.isEmpty) {
      await loadProducts();
    }

    // Check if product exists in loaded products
    if (_products.isEmpty) {
      throw Exception(
        'Ürünler yüklenemedi. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.'
      );
    }

    try {
      final productDetails = _products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw StateError('Product not found in list'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // For consumable products (karma), use buyConsumable
      // For non-consumable products (packages), use buyNonConsumable
      final bool isConsumable = productId.startsWith('karma_');
      
      final bool success = isConsumable
          ? await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam)
          : await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      return success;
    } on StateError {
      // Product not found in loaded list
      final availableIds = _products.map((p) => p.id).join(', ');
      throw Exception(
        'Ürün bulunamadı: $productId\n'
        'Yüklenen ürünler: ${availableIds.isEmpty ? "Hiçbiri" : availableIds}\n'
        'Lütfen Google Play Console\'da ürünün aktif olduğundan ve "Managed product" veya "Unmanaged product" olarak tanımlandığından emin olun.'
      );
    } catch (e) {
      throw Exception('Ürün satın alma hatası: ${e.toString()}');
    }
  }

  /// Purchase a subscription (premium)
  Future<bool> purchaseSubscription(String subscriptionId) async {
    if (!_isAvailable) {
      throw Exception('Satın alma şu anda kullanılamıyor');
    }

    // Ensure products are loaded
    if (_subscriptions.isEmpty) {
      await loadProducts();
    }

    // Check if subscription exists in loaded subscriptions
    if (_subscriptions.isEmpty) {
      throw Exception(
        'Abonelikler yüklenemedi. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.'
      );
    }

    try {
      final subscriptionDetails = _subscriptions.firstWhere(
        (subscription) => subscription.id == subscriptionId,
        orElse: () => throw StateError('Subscription not found in list'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: subscriptionDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } on StateError {
      // Subscription not found in loaded list
      final availableIds = _subscriptions.map((s) => s.id).join(', ');
      throw Exception(
        'Abonelik bulunamadı: $subscriptionId\n'
        'Yüklenen abonelikler: ${availableIds.isEmpty ? "Hiçbiri" : availableIds}\n'
        'Lütfen Google Play Console\'da aboneliğin aktif olduğundan emin olun.'
      );
    } catch (e) {
      throw Exception('Abonelik satın alma hatası: ${e.toString()}');
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Handle error
        _handlePurchaseError(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Handle successful purchase
        _handleSuccessfulPurchase(purchaseDetails);
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) {
    // Call success callback if provided
    if (onPurchaseSuccess != null) {
      onPurchaseSuccess!(purchaseDetails);
    }
  }

  /// Handle purchase error
  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    // Call error callback if provided
    if (onPurchaseError != null) {
      onPurchaseError!(purchaseDetails);
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    await _inAppPurchase.restorePurchases();
    
    if (kDebugMode) {
      print('🔄 Restoring purchases...');
    }
  }

  /// Get product price by ID
  String? getProductPrice(String productId) {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
      );
      return product.price;
    } catch (e) {
      try {
        final subscription = _subscriptions.firstWhere(
          (s) => s.id == productId,
        );
        return subscription.price;
      } catch (e) {
        return null;
      }
    }
  }

  /// Dispose
  void dispose() {
    _subscription.cancel();
  }
}

