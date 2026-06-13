import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/app.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';

void main() {
  testWidgets('app boots and shows Onboarding for a new user', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
      child: const MariJoyApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsOneWidget);
  });
}
