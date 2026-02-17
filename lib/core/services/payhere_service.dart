import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

/// PayHere SDK wrapper for top-up and subscription payments.
///
/// Uses `payhere_mobilesdk_flutter` package.
/// For development, use sandbox mode. Switch to live for production.
class PayHereService {
  static const _sandboxMerchantId = ''; // Set in .env
  static const _liveMerchantId = '';     // Set in .env

  static String get merchantId =>
      kDebugMode ? _sandboxMerchantId : _liveMerchantId;

  static bool get isSandbox => kDebugMode;

  /// Generate order ID for top-up.
  static String topUpOrderId(String userId, String packageId) {
    return 'waddek_topup_${userId}_${packageId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate order ID for subscription.
  static String subscriptionOrderId(String userId) {
    return 'waddek_sub_${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Build PayHere payment object for one-time top-up.
  ///
  /// Usage with payhere_mobilesdk_flutter:
  /// ```dart
  /// final payment = PayHereService.buildTopUpPayment(
  ///   userId: profile.id,
  ///   packageId: package.id,
  ///   amount: package.amount,
  ///   itemName: package.label,
  ///   customerName: profile.fullName ?? '',
  ///   customerPhone: profile.phone,
  /// );
  /// PayHere.startPayment(payment, onCompleted: ..., onError: ...);
  /// ```
  static Map<String, dynamic> buildTopUpPayment({
    required String userId,
    required String packageId,
    required double amount,
    required String itemName,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
  }) {
    return {
      'sandbox': isSandbox,
      'merchant_id': merchantId,
      'merchant_secret': '', // Only needed server-side, not in client
      'notify_url':
          '${AppConstants.supabaseUrl}/functions/v1/payhere-notify',
      'order_id': topUpOrderId(userId, packageId),
      'items': 'Waddek Wallet Top-Up - $itemName',
      'amount': amount,
      'currency': 'LKR',
      'first_name': customerName.split(' ').first,
      'last_name': customerName.split(' ').length > 1
          ? customerName.split(' ').last
          : '',
      'email': customerEmail ?? '',
      'phone': customerPhone,
      'address': '',
      'city': '',
      'country': 'Sri Lanka',
    };
  }

  /// Build PayHere recurring payment object for Pro Pass subscription.
  static Map<String, dynamic> buildSubscriptionPayment({
    required String userId,
    required double amount,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
  }) {
    return {
      'sandbox': isSandbox,
      'merchant_id': merchantId,
      'merchant_secret': '',
      'notify_url':
          '${AppConstants.supabaseUrl}/functions/v1/manage-subscription',
      'order_id': subscriptionOrderId(userId),
      'items': 'Waddek Pro Pass - Monthly',
      'amount': amount,
      'currency': 'LKR',
      'first_name': customerName.split(' ').first,
      'last_name': customerName.split(' ').length > 1
          ? customerName.split(' ').last
          : '',
      'email': customerEmail ?? '',
      'phone': customerPhone,
      'address': '',
      'city': '',
      'country': 'Sri Lanka',
      'recurrence': '1 Month',
      'duration': 'Forever',
    };
  }
}
