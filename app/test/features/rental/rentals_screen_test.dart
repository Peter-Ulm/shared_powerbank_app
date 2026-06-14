import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/domain/models/rental.dart';
import 'package:marijoy_app/domain/repositories/rentals_repository.dart';
import 'package:marijoy_app/features/rental/presentation/rental_timer_card.dart';
import 'package:marijoy_app/features/rental/presentation/rentals_screen.dart';

class _FakeRentalsRepo implements RentalsRepository {
  @override
  Future<List<Rental>> list({RentalStatus? status}) async => [
        Rental(
          id: 'R1', powerbankId: 'PB1', status: RentalStatus.active,
          startedAt: DateTime(2026, 6, 14, 10), dueAt: DateTime(2026, 6, 14, 15),
        ),
      ];
  @override
  Future<Rental> byId(String id) async => throw UnimplementedError();
  @override
  Stream<List<Rental>> watchActive() => const Stream.empty();
}

void main() {
  testWidgets('lists active rentals as timer cards', (tester) async {
    final container = ProviderContainer(overrides: [
      rentalsRepositoryProvider.overrideWithValue(_FakeRentalsRepo()),
    ]);
    addTearDown(container.dispose);

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const RentalsScreen()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(RentalTimerCard), findsOneWidget);
  });
}
