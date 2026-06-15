import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/rental.dart';
import 'history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historia / History')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (rentals) => rentals.isEmpty
            ? const Center(child: Text('Hakuna historia / No history'))
            : ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (_, i) {
                  final r = rentals[i];
                  return ListTile(
                    leading: Icon(_statusIcon(r.status)),
                    title: Text('Benki ${r.powerbankId}'),
                    subtitle: Text('${r.startedAt.toLocal()} • ${r.status.name}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/receipt/${r.id}'),
                  );
                },
              ),
      ),
    );
  }

  IconData _statusIcon(RentalStatus s) {
    switch (s) {
      case RentalStatus.completed:
        return Icons.check_circle;
      case RentalStatus.active:
        return Icons.bolt;
      case RentalStatus.overdue:
        return Icons.timelapse;
      case RentalStatus.lost:
        return Icons.report;
      case RentalStatus.disputed:
      case RentalStatus.closedByAdmin:
        return Icons.info;
    }
  }
}
