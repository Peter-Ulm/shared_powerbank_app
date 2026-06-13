import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthState.unknown();
  }

  Future<void> _restore() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens == null) {
      state = const AuthState.unauthenticated();
      return;
    }
    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = AuthState.authenticated(user: user);
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> requestOtp(String phoneE164) async {
    await ref.read(authRepositoryProvider).requestOtp(phoneE164);
    state = AuthState.otpSent(phone: phoneE164);
  }

  Future<void> verifyOtp(String code) async {
    final phone = state.maybeWhen(otpSent: (p) => p, orElse: () => null);
    if (phone == null) {
      throw StateError('verifyOtp called before an OTP was requested');
    }
    final res = await ref.read(authRepositoryProvider).verifyOtp(phone, code);
    await ref.read(tokenStoreProvider).write(res.tokens);
    state = AuthState.authenticated(user: res.user);
  }

  Future<void> signOut() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AuthState.unauthenticated();
  }

  /// Re-emit the current authenticated state so the router re-evaluates the
  /// terms gate after the user accepts T&Cs.
  void acknowledgeTerms() {
    final s = state;
    if (s is AuthAuthenticated) {
      state = AuthState.authenticated(user: s.user);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
