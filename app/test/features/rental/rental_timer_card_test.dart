import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/domain/models/rental.dart';
import 'package:marijoy_app/features/rental/presentation/rental_timer_card.dart';

void main() {
  testWidgets('shows remaining time from server timestamps', (tester) async {
    final started = DateTime(2026, 6, 14, 10);
    final due = started.add(const Duration(hours: 5));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RentalTimerCard(
          rental: Rental(
            id: 'R1', powerbankId: 'PB1', status: RentalStatus.active,
            startedAt: started, dueAt: due,
          ),
          now: () => started.add(const Duration(hours: 1)), // 4h left
        ),
      ),
    ));
    expect(find.text('4:00:00'), findsOneWidget);
    expect(find.text('Benki PB1'), findsOneWidget);
  });

  testWidgets('overdue shows overdue label', (tester) async {
    final started = DateTime(2026, 6, 14, 10);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RentalTimerCard(
          rental: Rental(
            id: 'R1', powerbankId: 'PB1', status: RentalStatus.overdue,
            startedAt: started, dueAt: started.add(const Duration(hours: 5)),
          ),
          now: () => started.add(const Duration(hours: 6)),
        ),
      ),
    ));
    expect(find.textContaining('Overdue'), findsOneWidget);
  });
}
