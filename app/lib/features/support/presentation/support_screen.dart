import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final items = faqItems(locale);
    return Scaffold(
      appBar: AppBar(title: const Text('Msaada / Support')),
      body: ListView(
        children: [
          for (final f in items)
            ExpansionTile(title: Text(f.q), children: [
              Padding(padding: const EdgeInsets.all(16), child: Text(f.a)),
            ]),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('WhatsApp'),
            onTap: () => _launch(Uri.parse('https://wa.me/255700000000')),
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Piga simu / Call'),
            onTap: () => _launch(Uri.parse('tel:+255700000000')),
          ),
        ],
      ),
    );
  }
}
