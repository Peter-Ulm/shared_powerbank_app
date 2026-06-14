import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/order.dart';
import 'ejection_progress_view.dart';
import 'order_providers.dart';
import 'order_result_view.dart';
import 'payment_wait_view.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderStreamProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Malipo / Payment'), automaticallyImplyLeading: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (order) {
          switch (order.status) {
            case OrderStatus.created:
            case OrderStatus.paymentPending:
            case OrderStatus.paid:
              return PaymentWaitView(order: order);
            case OrderStatus.fulfilling:
              return EjectionProgressView(order: order);
            case OrderStatus.fulfilled:
            case OrderStatus.partiallyFulfilled:
            case OrderStatus.failed:
            case OrderStatus.expired:
            case OrderStatus.cancelled:
            case OrderStatus.refundPending:
            case OrderStatus.refunded:
              return OrderResultView(order: order);
          }
        },
      ),
    );
  }
}
