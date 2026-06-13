import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/locale_controller.dart';

class LanguageStep extends ConsumerWidget {
  const LanguageStep({super.key, required this.onChosen});
  final VoidCallback onChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void choose(Locale locale) {
      ref.read(localeControllerProvider.notifier).setLocale(locale);
      onChosen();
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MariJoy', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Chagua lugha / Choose language'),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => choose(const Locale('sw')), child: const Text('Kiswahili')),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => choose(const Locale('en')), child: const Text('English')),
          ],
        ),
      ),
    );
  }
}
