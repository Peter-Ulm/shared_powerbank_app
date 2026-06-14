# MariJoy App — Rental Loop Implementation Plan (Plan 4 of 5)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** The core revenue loop, end to end on the mock backend: from a cabinet, the user picks quantity + wallet and pays (idempotent order), watches the payment-wait screen (poll + resend + "I already paid" + Lipa-Namba fallback, **never a PIN field**), sees per-bank ejection progress, then lands on live 5-hour `RentalTimerCard`s in a rentals list.

**Architecture:** Builds on Plans 1–3. The existing mock `ScenarioEngine` already drives `createOrder → fulfilling → ejected → rental active` on timers and exposes order/rentals streams; this plan builds the UI + controllers on top: a Checkout screen, an Order screen that renders the right sub-view per `OrderStatus`, a `RentalTimerCard`, and a Rentals list. Pure helpers (wallet detection, TZS formatting, time formatting/urgency) are isolated and unit-tested; plugin-free.

**Tech Stack:** Plans 1–3 stack. No new dependencies.

**Reference:** `docs/specs/2026-06-13-mobile-app-design.md` §3 screens 4–8, §2 (scenario engine); `docs/payments-tanzania.md` §3 (USSD push UX), §5 (pricing); `Powerbank_shared/SPEC.md` §4 (flow), §6 (orders/rentals), invariants 1 & 4 (never eject before paid; never ask for PIN).

**Prerequisite:** Plan 3 merged (discovery on `main`, 50 tests green). Modifies `lib/core/router/app_router.dart` (replace `/c/:deviceId`, `/orders/:id`, `/rentals` placeholders).

**Environment note for implementers:** Flutter at `C:\Users\USER\flutter\bin` is NOT on PATH for fresh shells — prepend `$env:Path = "C:\Users\USER\flutter\bin;$env:Path"` in every PowerShell command. Work in `C:\Users\USER\Desktop\shared_powerbank_app`, package `marijoy_app`, dir `app/`. Branch `feat/rental-loop`. **Widget tests for screens that show a countdown or watch the scenario engine MUST use `pump(Duration)` not `pumpAndSettle()` (periodic timers never settle).**

---

## File structure built by this plan

```
app/lib/
├── core/
│   ├── format/money.dart                 # Task 1 (NEW)
│   ├── format/duration_format.dart       # Task 4 (NEW)
│   ├── payments/wallet_detect.dart       # Task 1 (NEW)
│   ├── util/idempotency.dart             # Task 2 (NEW)
│   └── router/app_router.dart            # MODIFY (Task 6)
├── features/
│   ├── checkout/presentation/
│   │   ├── checkout_providers.dart       # Task 2 (NEW)
│   │   └── checkout_screen.dart          # Task 2 (NEW)
│   ├── order/presentation/
│   │   ├── order_providers.dart          # Task 3 (NEW)
│   │   ├── order_screen.dart             # Task 3 (NEW)
│   │   ├── payment_wait_view.dart        # Task 3 (NEW)
│   │   ├── ejection_progress_view.dart   # Task 3 (NEW)
│   │   └── order_result_view.dart        # Task 3 (NEW)
│   └── rental/presentation/
│       ├── rental_timer_card.dart        # Task 4 (NEW)
│       ├── rentals_controller.dart       # Task 5 (NEW)
│       └── rentals_screen.dart           # Task 5 (NEW)
```

---

## Task 1: Pure helpers — TZS money + wallet detection

**Files:** Create `app/lib/core/format/money.dart`, `app/lib/core/payments/wallet_detect.dart`; tests `app/test/core/format/money_test.dart`, `app/test/core/payments/wallet_detect_test.dart`.

- [ ] **Step 1:** Write `money.dart`:
```dart
/// Formats an integer TZS amount as 'TZS 1,000' (no decimals; thousands grouped).
String formatTzs(int amount) {
  final neg = amount < 0;
  final s = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'TZS ${neg ? '-' : ''}$buf';
}
```

