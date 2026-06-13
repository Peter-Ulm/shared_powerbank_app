import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth_state.dart';
import 'package:marijoy_app/features/onboarding/presentation/auth_controller.dart';

ProviderContainer _container(TokenStore store) {
  final c = ProviderContainer(overrides: [
    tokenStoreProvider.overrideWithValue(store),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('restores to unauthenticated when no token', () async {
    final c = _container(InMemoryTokenStore());
    c.read(authControllerProvider);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(authControllerProvider), const AuthState.unauthenticated());
  });

  test('requestOtp -> otpSent, verifyOtp -> authenticated and persists token', () async {
    final store = InMemoryTokenStore();
    final c = _container(store);
    final ctrl = c.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    await ctrl.requestOtp('+255712345678');
    expect(c.read(authControllerProvider), const AuthState.otpSent(phone: '+255712345678'));

    await ctrl.verifyOtp('123456');
    final state = c.read(authControllerProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user.phone, '+255712345678');
    expect(await store.read(), isNotNull);
  });

  test('signOut clears token and returns to unauthenticated', () async {
    final store = InMemoryTokenStore();
    final c = _container(store);
    final ctrl = c.read(authControllerProvider.notifier);
    await ctrl.requestOtp('+255712345678');
    await ctrl.verifyOtp('123456');
    await ctrl.signOut();
    expect(c.read(authControllerProvider), const AuthState.unauthenticated());
    expect(await store.read(), isNull);
  });
}
