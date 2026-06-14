import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/checkout/presentation/checkout_screen.dart';

void main() {
  testWidgets('shows total, steps quantity, and pays to the order route', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const CheckoutScreen(cabinetId: 'CAB001')),
      GoRoute(path: '/orders/:id', builder: (_, s) => Scaffold(body: Text('ORDER ${s.pathParameters['id']}'))),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // CAB001 unit price 1000, qty 1 -> total 1,000
    expect(find.text('Jumla / Total: TZS 1,000'), findsOneWidget);
    await tester.tap(find.byKey(const Key('qtyPlus')));
    await tester.pump();
    expect(find.text('Jumla / Total: TZS 2,000'), findsOneWidget);

    // No auth user -> wallet unset; pick one to enable Pay.
    await tester.tap(find.byKey(const Key('walletDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MPESA').last);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Lipa / Pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('ORDER'), findsOneWidget);

    // Drain the scenario engine's scheduled timers so none leak past the test.
    await tester.pump(const Duration(seconds: 7));
  });
}
