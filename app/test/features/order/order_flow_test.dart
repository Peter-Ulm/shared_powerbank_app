import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/features/order/presentation/order_screen.dart';

void main() {
  testWidgets('payment-wait -> ejection -> result', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final order = await container.read(ordersRepositoryProvider).create(
          cabinetId: 'CAB001', qty: 1, idempotencyKey: 'k1',
        );

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => OrderScreen(orderId: order.id)),
      GoRoute(path: '/rentals', builder: (_, __) => const Scaffold(body: Text('RENTALS'))),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Check your phone'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('Ejecting'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('ready'), findsOneWidget);
  });
}