- [ ] **Step 2:** Write `wallet_detect.dart`:
```dart
import '../../domain/models/wallet.dart';

/// Maps a TZS E.164 MSISDN (+255XXXXXXXXX) to its default mobile-money wallet
/// by the 2-digit national prefix. Configurable map; user can always override.
/// (Prefixes per docs/payments-tanzania.md §3.)
const Map<String, Wallet> kWalletPrefixes = {
  '74': Wallet.mpesa, '75': Wallet.mpesa, '76': Wallet.mpesa,
  '65': Wallet.mixx, '67': Wallet.mixx, '71': Wallet.mixx,
  '68': Wallet.airtel, '69': Wallet.airtel, '78': Wallet.airtel,
  '61': Wallet.halopesa, '62': Wallet.halopesa,
};

Wallet? detectWallet(String e164) {
  final m = RegExp(r'^\+255(\d{2})').firstMatch(e164);
  if (m == null) return null;
  return kWalletPrefixes[m.group(1)];
}
```

- [ ] **Step 3:** Tests. `money_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/format/money.dart';

void main() {
  test('formats thousands', () {
    expect(formatTzs(500), 'TZS 500');
    expect(formatTzs(1000), 'TZS 1,000');
    expect(formatTzs(2500000), 'TZS 2,500,000');
  });
}
```
`wallet_detect_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/payments/wallet_detect.dart';
import 'package:marijoy_app/domain/models/wallet.dart';

void main() {
  test('detects wallet by prefix', () {
    expect(detectWallet('+255712345678'), Wallet.mixx);
    expect(detectWallet('+255745000000'), Wallet.mpesa);
    expect(detectWallet('+255682000000'), Wallet.airtel);
    expect(detectWallet('+255612000000'), Wallet.halopesa);
  });
  test('returns null for unknown prefix or bad input', () {
    expect(detectWallet('+255500000000'), isNull);
    expect(detectWallet('garbage'), isNull);
  });
}
```

- [ ] **Step 4:** Run both test files (PASS: 1 + 2). Commit: `git add lib/core/format/money.dart lib/core/payments/wallet_detect.dart test/core/format/money_test.dart test/core/payments` then `feat: add TZS money format and wallet prefix detection`.

---

## Task 2: Checkout screen

**Files:** Create `app/lib/core/util/idempotency.dart`, `app/lib/features/checkout/presentation/checkout_providers.dart`, `checkout_screen.dart`; test `app/test/features/checkout/checkout_screen_test.dart`.

- [ ] **Step 1:** Write `idempotency.dart`:
```dart
import 'dart:math';

/// Generates a unique idempotency key for one checkout attempt.
String newIdempotencyKey() {
  final ts = DateTime.now().microsecondsSinceEpoch;
  final rand = Random().nextInt(1 << 32);
  return '$ts-$rand';
}
```

- [ ] **Step 2:** Write `checkout_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/cabinet.dart';

/// Loads a cabinet's live detail/availability for checkout.
final cabinetDetailProvider = FutureProvider.family<Cabinet, String>((ref, id) {
  return ref.read(cabinetsRepositoryProvider).byId(id);
});
```

