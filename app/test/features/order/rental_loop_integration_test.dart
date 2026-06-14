import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/checkout/presentation/checkout_screen.dart';
import 'package:marijoy_app/features/order/presentation/order_screen.dart';
import 'package:marijoy_app/features/rental/presentation/rental_timer_card.dart';
import 'package:marijoy_app/features/rental/presentation/rentals_screen.dart';

void main() {
  testWidgets('checkout -> pay -> eject -> result -> rentals', (tester) async {
    final router = GoRouter(initialLocation: '/c/CAB001', routes: [
      GoRoute(path: '/c/:deviceId', builder: (_, s) => CheckoutScreen(cabinetId: s.pathParameters['deviceId']!)),
      GoRoute(path: '/orders/:id', builder: (_, s) => OrderScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/rentals', builder: (_, __) => const RentalsScreen()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Pick a wallet, then pay.
    await tester.tap(find.byKey(const Key('walletDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MPESA').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Lipa / Pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Check your phone'), findsOneWidget);

    // Advance the engine through ejection to result.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('Ejecting'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('ready'), findsOneWidget);

    // Go to rentals.
    await tester.tap(find.textContaining('View rentals'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RentalTimerCard), findsOneWidget);
  });
}
