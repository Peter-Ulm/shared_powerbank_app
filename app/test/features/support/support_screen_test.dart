import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/features/support/presentation/support_screen.dart';

void main() {
  testWidgets('renders FAQ and expands an answer', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('en'),
      supportedLocales: [Locale('en'), Locale('sw')],
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: SupportScreen(),
    ));
    await tester.pump();
    expect(find.text('How do I rent a power bank?'), findsOneWidget);
    await tester.tap(find.text('Where do I return it?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No PIN needed'), findsOneWidget);
  });
}
