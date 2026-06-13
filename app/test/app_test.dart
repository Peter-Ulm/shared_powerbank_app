import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/app.dart';

void main() {
  testWidgets('app boots and shows Onboarding for a new user', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MariJoyApp()));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsOneWidget);
  });
}
