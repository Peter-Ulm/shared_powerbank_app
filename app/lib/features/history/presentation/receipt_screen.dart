import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/rental.dart';
import 'history_controller.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.rentalId});
  final String rentalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Risiti / Receipt')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (rentals) {
          Rental? r;
          for (final x in rentals) {
            if (x.id == rentalId) {
              r = x;
              break;
            }
          }
          if (r == null) return const Center(child: Text('Haipo / Not found'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risiti #${r.id}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _row('Benki', r.powerbankId),
                _row('Hali / Status', r.status.name),
                _row('Ilianza / Started', '${r.startedAt.toLocal()}'),
                if (r.returnedAt != null) _row('Ilirudishwa / Returned', '${r.returnedAt!.toLocal()}'),
                _row('Cabinet', r.cabinetOutId ?? '-'),
                _row('Ada ya ucheleweshaji / Overage', 'TZS ${r.overageTzs}'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(k), Flexible(child: Text(v, textAlign: TextAlign.right))],
        ),
      );
}
