import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/domain/models/cabinet.dart';
import 'package:marijoy_app/features/home/presentation/cabinet_card.dart';

void main() {
  testWidgets('shows label, availability counts and distance; taps when online', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CabinetCard(
          cabinet: const Cabinet(
            id: 'CAB001', label: 'Mlimani City', banksAvailable: 6, freeSlots: 10,
            online: true, lat: -6.77, lng: 39.24, distanceMeters: 120,
          ),
          onTap: () => tapped = true,
        ),
      ),
    ));
    expect(find.text('Mlimani City'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('120 m'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    expect(tapped, isTrue);
  });

  testWidgets('offline cabinet shows offline label and does not tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CabinetCard(
          cabinet: const Cabinet(
            id: 'CAB003', label: 'Mwenge', banksAvailable: 0, freeSlots: 0,
            online: false, lat: -6.77, lng: 39.22,
          ),
          onTap: () => tapped = true,
        ),
      ),
    ));
    expect(find.text('Nje ya mtandao'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    expect(tapped, isFalse);
  });
}
