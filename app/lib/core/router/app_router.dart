import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';

/// Placeholder screens; real ones land in later plans. Routes and the auth
/// gate are defined now so feature plans only swap the builders.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(label)));
}

GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final loggedIn = ref.read(isAuthenticatedProvider);
      final onboarding = state.matchedLocation == '/onboarding';
      if (!loggedIn && !onboarding) return '/onboarding';
      if (loggedIn && onboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const _Placeholder('Onboarding')),
      GoRoute(path: '/home', builder: (_, __) => const _Placeholder('Home')),
      GoRoute(path: '/scan', builder: (_, __) => const _Placeholder('Scan')),
      GoRoute(path: '/c/:deviceId', builder: (_, s) => _Placeholder('Checkout ${s.pathParameters['deviceId']}')),
      GoRoute(path: '/orders/:id', builder: (_, s) => _Placeholder('Order ${s.pathParameters['id']}')),
      GoRoute(path: '/rentals', builder: (_, __) => const _Placeholder('Rentals')),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));
