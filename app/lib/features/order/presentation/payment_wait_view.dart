import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../domain/models/order.dart';

class PaymentWaitView extends ConsumerWidget {
  const PaymentWaitView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(ordersRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phonelink_ring, size: 72),
          const SizedBox(height: 16),
          Text('Angalia simu yako, weka namba yako ya siri',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Check your phone and enter your PIN', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Kiasi / Amount: ${formatTzs(order.amountTzs)}'),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => repo.repush(order.id),
            child: const Text('Tuma ombi tena / Resend prompt'),
          ),
          TextButton(
            onPressed: () => repo.byId(order.id), // force a status re-check
            child: const Text('Nimelipa / I already paid'),
          ),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Lipa kwa Lipa Namba'),
                content: Text('Lipa Namba: 555111\nKumbukumbu / Ref: ${order.id}'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sawa')),
                ],
              ),
            ),
            child: const Text('Lipa kwa njia nyingine / Pay another way'),
          ),
        ],
      ),
    );
  }
}
