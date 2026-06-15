import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/history/presentation/history_screen.dart';
import 'package:marijoy_app/features/history/presentation/receipt_screen.dart';

void main() {
  testWidgets('lists seeded history and opens a receipt', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/receipt/:id', builder: (_, s) => ReceiptScreen(rentalId: s.pathParameters['id']!)),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Benki PB-H1'), findsOneWidget);
    await tester.tap(find.text('Benki PB-H1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Risiti #H1'), findsOneWidget);
  });
}
