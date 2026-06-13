import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/app.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';

void main() {
  testWidgets('new user: language -> phone -> otp -> terms -> home', (tester) async {
    final app = ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
      child: const MariJoyApp(),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    // Language
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();
    // Phone
    await tester.enterText(find.byType(TextField), '0712345678');
    await tester.tap(find.text('Endelea / Continue'));
    await tester.pumpAndSettle();
    // OTP
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.text('Thibitisha / Verify'));
    await tester.pumpAndSettle();
    // Terms gate
    expect(find.text('Masharti / Terms'), findsOneWidget);
    await tester.tap(find.text('Nakubali / I accept'));
    await tester.pumpAndSettle();
    // Home
    expect(find.text('Home'), findsOneWidget);
  });
}
