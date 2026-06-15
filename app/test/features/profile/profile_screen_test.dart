import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/l10n/locale_controller.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('toggling language updates the locale controller', (tester) async {
    final prefs = InMemoryAppPrefs();
    final container = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProfileScreen()),
    ));
    await tester.pump();

    expect(container.read(localeControllerProvider), isNull); // default
    await tester.tap(find.byType(SwitchListTile)); // sw -> toggles to en
    await tester.pump();
    expect(container.read(localeControllerProvider), const Locale('en'));
    expect(prefs.locale, 'en');
  });
}
