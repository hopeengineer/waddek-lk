import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

/// Provides the [AuthRepository] singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state notifier — manages OTP flow state.
enum AuthFlowState { idle, sendingOtp, otpSent, verifying, verified, error }

class AuthState {
  const AuthState({
    this.flowState = AuthFlowState.idle,
    this.phone = '',
    this.errorMessage,
    this.isLoading = false,
  });

  final AuthFlowState flowState;
  final String phone;
  final String? errorMessage;
  final bool isLoading;

  AuthState copyWith({
    AuthFlowState? flowState,
    String? phone,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      flowState: flowState ?? this.flowState,
      phone: phone ?? this.phone,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  /// Send OTP to phone number.
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      flowState: AuthFlowState.sendingOtp,
      phone: phone,
      isLoading: true,
    );

    try {
      final success = await _repo.sendOtp(phone);
      if (success) {
        state = state.copyWith(
          flowState: AuthFlowState.otpSent,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          flowState: AuthFlowState.error,
          errorMessage: 'Failed to send OTP. Please try again.',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Verify OTP code.
  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(
      flowState: AuthFlowState.verifying,
      isLoading: true,
    );

    try {
      await _repo.verifyOtp(state.phone, code);
      state = state.copyWith(
        flowState: AuthFlowState.verified,
        isLoading: false,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: e.message,
        isLoading: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: 'Verification failed. Please try again.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Check if user needs role selection.
  Future<bool> needsOnboarding() async {
    return !(await _repo.hasProfile());
  }

  /// Set user role.
  Future<void> setRole(String role) async {
    await _repo.setRole(role);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }

  /// Clear error state.
  void clearError() {
    state = state.copyWith(flowState: AuthFlowState.idle);
  }
}

/// Provider for the auth state notifier.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
