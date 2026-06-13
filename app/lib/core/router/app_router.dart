import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../../features/onboarding/presentation/auth_controller.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_flow.dart';
import '../../features/onboarding/presentation/terms_screen.dart';

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(label)));
}

GoRouter buildRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      return auth.maybeWhen(
        unknown: () => loc == '/splash' ? null : '/splash',
        authenticated: (user) {
          final accepted = ref.read(appPrefsProvider).termsAccepted;
          if (!accepted) return loc == '/terms' ? null : '/terms';
          if (loc == '/splash' || loc == '/onboarding' || loc == '/terms') return '/home';
          return null;
        },
        orElse: () => loc == '/onboarding' ? null : '/onboarding',
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingFlow()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
      GoRoute(path: '/home', builder: (_, __) => const _Placeholder('Home')),
      GoRoute(path: '/scan', builder: (_, __) => const _Placeholder('Scan')),
      GoRoute(path: '/c/:deviceId', builder: (_, s) => _Placeholder('Checkout ${s.pathParameters['deviceId']}')),
      GoRoute(path: '/orders/:id', builder: (_, s) => _Placeholder('Order ${s.pathParameters['id']}')),
      GoRoute(path: '/rentals', builder: (_, __) => const _Placeholder('Rentals')),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));
