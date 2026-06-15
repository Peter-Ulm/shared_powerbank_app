import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../onboarding/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final phone = auth.maybeWhen(authenticated: (u) => u.phone, orElse: () => '-');
    final locale = ref.watch(localeControllerProvider);
    final isSwahili = (locale?.languageCode ?? 'sw') == 'sw';
    return Scaffold(
      appBar: AppBar(title: const Text('Akaunti / Account')),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.phone), title: Text(phone)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text('Kukodi kwangu / My rentals'),
            onTap: () => context.push('/rentals'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historia / History'),
            onTap: () => context.push('/history'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Msaada / Support'),
            onTap: () => context.push('/support'),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.language),
            title: const Text('Kiswahili'),
            value: isSwahili,
            onChanged: (v) => ref
                .read(localeControllerProvider.notifier)
                .setLocale(Locale(v ? 'sw' : 'en')),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Toka / Log out'),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
