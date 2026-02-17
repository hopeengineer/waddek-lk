import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/wallet_model.dart';

/// Data layer for wallet and transaction operations.
class WalletRepository {
  final _client = SupabaseService.client;

  /// Fetch current user's wallet.
  Future<WalletModel?> getWallet(String userId) async {
    final data = await _client
        .from(SupabaseConstants.wallets)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return WalletModel.fromJson(data);
  }

  /// Stream wallet balance in realtime.
  Stream<WalletModel?> streamWallet(String userId) {
    return _client
        .from(SupabaseConstants.wallets)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) {
      if (rows.isEmpty) return null;
      return WalletModel.fromJson(rows.first);
    });
  }

  /// Fetch transaction history.
  Future<List<TransactionModel>> getTransactions(String walletId,
      {int limit = 50}) async {
    final data = await _client
        .from(SupabaseConstants.transactions)
        .select()
        .eq('wallet_id', walletId)
        .order('created_at', ascending: false)
        .limit(limit);
    return data
        .map<TransactionModel>((t) => TransactionModel.fromJson(t))
        .toList();
  }

  /// Fetch available top-up packages.
  Future<List<TopUpPackage>> getTopUpPackages() async {
    final data = await _client
        .from(SupabaseConstants.topUpPackages)
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return data
        .map<TopUpPackage>((p) => TopUpPackage.fromJson(p))
        .toList();
  }

  /// Call unlock-details Edge Function.
  Future<Map<String, dynamic>> unlockDetails({
    required String jobId,
    required String bidId,
    required String workerId,
  }) async {
    final response = await _client.functions.invoke(
      'unlock-details',
      body: {
        'job_id': jobId,
        'bid_id': bidId,
        'worker_id': workerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
