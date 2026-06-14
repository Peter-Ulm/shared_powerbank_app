import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/order.dart';

class OrderResultView extends StatelessWidget {
  const OrderResultView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final failed = order.status == OrderStatus.failed ||
        order.status == OrderStatus.expired ||
        order.status == OrderStatus.cancelled;
    if (failed) {
      return _Centered(
        icon: Icons.cancel,
        color: Colors.red,
        title: 'Malipo hayakukamilika',
        subtitle: 'Payment did not complete.',
        buttonLabel: 'Rudi nyumbani / Home',
        onPressed: () => context.go('/home'),
      );
    }
    final partial = order.status == OrderStatus.partiallyFulfilled;
    return _Centered(
      icon: Icons.bolt,
      color: Colors.green,
      title: partial ? 'Baadhi ya benki zimetoka' : 'Benki zako ziko tayari!',
      subtitle: partial
          ? 'Some banks failed and were refunded.'
          : 'Your power bank(s) are ready.',
      buttonLabel: 'Tazama kukodi / View rentals',
      onPressed: () => context.go('/rentals'),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: color),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
