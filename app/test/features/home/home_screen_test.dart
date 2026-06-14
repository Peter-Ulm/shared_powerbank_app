import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/home/presentation/cabinet_card.dart';
import 'package:marijoy_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('renders cabinet cards from the mock repository', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/scan', builder: (_, __) => const Scaffold(body: Text('Scan'))),
      GoRoute(path: '/c/:id', builder: (_, __) => const Scaffold(body: Text('Checkout'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
    // Let the async cabinets load (avoid pumpAndSettle: the map keeps ticking).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CabinetCard), findsWidgets);
    expect(find.text('Mlimani City - Gate'), findsOneWidget);
  });
}
