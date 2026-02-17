import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/disputes_repository.dart';
import '../../domain/dispute_model.dart';

final disputesRepositoryProvider = Provider<DisputesRepository>((ref) {
  return DisputesRepository();
});

/// User's disputes.
final myDisputesProvider =
    FutureProvider<List<DisputeModel>>((ref) async {
  return ref.read(disputesRepositoryProvider).getMyDisputes();
});
