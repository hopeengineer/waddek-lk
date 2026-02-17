import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wallet_repository.dart';
import '../domain/wallet_model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

/// Wallet balance — realtime stream.
final walletStreamProvider =
    StreamProvider.family<WalletModel?, String>((ref, userId) {
  return ref.read(walletRepositoryProvider).streamWallet(userId);
});

/// Transaction history.
final transactionsProvider =
    FutureProvider.family<List<TransactionModel>, String>(
        (ref, walletId) async {
  return ref.read(walletRepositoryProvider).getTransactions(walletId);
});

/// Top-up packages.
final topUpPackagesProvider =
    FutureProvider<List<TopUpPackage>>((ref) async {
  return ref.read(walletRepositoryProvider).getTopUpPackages();
});
