import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/verification_repository.dart';

final verificationRepositoryProvider =
    Provider<VerificationRepository>((ref) => VerificationRepository());

/// Verification flow state that the UI listens to.
class VerificationState {
  const VerificationState({
    this.starting = false,
    this.polling = false,
    this.error,
    this.verificationUrl,
  });

  /// True while we're calling the start edge function.
  final bool starting;

  /// True while the user is on Shufti's hosted page and we're
  /// polling `profiles.verification_status` for the webhook to land.
  final bool polling;

  final String? error;
  final String? verificationUrl;

  VerificationState copyWith({
    bool? starting,
    bool? polling,
    String? error,
    String? verificationUrl,
  }) =>
      VerificationState(
        starting: starting ?? this.starting,
        polling: polling ?? this.polling,
        error: error,
        verificationUrl: verificationUrl ?? this.verificationUrl,
      );
}

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier(this._ref) : super(const VerificationState());

  final Ref _ref;
  Timer? _pollTimer;

  /// Kick off the flow. Returns the verification URL that the caller
  /// should open in a browser (web tab or in-app webview).
  Future<String?> start(String docType) async {
    state = state.copyWith(starting: true, error: null);
    try {
      final url = await _ref
          .read(verificationRepositoryProvider)
          .startVerification(docType);
      state = state.copyWith(
        starting: false,
        polling: true,
        verificationUrl: url,
      );
      _startPolling();
      return url;
    } catch (e) {
      state = state.copyWith(
        starting: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _ref.read(currentProfileProvider.notifier).loadProfile();
      final profile = _ref.read(currentProfileProvider).valueOrNull;
      if (profile == null) return;
      final status = profile.verificationStatus;
      // Terminal states — stop polling.
      if (status == 'verified' ||
          status == 'duplicate_detected' ||
          status == 'rejected' ||
          // The webhook resets to 'unverified' on decline, but only
          // after the user spent time on Shufti's page — treat the
          // presence of a decline reason as terminal.
          (status == 'unverified' &&
              (profile.shuftiproDeclineReason ?? '').isNotEmpty)) {
        stopPolling();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (state.polling) state = state.copyWith(polling: false);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final verificationProvider =
    StateNotifierProvider.autoDispose<VerificationNotifier, VerificationState>(
        (ref) => VerificationNotifier(ref));
