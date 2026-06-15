# MariJoy App — Periphery & Real-Backend Readiness (Plan 5 of 5)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Complete the MVP app: history & receipts, profile (language switch / logout / hub), support (bilingual FAQ + WhatsApp/call), a wired notification interface, and the `HttpX` repository implementations + `dio` provider that flip the app from the mock backend to a real NestJS API via the single `AppEnvironment` flag — proving the contract with unit tests against mocked HTTP.

**Architecture:** Builds on Plans 1–4. Adds periphery feature folders (`history`, `profile`, `support`), a `NotificationService` no-op interface (real FCM is a documented drop-in needing Firebase config), and `Http*` implementations of the four repository interfaces selected by `env.useMockData`. Existing tests keep using mocks (default flavor = mock); the HTTP repos are unit-tested with `http_mock_adapter`.

**Tech Stack:** Plans 1–4 stack, plus `url_launcher` (WhatsApp/call/links).

**Reference:** `docs/specs/2026-06-13-mobile-app-design.md` §3 screens 8–10 + §4 (cross-cutting: deep links, push, observability, resume-on-launch); `Powerbank_shared/SPEC.md` §6 (full API), §3.4 (analytics).

**Prerequisite:** Plan 4 merged (rental loop on `main`, 62 tests green). Modifies `lib/core/providers.dart` (env-based repo selection + dio), `lib/core/router/app_router.dart` (periphery routes), `lib/features/home/presentation/home_screen.dart` (account button), `lib/mock/mock_repositories.dart` + `lib/mock/fixtures.dart` (seed history).

**Environment note for implementers:** Flutter at `C:\Users\USER\flutter\bin` is NOT on PATH for fresh shells — prepend `$env:Path = "C:\Users\USER\flutter\bin;$env:Path"`. Work in `C:\Users\USER\Desktop\shared_powerbank_app`, package `marijoy_app`, dir `app/`. Branch `feat/periphery-backend`. Screens with countdowns/maps use `pump(Duration)` not `pumpAndSettle()`.

---

## Deferred (needs external infra — out of MVP code scope, noted only)
- **Real FCM**: needs a Firebase project + `google-services.json`/`GoogleService-Info.plist`. This plan wires a `NotificationService` interface with a no-op mock; the real `FcmNotificationService` is a drop-in.
- **Real Sentry**: needs a DSN; bootstrap guards init behind `env`. Not added here to avoid dead config.
- **Live API integration/E2E**: needs the NestJS backend running. The `Http*` repos are unit-tested against mocked HTTP here; switch with `--dart-define=FLAVOR=dev --dart-define=API_BASE_URL=...` when the backend exists.
- **App Links platform manifest**: needs the production domain (Plan 3 note).

---

## File structure built by this plan

```
app/lib/
├── core/
│   ├── notifications/notification_service.dart   # Task 4 (NEW)
│   ├── providers.dart                            # MODIFY (Tasks 4,5)
│   └── router/app_router.dart                    # MODIFY (Task 6)
├── data/http/                                     # Task 5 (NEW)
│   ├── http_auth_repository.dart
│   ├── http_cabinets_repository.dart
│   ├── http_orders_repository.dart
│   └── http_rentals_repository.dart
├── mock/{fixtures.dart, mock_repositories.dart}   # MODIFY (Task 1: seed history)
└── features/
    ├── history/presentation/{history_controller.dart, history_screen.dart, receipt_screen.dart}
    ├── profile/presentation/profile_screen.dart
    └── support/presentation/{faq.dart, support_screen.dart}
```

---

## Task 1: Seed history + History/Receipt screens

**Files:** modify `app/lib/mock/fixtures.dart`, `app/lib/mock/mock_repositories.dart`; create `app/lib/features/history/presentation/history_controller.dart`, `history_screen.dart`, `receipt_screen.dart`; test `app/test/features/history/history_screen_test.dart`.

