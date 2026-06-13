import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/onboarding/presentation/terms_screen.dart';

void main() {
  testWidgets('accepting terms persists the flag', (tester) async {
    final prefs = InMemoryAppPrefs();
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
    ]);
    addTearDown(c.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: TermsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(prefs.termsAccepted, isFalse);
    await tester.tap(find.text('Nakubali / I accept'));
    await tester.pump();
    expect(prefs.termsAccepted, isTrue);
  });
}
