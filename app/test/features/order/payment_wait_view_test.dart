import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/features/order/presentation/payment_wait_view.dart';

void main() {
  testWidgets('shows check-phone copy and resend, and has NO PIN field', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PaymentWaitView(
            order: Order(id: 'ORD001', status: OrderStatus.paymentPending, amountTzs: 1000),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Check your phone'), findsOneWidget);
    expect(find.textContaining('Resend prompt'), findsOneWidget);
    // Invariant 4: the app NEVER collects the mobile-money PIN.
    expect(find.byType(TextField), findsNothing);
  });
}
