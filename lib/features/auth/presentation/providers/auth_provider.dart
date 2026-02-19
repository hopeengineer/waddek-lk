import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_repository.dart';

/// Provides the [AuthRepository] singleton.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Auth state notifier — manages OTP, login, and registration flow state.
enum AuthFlowState {
  idle,
  sendingOtp,
  otpSent,
  verifying,
  verified,
  loggingIn,
  awaiting2fa,
  registering,
  registered,
  error,
}

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

  /// Send OTP to phone number (signup only).
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(
      flowState: AuthFlowState.sendingOtp,
      phone: phone,
      isLoading: true,
    );

    try {
      final success = await _repo.sendOtp(phone, context: 'signup');
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

  /// Verify OTP code (signup context).
  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(
      flowState: AuthFlowState.verifying,
      isLoading: true,
    );

    try {
      await _repo.verifyOtp(state.phone, code, context: 'signup');
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

  /// Verify OTP code for 2FA login.
  Future<bool> verify2fa(String code) async {
    state = state.copyWith(
      flowState: AuthFlowState.verifying,
      isLoading: true,
    );

    try {
      await _repo.verifyOtp(state.phone, code, context: 'login_2fa');
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

  /// Log in with phone/email + password.
  Future<void> login(String identifier, String password) async {
    state = state.copyWith(
      flowState: AuthFlowState.loggingIn,
      isLoading: true,
    );

    try {
      final result = await _repo.login(identifier, password);
      final phone = result['phone'] as String? ?? identifier;
      state = state.copyWith(
        flowState: AuthFlowState.awaiting2fa,
        phone: phone,
        isLoading: false,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: e.message,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: 'Login failed. Please try again.',
        isLoading: false,
      );
    }
  }

  /// Register new user with profile data.
  Future<void> register({
    required String phone,
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      flowState: AuthFlowState.registering,
      isLoading: true,
    );

    try {
      await _repo.register(
        phone: phone,
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(
        flowState: AuthFlowState.registered,
        isLoading: false,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: e.message,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        flowState: AuthFlowState.error,
        errorMessage: 'Registration failed. Please try again.',
        isLoading: false,
      );
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
