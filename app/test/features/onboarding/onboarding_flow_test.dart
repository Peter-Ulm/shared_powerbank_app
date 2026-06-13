import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/l10n/app_localizations.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/onboarding/presentation/auth_controller.dart';
import 'package:marijoy_app/features/onboarding/presentation/onboarding_flow.dart';

Widget _wrap(ProviderContainer c) => UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        locale: Locale('sw'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: OnboardingFlow(),
      ),
    );

void main() {
  testWidgets('language -> phone -> otp progression', (tester) async {
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
    ]);
    addTearDown(c.dispose);
    c.read(authControllerProvider);
    await tester.pumpWidget(_wrap(c));
    await tester.pumpAndSettle();

    expect(find.text('Kiswahili'), findsOneWidget);
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0712345678');
    await tester.tap(find.text('Endelea / Continue'));
    await tester.pumpAndSettle();

    expect(find.text('OTP'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.text('Thibitisha / Verify'));
    await tester.pumpAndSettle();
  });
}
