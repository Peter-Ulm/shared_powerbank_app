import 'package:flutter/material.dart';
import '../../../domain/models/order.dart';

class EjectionProgressView extends StatelessWidget {
  const EjectionProgressView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Inatoa benki / Ejecting',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final u in order.fulfilment)
            ListTile(
              leading: _iconFor(u.status),
              title: Text('Benki ${u.unit}'),
              subtitle: Text(_labelFor(u)),
            ),
        ],
      ),
    );
  }

  Widget _iconFor(FulfilmentStatus s) {
    switch (s) {
      case FulfilmentStatus.ejected:
        return const Icon(Icons.check_circle, color: Colors.green);
      case FulfilmentStatus.failed:
      case FulfilmentStatus.refunded:
        return const Icon(Icons.error, color: Colors.red);
      case FulfilmentStatus.pending:
      case FulfilmentStatus.ejecting:
        return const SizedBox(
            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }
  }

  String _labelFor(FulfilmentUnit u) {
    switch (u.status) {
      case FulfilmentStatus.ejected:
        return 'Mlango ${u.slot} • imetoka';
      case FulfilmentStatus.failed:
        return 'Imeshindikana — umerejeshewa';
      case FulfilmentStatus.refunded:
        return 'Umerejeshewa';
      case FulfilmentStatus.pending:
      case FulfilmentStatus.ejecting:
        return 'Subiri / Please wait';
    }
  }
}