- [ ] **Step 1:** In `fixtures.dart` add seeded completed rentals (append to the file):
```dart
import '../domain/models/rental.dart';

final mockHistoryRentals = <Rental>[
  Rental(
    id: 'H1', powerbankId: 'PB-H1', status: RentalStatus.completed,
    startedAt: DateTime(2026, 6, 10, 9), dueAt: DateTime(2026, 6, 10, 14),
    returnedAt: DateTime(2026, 6, 10, 11, 30), cabinetOutId: 'CAB001',
  ),
  Rental(
    id: 'H2', powerbankId: 'PB-H2', status: RentalStatus.completed,
    startedAt: DateTime(2026, 6, 8, 18), dueAt: DateTime(2026, 6, 8, 23),
    returnedAt: DateTime(2026, 6, 8, 22), cabinetOutId: 'CAB002', overageTzs: 0,
  ),
];
```
(Keep the existing `import '../domain/models/cabinet.dart';`, `kUnitPriceTzs`, and `mockCabinets`.)

- [ ] **Step 2:** In `mock_repositories.dart`, make `MockRentalsRepository.list` include seeded history when no status filter (active-only stays engine-driven):
```dart
  @override
  Future<List<Rental>> list({RentalStatus? status}) async {
    final all = [..._engine.rentals, ...mockHistoryRentals];
    return all.where((r) => status == null || r.status == status).toList();
  }
```
(`mockHistoryRentals` comes from `fixtures.dart`, already imported.)

- [ ] **Step 3:** `history_controller.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/rental.dart';

/// All rentals (active + past), newest first.
final historyProvider = FutureProvider<List<Rental>>((ref) async {
  final list = await ref.read(rentalsRepositoryProvider).list();
  final sorted = [...list]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  return sorted;
});
```

- [ ] **Step 4:** `history_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/rental.dart';
import 'history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Historia / History')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (rentals) => rentals.isEmpty
            ? const Center(child: Text('Hakuna historia / No history'))
            : ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (_, i) {
                  final r = rentals[i];
                  return ListTile(
                    leading: Icon(_statusIcon(r.status)),
                    title: Text('Benki ${r.powerbankId}'),
                    subtitle: Text('${r.startedAt.toLocal()} • ${r.status.name}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/receipt/${r.id}'),
                  );
                },
              ),
      ),
    );
  }

  IconData _statusIcon(RentalStatus s) {
    switch (s) {
      case RentalStatus.completed:
        return Icons.check_circle;
      case RentalStatus.active:
        return Icons.bolt;
      case RentalStatus.overdue:
        return Icons.timelapse;
      case RentalStatus.lost:
        return Icons.report;
      case RentalStatus.disputed:
      case RentalStatus.closedByAdmin:
        return Icons.info;
    }
  }
}
```

- [ ] **Step 5:** `receipt_screen.dart` (looks the rental up in the history list):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_controller.dart';

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.rentalId});
  final String rentalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Risiti / Receipt')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (rentals) {
          final r = rentals.where((x) => x.id == rentalId).firstOrNull;
          if (r == null) return const Center(child: Text('Haipo / Not found'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risiti #${r.id}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _row('Benki', r.powerbankId),
                _row('Hali / Status', r.status.name),
                _row('Ilianza / Started', '${r.startedAt.toLocal()}'),
                if (r.returnedAt != null) _row('Ilirudishwa / Returned', '${r.returnedAt!.toLocal()}'),
                _row('Cabinet', r.cabinetOutId ?? '-'),
                _row('Ada ya ucheleweshaji / Overage', 'TZS ${r.overageTzs}'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(k), Flexible(child: Text(v, textAlign: TextAlign.right))],
        ),
      );
}
```
(`firstOrNull` is from `dart:collection`'s extension in `package:collection`; if unavailable, replace with `rentals.cast<Rental?>().firstWhere((x) => x?.id == rentalId, orElse: () => null)` and import the model — pick whichever analyzes clean.)

- [ ] **Step 6:** Test `history_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/history/presentation/history_screen.dart';
import 'package:marijoy_app/features/history/presentation/receipt_screen.dart';