- [ ] **Step 3:** Write `checkout_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/format/money.dart';
import '../../../core/payments/wallet_detect.dart';
import '../../../core/providers.dart';
import '../../../core/util/idempotency.dart';
import '../../../domain/models/cabinet.dart';
import '../../../domain/models/wallet.dart';
import '../../onboarding/presentation/auth_controller.dart';
import 'checkout_providers.dart';

const kPerUserMaxBanks = 3;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.cabinetId});
  final String cabinetId;
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _qty = 1;
  Wallet? _wallet;
  bool _walletInitialized = false;
  bool _submitting = false;

  String? get _userPhone => ref
      .read(authControllerProvider)
      .maybeWhen(authenticated: (u) => u.phone, orElse: () => null);

  Future<void> _pay(Cabinet cabinet) async {
    setState(() => _submitting = true);
    try {
      final order = await ref.read(ordersRepositoryProvider).create(
            cabinetId: cabinet.id,
            qty: _qty,
            wallet: _wallet,
            idempotencyKey: newIdempotencyKey(),
          );
      if (mounted) context.go('/orders/${order.id}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(cabinetDetailProvider(widget.cabinetId));
    return Scaffold(
      appBar: AppBar(title: const Text('Kodisha / Rent')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Imeshindikana kupata cabinet.')),
        data: (cabinet) {
          if (!cabinet.online) {
            return const Center(child: Text('Cabinet hii haipo mtandaoni / offline'));
          }
          final maxQty = cabinet.banksAvailable < kPerUserMaxBanks
              ? cabinet.banksAvailable
              : kPerUserMaxBanks;
          if (maxQty < 1) {
            return const Center(child: Text('Hakuna benki / No banks available'));
          }
          if (_qty > maxQty) _qty = maxQty;
          if (!_walletInitialized) {
            final phone = _userPhone;
            _wallet = phone == null ? null : detectWallet(phone);
            _walletInitialized = true;
          }
          final unit = cabinet.unitPriceTzs ?? 0;
          final total = unit * _qty;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(cabinet.label, style: Theme.of(context).textTheme.titleLarge),
                Text('Benki ${cabinet.banksAvailable} • Nafasi ${cabinet.freeSlots}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Idadi / Quantity'),
                    Row(children: [
                      IconButton(
                        key: const Key('qtyMinus'),
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_qty', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        key: const Key('qtyPlus'),
                        onPressed: _qty < maxQty ? () => setState(() => _qty++) : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Wallet>(
                  initialValue: _wallet,
                  decoration: const InputDecoration(labelText: 'Mtandao wa pesa / Wallet'),
                  items: Wallet.values
                      .map((w) => DropdownMenuItem(value: w, child: Text(w.name.toUpperCase())))
                      .toList(),
                  onChanged: (w) => setState(() => _wallet = w),
                ),
                const Spacer(),
                Text('Jumla / Total: ${formatTzs(total)}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: (_submitting || _wallet == null) ? null : () => _pay(cabinet),
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Lipa / Pay ${formatTzs(total)}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4:** Test `checkout_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/checkout/presentation/checkout_screen.dart';

void main() {
  testWidgets('shows total, steps quantity, and pays to the order route', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const CheckoutScreen(cabinetId: 'CAB001')),
      GoRoute(path: '/orders/:id', builder: (_, s) => Scaffold(body: Text('ORDER ${s.pathParameters['id']}'))),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // CAB001 unit price 1000, qty 1 -> total 1,000
    expect(find.text('Jumla / Total: TZS 1,000'), findsOneWidget);
    // step up to 2
    await tester.tap(find.byKey(const Key('qtyPlus')));
    await tester.pump();
    expect(find.text('Jumla / Total: TZS 2,000'), findsOneWidget);

    // Default wallet is unset (no auth user) -> pick one to enable Pay.
    await tester.tap(find.byType(DropdownButtonFormField<dynamic>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MPESA').last);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Lipa / Pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('ORDER'), findsOneWidget);
  });
}
```
NOTE: the order created by the mock has an id like `ORD001`; the route shows `ORDER ORD001`. If the dropdown interaction is flaky, you may instead override the auth user so a wallet auto-selects — but the above (manual pick) should work. Keep the assertions.

- [ ] **Step 5:** Run `flutter test test/features/checkout/checkout_screen_test.dart` (PASS). Commit: `git add lib/core/util/idempotency.dart lib/features/checkout test/features/checkout` then `feat: add Checkout screen with qty, wallet, idempotent order`.

---

## Task 3: Order screen (payment-wait → ejection → result)

**Files:** Create `app/lib/features/order/presentation/order_providers.dart`, `order_screen.dart`, `payment_wait_view.dart`, `ejection_progress_view.dart`, `order_result_view.dart`; tests `app/test/features/order/payment_wait_view_test.dart`, `app/test/features/order/order_flow_test.dart`.

- [ ] **Step 1:** `order_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/order.dart';

