import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/router/app_router.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth.dart';

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp.router(routerConfig: c.read(routerProvider)),
  ));
  await tester.pumpAndSettle();
}

ProviderContainer _container({required TokenStore tokens, AppPrefs? prefs}) {
  final c = ProviderContainer(overrides: [
    tokenStoreProvider.overrideWithValue(tokens),
    appPrefsProvider.overrideWithValue(prefs ?? InMemoryAppPrefs()),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  testWidgets('no token -> lands on Onboarding', (tester) async {
    final c = _container(tokens: InMemoryTokenStore());
    await _pump(tester, c);
    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('valid token but terms not accepted -> Terms', (tester) async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final c = _container(tokens: store, prefs: InMemoryAppPrefs(termsAccepted: false));
    await _pump(tester, c);
    expect(find.text('Terms'), findsOneWidget);
  });

  testWidgets('valid token and terms accepted -> Home', (tester) async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final c = _container(tokens: store, prefs: InMemoryAppPrefs(termsAccepted: true));
    await _pump(tester, c);
    expect(find.text('Home'), findsOneWidget);
  });
}
