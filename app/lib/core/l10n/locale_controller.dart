import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Holds the active locale (null = follow device, resolved to sw default).
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(appPrefsProvider).locale;
    return code == null ? null : Locale(code);
  }

  void setLocale(Locale locale) {
    ref.read(appPrefsProvider).locale = locale.languageCode;
    state = locale;
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