/// Streams an order's live status from the (mock) backend.
final orderStreamProvider = StreamProvider.family<Order, String>((ref, id) {
  return ref.read(ordersRepositoryProvider).watch(id);
});
```

- [ ] **Step 2:** `payment_wait_view.dart` (NO PIN field — invariant 4):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/format/money.dart';
import '../../../core/providers.dart';
import '../../../domain/models/order.dart';

class PaymentWaitView extends ConsumerWidget {
  const PaymentWaitView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(ordersRepositoryProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phonelink_ring, size: 72),
          const SizedBox(height: 16),
          Text('Angalia simu yako, weka namba yako ya siri',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Check your phone and enter your PIN', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Kiasi / Amount: ${formatTzs(order.amountTzs)}'),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => repo.repush(order.id),
            child: const Text('Tuma ombi tena / Resend prompt'),
          ),
          TextButton(
            onPressed: () => repo.byId(order.id), // force a status re-check
            child: const Text('Nimelipa / I already paid'),
          ),
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Lipa kwa Lipa Namba'),
                content: Text('Lipa Namba: 555111\nKumbukumbu / Ref: ${order.id}'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sawa')),
                ],
              ),
            ),
            child: const Text('Lipa kwa njia nyingine / Pay another way'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3:** `ejection_progress_view.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../domain/models/order.dart';

class EjectionProgressView extends StatelessWidget {
  const EjectionProgressView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Inatoa benki / Ejecting',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final u in order.fulfilment)
            ListTile(
              leading: _iconFor(u.status),
              title: Text('Benki ${u.unit}'),
              subtitle: Text(_labelFor(u)),
            ),
        ],
      ),
    );
  }

  Widget _iconFor(FulfilmentStatus s) {
    switch (s) {
      case FulfilmentStatus.ejected:
        return const Icon(Icons.check_circle, color: Colors.green);
      case FulfilmentStatus.failed:
      case FulfilmentStatus.refunded:
        return const Icon(Icons.error, color: Colors.red);
      case FulfilmentStatus.pending:
      case FulfilmentStatus.ejecting:
        return const SizedBox(
            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }
  }

  String _labelFor(FulfilmentUnit u) {
    switch (u.status) {
      case FulfilmentStatus.ejected:
        return 'Mlango ${u.slot} • imetoka';
      case FulfilmentStatus.failed:
        return 'Imeshindikana — umerejeshewa';
      case FulfilmentStatus.refunded:
        return 'Umerejeshewa';
      case FulfilmentStatus.pending:
      case FulfilmentStatus.ejecting:
        return 'Subiri / Please wait';
    }
  }
}
```

- [ ] **Step 4:** `order_result_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/order.dart';

class OrderResultView extends StatelessWidget {
  const OrderResultView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final failed = order.status == OrderStatus.failed ||
        order.status == OrderStatus.expired ||
        order.status == OrderStatus.cancelled;
    if (failed) {
      return _Centered(
        icon: Icons.cancel,
        color: Colors.red,
        title: 'Malipo hayakukamilika',
        subtitle: 'Payment did not complete.',
        buttonLabel: 'Rudi nyumbani / Home',
        onPressed: () => context.go('/home'),
      );
    }
    final partial = order.status == OrderStatus.partiallyFulfilled;
    return _Centered(
      icon: Icons.bolt,
      color: Colors.green,
      title: partial ? 'Baadhi ya benki zimetoka' : 'Benki zako ziko tayari!',
      subtitle: partial
          ? 'Some banks failed and were refunded.'
          : 'Your power bank(s) are ready.',
      buttonLabel: 'Tazama kukodi / View rentals',
      onPressed: () => context.go('/rentals'),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: color),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5:** `order_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/order.dart';
import 'ejection_progress_view.dart';
import 'order_providers.dart';
import 'order_result_view.dart';
import 'payment_wait_view.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderStreamProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Malipo / Payment'), automaticallyImplyLeading: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (order) {
          switch (order.status) {
            case OrderStatus.created:
            case OrderStatus.paymentPending:
            case OrderStatus.paid:
              return PaymentWaitView(order: order);
            case OrderStatus.fulfilling:
              return EjectionProgressView(order: order);
            case OrderStatus.fulfilled:
            case OrderStatus.partiallyFulfilled:
            case OrderStatus.failed:
            case OrderStatus.expired:
            case OrderStatus.cancelled:
            case OrderStatus.refundPending:
            case OrderStatus.refunded:
              return OrderResultView(order: order);
          }
        },
      ),
    );
  }
}
```

- [ ] **Step 6:** Test `payment_wait_view_test.dart` (the no-PIN invariant + key actions render):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/features/order/presentation/payment_wait_view.dart';

void main() {
  testWidgets('shows check-phone copy and resend, and has NO PIN field', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: PaymentWaitView(
            order: const Order(id: 'ORD001', status: OrderStatus.paymentPending, amountTzs: 1000),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('Check your phone'), findsOneWidget);
    expect(find.textContaining('Resend prompt'), findsOneWidget);
    // Invariant 4: the app NEVER collects the mobile-money PIN.
    expect(find.byType(TextField), findsNothing);
  });
}
```

- [ ] **Step 7:** Test `order_flow_test.dart` (drives the scenario engine via pumped durations; tick=2s):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/features/order/presentation/order_screen.dart';

void main() {
  testWidgets('payment-wait -> ejection -> result', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Create an order in the engine so the screen can watch it.
    final order = await container.read(ordersRepositoryProvider).create(
          cabinetId: 'CAB001', qty: 1, idempotencyKey: 'k1',
        );

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => OrderScreen(orderId: order.id)),
      GoRoute(path: '/rentals', builder: (_, __) => const Scaffold(body: Text('RENTALS'))),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    expect(find.textContaining('Check your phone'), findsOneWidget);

    // Engine: ~2s -> fulfilling, ~4s -> ejected/fulfilled. Advance with pumps.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('Ejecting'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('ready'), findsOneWidget); // 'Your power bank(s) are ready.'
  });
}
```

