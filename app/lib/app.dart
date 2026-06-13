import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_localizations.dart';
import 'core/l10n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/marijoy_theme.dart';

class MariJoyApp extends ConsumerWidget {
  const MariJoyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: 'MariJoy',
      debugShowCheckedModeBanner: false,
      theme: MariJoyTheme.light(),
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (deviceLocale, supported) {
        for (final l in supported) {
          if (l.languageCode == deviceLocale?.languageCode) return l;
        }
        return const Locale('sw');
      },
    );
  }
}
