import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/features/scan/presentation/cabinet_code_field.dart';

void main() {
  testWidgets('valid code calls onSubmit with parsed id', (tester) async {
    String? submitted;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CabinetCodeField(onSubmit: (id) => submitted = id)),
    ));
    await tester.enterText(find.byType(TextField), 'cab001');
    await tester.tap(find.text('Fungua / Open'));
    await tester.pump();
    expect(submitted, 'CAB001');
  });

  testWidgets('invalid code shows an error and does not submit', (tester) async {
    String? submitted;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CabinetCodeField(onSubmit: (id) => submitted = id)),
    ));
    await tester.enterText(find.byType(TextField), 'hi');
    await tester.tap(find.text('Fungua / Open'));
    await tester.pump();
    expect(submitted, isNull);
    expect(find.textContaining('si sahihi'), findsOneWidget);
  });
}
