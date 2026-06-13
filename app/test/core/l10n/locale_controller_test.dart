import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/l10n/locale_controller.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';

void main() {
  test('initial locale follows persisted prefs', () {
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(InMemoryAppPrefs(locale: 'en')),
    ]);
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider), const Locale('en'));
  });

  test('setLocale updates state and persists', () {
    final prefs = InMemoryAppPrefs();
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(prefs),
    ]);
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider), isNull);
    c.read(localeControllerProvider.notifier).setLocale(const Locale('sw'));
    expect(c.read(localeControllerProvider), const Locale('sw'));
    expect(prefs.locale, 'sw');
  });
}