- [ ] **Step 8:** Run `flutter test test/features/order/` (both files PASS). Commit: `git add lib/features/order test/features/order` then `feat: add Order screen (payment-wait, ejection, result)`.

---

## Task 4: RentalTimerCard

**Files:** Create `app/lib/core/format/duration_format.dart`, `app/lib/features/rental/presentation/rental_timer_card.dart`; tests `app/test/core/format/duration_format_test.dart`, `app/test/features/rental/rental_timer_card_test.dart`.

- [ ] **Step 1:** `duration_format.dart`:
```dart
import 'package:flutter/material.dart';

/// Formats a non-negative duration as 'H:MM:SS' (clamped at zero).
String formatHms(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return '$h:${two(m)}:${two(s)}';
}

enum RentalUrgency { normal, warning, critical }

/// green > 60 min left; marigold within 60 min; red within 15 min or overdue.
RentalUrgency urgencyFor(Duration remaining) {
  if (remaining.inMinutes <= 15) return RentalUrgency.critical;
  if (remaining.inMinutes <= 60) return RentalUrgency.warning;
  return RentalUrgency.normal;
}

Color colorForUrgency(RentalUrgency u) {
  switch (u) {
    case RentalUrgency.normal:
      return const Color(0xFF0E9F6E); // Charge Green
    case RentalUrgency.warning:
      return const Color(0xFFF59E0B); // Marigold
    case RentalUrgency.critical:
      return const Color(0xFFDC2626); // Error red
  }
}
```

- [ ] **Step 2:** `rental_timer_card.dart`:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/format/duration_format.dart';
import '../../../domain/models/rental.dart';

/// Renders a per-bank 5-hour countdown from server timestamps. The `now`
/// parameter is injectable for tests; production uses the wall clock.
class RentalTimerCard extends StatefulWidget {
  const RentalTimerCard({super.key, required this.rental, this.onReportBad, DateTime Function()? now})
      : _now = now;
  final Rental rental;
  final VoidCallback? onReportBad;
  final DateTime Function()? _now;

  @override
  State<RentalTimerCard> createState() => _RentalTimerCardState();
}

