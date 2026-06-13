import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import 'auth_controller.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masharti / Terms')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Kwa kukodi benki ya MariJoy, unakubali ada ya ucheleweshaji '
                  'na ada ya kupoteza benki kama ilivyoainishwa.\n\n'
                  'By renting a MariJoy power bank, you agree to the overage and '
                  'lost-bank fees as described.',
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                ref.read(appPrefsProvider).termsAccepted = true;
                ref.read(authControllerProvider.notifier).acknowledgeTerms();
              },
              child: const Text('Nakubali / I accept'),
            ),
          ],
        ),
      ),
    );
  }
}
