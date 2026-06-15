import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/profile/presentation/profile_screen.dart';
import 'package:marijoy_app/features/history/presentation/history_screen.dart';

void main() {
  testWidgets('profile -> history navigation', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/rentals', builder: (_, __) => const Scaffold(body: Text('RENTALS'))),
      GoRoute(path: '/support', builder: (_, __) => const Scaffold(body: Text('SUPPORT'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.tap(find.text('Historia / History'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Benki PB-H1'), findsOneWidget);
  });
}