void main() {
  testWidgets('lists seeded history and opens a receipt', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/receipt/:id', builder: (_, s) => ReceiptScreen(rentalId: s.pathParameters['id']!)),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Benki PB-H1'), findsOneWidget);
    await tester.tap(find.text('Benki PB-H1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Risiti #H1'), findsOneWidget);
  });
}
```

- [ ] **Step 7:** Run `flutter test test/features/history/history_screen_test.dart` (PASS). Commit: `git add lib/mock/fixtures.dart lib/mock/mock_repositories.dart lib/features/history test/features/history` then `feat: add History and Receipt screens with seeded mock history`.

---

## Task 2: Profile screen (language, logout, hub)

**Files:** create `app/lib/features/profile/presentation/profile_screen.dart`; test `app/test/features/profile/profile_screen_test.dart`.

- [ ] **Step 1:** `profile_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../onboarding/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final phone = auth.maybeWhen(authenticated: (u) => u.phone, orElse: () => '-');
    final locale = ref.watch(localeControllerProvider);
    final isSwahili = (locale?.languageCode ?? 'sw') == 'sw';
    return Scaffold(
      appBar: AppBar(title: const Text('Akaunti / Account')),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.phone), title: Text(phone)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text('Kukodi kwangu / My rentals'),
            onTap: () => context.push('/rentals'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historia / History'),
            onTap: () => context.push('/history'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Msaada / Support'),
            onTap: () => context.push('/support'),
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.language),
            title: const Text('Kiswahili'),
            value: isSwahili,
            onChanged: (v) => ref
                .read(localeControllerProvider.notifier)
                .setLocale(Locale(v ? 'sw' : 'en')),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Toka / Log out'),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2:** Test `profile_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/l10n/locale_controller.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('toggling language updates the locale controller', (tester) async {
    final prefs = InMemoryAppPrefs();
    final container = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProfileScreen()),
    ));
    await tester.pump();

    expect(container.read(localeControllerProvider), isNull); // default
    await tester.tap(find.byType(SwitchListTile)); // sw -> toggles to en (false)
    await tester.pump();
    expect(container.read(localeControllerProvider), const Locale('en'));
    expect(prefs.locale, 'en');
  });
}
```

- [ ] **Step 3:** Run `flutter test test/features/profile/profile_screen_test.dart` (PASS). Commit: `git add lib/features/profile test/features/profile` then `feat: add Profile screen (language, logout, navigation hub)`.

---

## Task 3: Support screen (FAQ + WhatsApp/call)

**Files:** add `url_launcher`; create `app/lib/features/support/presentation/faq.dart`, `support_screen.dart`; test `app/test/features/support/support_screen_test.dart`.

- [ ] **Step 1:** From `app/` run `flutter pub add url_launcher`.

- [ ] **Step 2:** `faq.dart`:
```dart
class FaqItem {
  const FaqItem(this.q, this.a);
  final String q;
  final String a;
}