class _RentalTimerCardState extends State<RentalTimerCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget._now == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = (widget._now ?? DateTime.now)();
    final remaining = widget.rental.dueAt.difference(now);
    final overdue = remaining.isNegative;
    final urgency = urgencyFor(remaining);
    final color = colorForUrgency(urgency);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Benki ${widget.rental.powerbankId}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              overdue ? 'Imechelewa / Overdue' : formatHms(remaining),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.onReportBad != null)
                  TextButton.icon(
                    onPressed: widget.onReportBad,
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: const Text('Ripoti benki mbovu'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3:** Tests. `duration_format_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/format/duration_format.dart';

void main() {
  test('formats H:MM:SS and clamps negatives', () {
    expect(formatHms(const Duration(hours: 5)), '5:00:00');
    expect(formatHms(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    expect(formatHms(const Duration(seconds: -10)), '0:00:00');
  });
  test('urgency thresholds', () {
    expect(urgencyFor(const Duration(hours: 2)), RentalUrgency.normal);
    expect(urgencyFor(const Duration(minutes: 45)), RentalUrgency.warning);
    expect(urgencyFor(const Duration(minutes: 10)), RentalUrgency.critical);
    expect(urgencyFor(const Duration(seconds: -5)), RentalUrgency.critical);
  });
}
```
`rental_timer_card_test.dart` (inject `now` to avoid the live ticker):
```dart
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
```

- [ ] **Step 4:** Run `flutter test test/core/format/duration_format_test.dart test/features/rental/rental_timer_card_test.dart` (PASS). Commit: `git add lib/core/format/duration_format.dart lib/features/rental/presentation/rental_timer_card.dart test/core/format/duration_format_test.dart test/features/rental` then `feat: add RentalTimerCard with countdown and urgency`.

---

## Task 5: Rentals list

**Files:** Create `app/lib/features/rental/presentation/rentals_controller.dart`, `rentals_screen.dart`; test `app/test/features/rental/rentals_screen_test.dart`.

- [ ] **Step 1:** `rentals_controller.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/rental.dart';

class RentalsController extends AsyncNotifier<List<Rental>> {
  @override
  Future<List<Rental>> build() =>
      ref.read(rentalsRepositoryProvider).list(status: RentalStatus.active);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(rentalsRepositoryProvider).list(status: RentalStatus.active));
  }
}

final rentalsControllerProvider =
    AsyncNotifierProvider<RentalsController, List<Rental>>(RentalsController.new);
```

- [ ] **Step 2:** `rentals_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'rental_timer_card.dart';
import 'rentals_controller.dart';

class RentalsScreen extends ConsumerWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rentalsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kukodi kwangu / My rentals'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (rentals) => rentals.isEmpty
            ? const Center(child: Text('Huna kukodi kwa sasa / No active rentals'))
            : ListView(
                children: [
                  for (final r in rentals)
                    RentalTimerCard(
                      rental: r,
                      onReportBad: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Imepokelewa / Reported')),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
```

- [ ] **Step 3:** Test `rentals_screen_test.dart` (seed a rental via the engine, then show the list; use pump not pumpAndSettle — the card ticks):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/features/rental/presentation/rental_timer_card.dart';
import 'package:marijoy_app/features/rental/presentation/rentals_screen.dart';

void main() {
  testWidgets('lists active rentals as timer cards', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Drive the engine to produce one active rental.
    await container.read(ordersRepositoryProvider).create(
          cabinetId: 'CAB001', qty: 1, idempotencyKey: 'k1',
        );
    // Let the engine's timers run to activate the rental.
    await Future<void>.delayed(const Duration(seconds: 6));

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const RentalsScreen()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(RentalTimerCard), findsOneWidget);
  });
}
```
NOTE: the `Future.delayed(6s)` runs in real time inside `testWidgets` (outside `pump`) so the engine's real `Timer`s fire; this is acceptable here. If it proves flaky, instead seed the rental by reading `rentalsRepositoryProvider` after pumping the order screen — but the delayed approach is simplest and deterministic enough (engine tick = 2s, rental active by ~4s).

- [ ] **Step 4:** Run `flutter test test/features/rental/rentals_screen_test.dart` (PASS). Commit: `git add lib/features/rental/presentation/rentals_controller.dart lib/features/rental/presentation/rentals_screen.dart test/features/rental/rentals_screen_test.dart` then `feat: add Rentals list with timer cards and report-bad-bank`.

---

## Task 6: Wire routes + integration + DoD

**Files:** modify `app/lib/core/router/app_router.dart`; test `app/test/features/order/rental_loop_integration_test.dart`.

- [ ] **Step 1:** In `app_router.dart` add imports and replace the three placeholders:
```dart
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/order/presentation/order_screen.dart';
import '../../features/rental/presentation/rentals_screen.dart';
```
and:
```dart
      GoRoute(path: '/c/:deviceId', builder: (_, s) => CheckoutScreen(cabinetId: s.pathParameters['deviceId']!)),
      GoRoute(path: '/orders/:id', builder: (_, s) => OrderScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/rentals', builder: (_, __) => const RentalsScreen()),
```
Remove the now-unused `_Placeholder` only if no routes still use it (`/orders` and `/rentals` and `/c` are replaced; if `_Placeholder` is unused, delete the class to satisfy analyze; if any route still uses it, keep it).

- [ ] **Step 2:** Integration test `rental_loop_integration_test.dart` (checkout → pay → eject → result → rentals):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/features/checkout/presentation/checkout_screen.dart';
import 'package:marijoy_app/features/order/presentation/order_screen.dart';
import 'package:marijoy_app/features/rental/presentation/rental_timer_card.dart';
import 'package:marijoy_app/features/rental/presentation/rentals_screen.dart';

void main() {
  testWidgets('checkout -> pay -> eject -> result -> rentals', (tester) async {
    final router = GoRouter(initialLocation: '/c/CAB001', routes: [
      GoRoute(path: '/c/:deviceId', builder: (_, s) => CheckoutScreen(cabinetId: s.pathParameters['deviceId']!)),
      GoRoute(path: '/orders/:id', builder: (_, s) => OrderScreen(orderId: s.pathParameters['id']!)),
      GoRoute(path: '/rentals', builder: (_, __) => const RentalsScreen()),
      GoRoute(path: '/home', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    ]);
    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Pick a wallet, then pay.
    await tester.tap(find.byType(DropdownButtonFormField<dynamic>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MPESA').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Lipa / Pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Check your phone'), findsOneWidget);

    // Advance the engine through ejection to result.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('Ejecting'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.textContaining('ready'), findsOneWidget);

    // Go to rentals.
    await tester.tap(find.textContaining('View rentals'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RentalTimerCard), findsOneWidget);
  });
}
```

- [ ] **Step 3 — DoD:** Run the FULL suite `flutter test` (all Plans 1–4; report count) and `flutter analyze` (clean). Commit: `git add lib/core/router/app_router.dart test/features/order/rental_loop_integration_test.dart` then `feat: wire rental-loop routes and add integration test`.

---

## Self-review notes (against the design spec)

- **Spec coverage:** Checkout with live availability + qty stepper (1..min(available,3)) + wallet auto-detect/override + price ✓ T2; idempotent order creation (Idempotency-Key) ✓ T2 (invariant 3); payment-wait with resend / I-already-paid / Lipa-Namba and **no PIN field** ✓ T3 (invariant 4); per-bank ejection progress incl. partial/refund labels ✓ T3 (§9 #1/#9); success/partial/failed results ✓ T3; 5-hour `RentalTimerCard` from server timestamps with green→marigold→red urgency + overdue ✓ T4 (invariant 7); rentals list + report-bad-bank ✓ T5 (§9 #20); full loop wired ✓ T6.
- **Deferred (noted):** real polling cadence/SSE and true repush semantics (mock engine drives transitions on timers); overage collection at return, reminders (T-60/T-15 push), and return/RS handling are server-driven and land with the real backend (Plan 5) + FCM; "report bad bank" shows a mock acknowledgement (real flag/refund endpoint in Plan 5).
- **Test discipline:** screens with countdowns or engine watches use `pump(Duration)` (never `pumpAndSettle`); pure helpers (money, wallet, duration/urgency) are unit-tested; `PaymentWaitView` asserts the no-PIN invariant.
- **Type/name consistency:** `cabinetDetailProvider`, `orderStreamProvider`, `rentalsControllerProvider`, `ordersRepositoryProvider`, `rentalsRepositoryProvider`, `OrderStatus`/`FulfilmentStatus`/`RentalStatus`, `formatTzs`, `detectWallet`, `formatHms`, `urgencyFor` are used consistently across controllers, screens, router, and tests.
```
