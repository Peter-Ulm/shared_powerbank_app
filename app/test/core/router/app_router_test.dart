import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/router/app_router.dart';

void main() {
  testWidgets('unauthenticated user lands on Onboarding', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('authenticated user lands on Home', (tester) async {
    final container = ProviderContainer(
      overrides: [isAuthenticatedProvider.overrideWith((_) => true)],
    );
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