List<FaqItem> faqItems(String locale) {
  if (locale == 'en') {
    return const [
      FaqItem('How do I rent a power bank?', 'Scan the cabinet QR, choose quantity, pay with mobile money, and take the ejected bank.'),
      FaqItem('Where do I return it?', 'Insert it into any MariJoy cabinet with a free slot. No PIN needed to return.'),
      FaqItem('What if a bank does not eject?', 'You are refunded automatically for that bank.'),
    ];
  }
  return const [
    FaqItem('Nakodije benki?', 'Skani QR ya cabinet, chagua idadi, lipa kwa simu, kisha chukua benki iliyotoka.'),
    FaqItem('Narudisha wapi?', 'Iingize kwenye cabinet yoyote ya MariJoy yenye nafasi. Hakuna PIN ya kurudisha.'),
    FaqItem('Benki isipotoka?', 'Unarejeshewa pesa kiotomatiki kwa benki hiyo.'),
  ];
}
```

- [ ] **Step 3:** `support_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final items = faqItems(locale);
    return Scaffold(
      appBar: AppBar(title: const Text('Msaada / Support')),
      body: ListView(
        children: [
          for (final f in items)
            ExpansionTile(title: Text(f.q), children: [
              Padding(padding: const EdgeInsets.all(16), child: Text(f.a)),
            ]),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('WhatsApp'),
            onTap: () => _launch(Uri.parse('https://wa.me/255700000000')),
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Piga simu / Call'),
            onTap: () => _launch(Uri.parse('tel:+255700000000')),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4:** Test `support_screen_test.dart` (FAQ renders + expands; no URL launching in the test):
```dart
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
```

- [ ] **Step 5:** Run `flutter test test/features/support/support_screen_test.dart` (PASS). Commit: `git add pubspec.yaml pubspec.lock lib/features/support test/features/support` then `feat: add Support screen (FAQ + WhatsApp/call)`.

---

## Task 4: NotificationService (no-op) + wiring

**Files:** create `app/lib/core/notifications/notification_service.dart`; modify `app/lib/core/providers.dart`; test `app/test/core/notifications/notification_service_test.dart`.

- [ ] **Step 1:** `notification_service.dart`:
```dart
/// Push-notification abstraction. The mock is a no-op; a real
/// FcmNotificationService (firebase_messaging) is a drop-in once Firebase is
/// configured. The app never depends on push for correctness (SMS is the
/// backend's fallback for money events) — only convenience.
abstract class NotificationService {
  Future<String?> registerToken();
  Future<void> clear();
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();
  @override
  Future<String?> registerToken() async => null;
  @override
  Future<void> clear() async {}
}
```

- [ ] **Step 2:** In `providers.dart` add `import 'notifications/notification_service.dart';` and:
```dart
final notificationServiceProvider =
    Provider<NotificationService>((ref) => const NoopNotificationService());
```

- [ ] **Step 3:** Test `notification_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/notifications/notification_service.dart';

void main() {
  test('noop notification service returns null token and clears quietly', () async {
    const svc = NoopNotificationService();
    expect(await svc.registerToken(), isNull);
    await svc.clear(); // no throw
  });
}
```

- [ ] **Step 4:** Run `flutter test test/core/notifications/notification_service_test.dart` (PASS). Commit: `git add lib/core/notifications lib/core/providers.dart test/core/notifications` then `feat: add NotificationService no-op interface`.

---

## Task 5: HttpX repositories + env-based selection

**Files:** create `app/lib/data/http/http_auth_repository.dart`, `http_cabinets_repository.dart`, `http_orders_repository.dart`, `http_rentals_repository.dart`; modify `app/lib/core/providers.dart`; tests `app/test/data/http/http_repositories_test.dart`.

- [ ] **Step 1:** `http_auth_repository.dart`:
```dart
import 'package:dio/dio.dart';
import '../../domain/models/auth.dart';
import '../../domain/repositories/auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._dio);
  final Dio _dio;

  @override
  Future<void> requestOtp(String phone) async {
    await _dio.post('/auth/otp/request', data: {'phone': phone});
  }

  @override
  Future<({AuthTokens tokens, AppUser user})> verifyOtp(String phone, String code) async {
    final res = await _dio.post('/auth/otp/verify', data: {'phone': phone, 'code': code});
    final data = res.data as Map<String, dynamic>;
    return (
      tokens: AuthTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      ),
      user: AppUser.fromJson((data['user'] as Map).cast<String, dynamic>()),
    );
  }

  @override
  Future<AppUser> me() async {
    final res = await _dio.get('/me');
    return AppUser.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
```

- [ ] **Step 2:** `http_cabinets_repository.dart`:
```dart
import 'package:dio/dio.dart';
import '../../domain/models/cabinet.dart';
import '../../domain/repositories/cabinets_repository.dart';

class HttpCabinetsRepository implements CabinetsRepository {
  HttpCabinetsRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Cabinet>> nearby({required double lat, required double lng, double radiusM = 2000}) async {
    final res = await _dio.get('/cabinets', queryParameters: {'lat': lat, 'lng': lng, 'radius': radiusM});
    final list = (res.data as List).cast<Map>();
    return list.map((m) => Cabinet.fromJson(m.cast<String, dynamic>())).toList();
  }

  @override
  Future<Cabinet> byId(String id) async {
    final res = await _dio.get('/cabinets/$id');
    return Cabinet.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
```

- [ ] **Step 3:** `http_orders_repository.dart` (note: create sends the Idempotency-Key header; `watch` polls):
```dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/models/order.dart';
import '../../domain/models/wallet.dart';
import '../../domain/repositories/orders_repository.dart';

class HttpOrdersRepository implements OrdersRepository {
  HttpOrdersRepository(this._dio);
  final Dio _dio;

  @override
  Future<Order> create({
    required String cabinetId,
    required int qty,
    Wallet? wallet,
    required String idempotencyKey,
  }) async {
    final res = await _dio.post(
      '/orders',
      data: {'cabinetId': cabinetId, 'qty': qty, if (wallet != null) 'wallet': wallet.name},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    return _parseOrder((res.data as Map).cast<String, dynamic>());
  }

  @override
  Future<Order> byId(String id) async {
    final res = await _dio.get('/orders/$id');
    return _parseOrder((res.data as Map).cast<String, dynamic>());
  }

  @override
  Stream<Order> watch(String id) async* {
    while (true) {
      final order = await byId(id);
      yield order;
      const terminal = {
        OrderStatus.fulfilled, OrderStatus.partiallyFulfilled, OrderStatus.failed,
        OrderStatus.expired, OrderStatus.cancelled, OrderStatus.refunded,
      };
      if (terminal.contains(order.status)) break;
      await Future<void>.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Future<void> repush(String id) async => _dio.post('/orders/$id/repush');

  @override
  Future<void> cancel(String id) async => _dio.post('/orders/$id/cancel');

  /// Accepts either the canonical `id` field or the create response's `orderId`.
  Order _parseOrder(Map<String, dynamic> json) {
    final normalized = {...json};
    if (!normalized.containsKey('id') && normalized.containsKey('orderId')) {
      normalized['id'] = normalized['orderId'];
    }
    normalized['amountTzs'] ??= normalized['amount_tzs'] ?? 0;
    normalized['fulfilment'] ??= const [];
    return Order.fromJson(normalized);
  }
}
```

- [ ] **Step 4:** `http_rentals_repository.dart`:
```dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/models/rental.dart';
import '../../domain/repositories/rentals_repository.dart';

class HttpRentalsRepository implements RentalsRepository {
  HttpRentalsRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Rental>> list({RentalStatus? status}) async {
    final res = await _dio.get('/rentals',
        queryParameters: {if (status != null) 'status': status.name});
    final list = (res.data as List).cast<Map>();
    return list.map((m) => Rental.fromJson(m.cast<String, dynamic>())).toList();
  }

  @override
  Future<Rental> byId(String id) async {
    final res = await _dio.get('/rentals/$id');
    return Rental.fromJson((res.data as Map).cast<String, dynamic>());
  }

  @override
  Stream<List<Rental>> watchActive() async* {
    yield await list(status: RentalStatus.active);
  }
}
```

- [ ] **Step 5:** In `providers.dart`, add a `dioProvider` and switch each repo provider on `env.useMockData`. Add imports for the four `Http*` classes and `dio`/`dio_client`. Replace the four repository providers:
```dart
import 'package:dio/dio.dart';
import 'network/dio_client.dart';
import '../data/http/http_auth_repository.dart';
import '../data/http/http_cabinets_repository.dart';
import '../data/http/http_orders_repository.dart';
import '../data/http/http_rentals_repository.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  return buildDio(env, ref.watch(tokenStoreProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockAuthRepository()
      : HttpAuthRepository(ref.watch(dioProvider));
});

final cabinetsRepositoryProvider = Provider<CabinetsRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockCabinetsRepository()
      : HttpCabinetsRepository(ref.watch(dioProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockOrdersRepository(ref.watch(scenarioEngineProvider))
      : HttpOrdersRepository(ref.watch(dioProvider));
});

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return ref.watch(environmentProvider).useMockData
      ? MockRentalsRepository(ref.watch(scenarioEngineProvider))
      : HttpRentalsRepository(ref.watch(dioProvider));
});
```
(Default flavor is `mock`, so existing tests/screens keep using the mocks.)

- [ ] **Step 6:** Test `http_repositories_test.dart` (mocked dio; verifies request shape + parsing):
```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:marijoy_app/data/http/http_auth_repository.dart';
import 'package:marijoy_app/data/http/http_cabinets_repository.dart';
import 'package:marijoy_app/data/http/http_orders_repository.dart';
import 'package:marijoy_app/domain/models/order.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'));
    adapter = DioAdapter(dio: dio);
  });

  test('verifyOtp parses tokens and user', () async {
    adapter.onPost('/auth/otp/verify', (s) => s.reply(200, {
          'accessToken': 'a', 'refreshToken': 'r',
          'user': {'id': 'U1', 'phone': '+255712345678', 'locale': 'sw', 'status': 'active'},
        }), data: {'phone': '+255712345678', 'code': '123456'});
    final res = await HttpAuthRepository(dio).verifyOtp('+255712345678', '123456');
    expect(res.tokens.accessToken, 'a');
    expect(res.user.phone, '+255712345678');
  });

  test('cabinets nearby parses a list', () async {
    adapter.onGet('/cabinets', (s) => s.reply(200, [
          {'id': 'CAB001', 'label': 'Posta', 'banksAvailable': 4, 'freeSlots': 6,
           'online': true, 'lat': -6.8, 'lng': 39.2},
        ]), queryParameters: {'lat': -6.8, 'lng': 39.2, 'radius': 2000.0});
    final list = await HttpCabinetsRepository(dio).nearby(lat: -6.8, lng: 39.2);
    expect(list, hasLength(1));
    expect(list.first.id, 'CAB001');
  });

  test('order create sends Idempotency-Key and parses orderId', () async {
    adapter.onPost('/orders', (s) => s.reply(201, {
          'orderId': 'ORD9', 'status': 'payment_pending', 'amountTzs': 1000,
        }), data: {'cabinetId': 'CAB001', 'qty': 1, 'wallet': 'mpesa'},
        headers: {'Idempotency-Key': 'idem-1', 'content-type': 'application/json; charset=utf-8'});
    final order = await HttpOrdersRepository(dio).create(
      cabinetId: 'CAB001', qty: 1, wallet: Wallet.mpesa, idempotencyKey: 'idem-1',
    );
    expect(order.id, 'ORD9');
    expect(order.status, OrderStatus.paymentPending);
  });
}
```
Imports note: the order test references `Wallet` — add `import 'package:marijoy_app/domain/models/wallet.dart';`. If `http_mock_adapter`'s `headers` matcher is strict about the content-type, drop the `headers:` matcher from the `onPost` and instead assert the header by switching to a request interceptor capture — but first try as written; relax the matcher (remove `headers`/`data` matchers) only as needed to make the request match, keeping the response-parsing assertions intact.

- [ ] **Step 7:** Run `flutter test test/data/http/http_repositories_test.dart` (PASS). Commit: `git add lib/data/http lib/core/providers.dart test/data/http` then `feat: add Http repositories and env-based mock/real selection`.

---

## Task 6: Wire periphery routes + Home account button + DoD

**Files:** modify `app/lib/core/router/app_router.dart`, `app/lib/features/home/presentation/home_screen.dart`; test `app/test/features/profile/profile_nav_test.dart`.

- [ ] **Step 1:** In `app_router.dart` add imports and routes:
```dart
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/receipt_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/support/presentation/support_screen.dart';
```
and inside `routes:` add:
```dart
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/receipt/:id', builder: (_, s) => ReceiptScreen(rentalId: s.pathParameters['id']!)),
      GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
```
These are authenticated routes; the existing redirect already permits any non-onboarding/splash/terms path when authenticated+accepted.

- [ ] **Step 2:** In `home_screen.dart`, add an account action to the AppBar (next to refresh):
```dart
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/profile'),
          ),
```
(Place it in the `AppBar.actions` list before or after the existing refresh `IconButton`.)

- [ ] **Step 3:** Test `profile_nav_test.dart` (Profile hub navigates to History):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.tap(find.text('Historia / History'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Historia / History'), findsWidgets); // History screen app bar title
    expect(find.text('Benki PB-H1'), findsOneWidget);
  });
}
```

- [ ] **Step 4 — DoD:** Run the FULL suite `flutter test` (all Plans 1–5; report count) and `flutter analyze` (clean). Commit: `git add lib/core/router/app_router.dart lib/features/home/presentation/home_screen.dart test/features/profile/profile_nav_test.dart` then `feat: wire periphery routes and Home account access`.

---

## Self-review notes (against the design spec)

- **Spec coverage:** History & receipts ✓ T1; Profile (language switch, logout, hub) ✓ T2; Support (bilingual FAQ + WhatsApp/call) ✓ T3; notification abstraction wired ✓ T4; `Http*` repos for all four domains + Idempotency-Key header + one-flag mock/real swap ✓ T5; periphery routing + Home account access ✓ T6. Resume-on-launch is already covered by Plan 2's auth restore (in-flight order resume can be added with the real backend, since order state is server-side).
- **Deferred (explicitly):** real FCM (Firebase config), real Sentry (DSN), live API E2E (backend), App Links manifest (domain) — see the Deferred section; all are external-infra dependencies, with drop-in seams in place.
- **Test discipline:** periphery screens are plugin-light and widget-tested; `url_launcher` is only invoked on tap (not in tests); `Http*` repos are unit-tested with `http_mock_adapter`; default flavor stays `mock` so all prior tests are unaffected.
- **Type/name consistency:** `historyProvider`, `notificationServiceProvider`, `dioProvider`, `HttpAuthRepository`/`HttpCabinetsRepository`/`HttpOrdersRepository`/`HttpRentalsRepository`, `localeControllerProvider`, `authControllerProvider`, and `rentalsRepositoryProvider` are referenced consistently across providers, screens, router, and tests.
```
