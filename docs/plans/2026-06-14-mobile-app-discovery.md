# MariJoy App — Discovery (Map + Scan) Implementation Plan (Plan 3 of 5)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** After login, the user sees a Home screen with a map (OSM via `flutter_map`) and a distance-sorted list of nearby cabinets (each a `CabinetCard` with availability), and can open a Scan screen to scan a cabinet QR (or type its code / arrive via a `/c/{deviceId}` deep link) which routes to checkout.

**Architecture:** Builds on Plans 1–2. Adds a `LocationService` (mock fixed coords now, real geolocator later), a pure cabinet-link parser, a `HomeController` (`AsyncNotifier<List<Cabinet>>`) backed by the existing `CabinetsRepository` mock, a reusable `CabinetCard`, the Home and Scan screens (replacing the Plan-2 router placeholders), and the navigation between them. Camera/map plugins are kept at the edges so the testable logic (parser, controller, cards, manual code entry) is plugin-free.

**Tech Stack:** Plans 1–2 stack, plus `flutter_map` + `latlong2` (OSM map, no Google billing) and `mobile_scanner` (QR).

**Reference:** `docs/specs/2026-06-13-mobile-app-design.md` §3 screens 2–3, §10 (returns UX / availability); `Powerbank_shared/SPEC.md` §6 (`GET /cabinets`), §8 (QR carries deviceId only).

**Prerequisite:** Plan 2 merged (auth on `main`, 39 tests green). This plan modifies `lib/core/router/app_router.dart` (replace `/home` and `/scan` placeholders).

**Environment note for implementers:** Flutter is at `C:\Users\USER\flutter\bin` and is NOT on PATH for fresh shells — prepend `$env:Path = "C:\Users\USER\flutter\bin;$env:Path"` in every PowerShell command. Work in `C:\Users\USER\Desktop\shared_powerbank_app`, package `marijoy_app`, project dir `app/`. Branch: `feat/discovery`.

---

## File structure built by this plan

```
app/lib/
├── core/
│   ├── location/location_service.dart       # Task 2 (NEW)
│   ├── deeplink/cabinet_link.dart           # Task 3 (NEW, pure)
│   ├── providers.dart                       # MODIFY (Tasks 2,4)
│   └── router/app_router.dart               # MODIFY (Task 7)
├── features/
│   ├── home/presentation/
│   │   ├── home_controller.dart             # Task 4 (NEW)
│   │   ├── cabinet_card.dart                # Task 5 (NEW)
│   │   └── home_screen.dart                 # Task 6 (NEW)
│   └── scan/presentation/
│       ├── cabinet_code_field.dart          # Task 7 (NEW, testable manual entry)
│       └── scan_screen.dart                 # Task 7 (NEW)
```

---

## Task 1: Add dependencies

**Files:** modify `app/pubspec.yaml` (via `flutter pub add`).

- [ ] **Step 1:** From `app/` (PATH prepended) run:
```
flutter pub add flutter_map latlong2 mobile_scanner
```
This selects compatible versions automatically. Expected: resolves and writes them to `pubspec.yaml`.

- [ ] **Step 2:** Run `flutter pub get` (if not already) and `flutter analyze` — expect no NEW issues. Commit: `git add pubspec.yaml pubspec.lock` then `chore: add flutter_map, latlong2, mobile_scanner`.

---

## Task 2: LocationService

**Files:** Create `app/lib/core/location/location_service.dart`; modify `app/lib/core/providers.dart`; test `app/test/core/location/location_service_test.dart`.

- [ ] **Step 1:** Write `location_service.dart`:
```dart
/// A simple lat/lng point (decoupled from any map/geo package).
class LatLngPoint {
  const LatLngPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

abstract class LocationService {
  Future<LatLngPoint> current();
}

/// Fixed Dar es Salaam city-centre location. A real geolocator-backed impl
/// (with permission handling) replaces this in a later plan.
class MockLocationService implements LocationService {
  const MockLocationService();
  @override
  Future<LatLngPoint> current() async => const LatLngPoint(-6.776, 39.178);
}
```

- [ ] **Step 2:** In `providers.dart` add `import 'location/location_service.dart';` and:
```dart
final locationServiceProvider = Provider<LocationService>((ref) => const MockLocationService());
```

- [ ] **Step 3:** Test `location_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/location/location_service.dart';

void main() {
  test('mock location returns Dar es Salaam coords', () async {
    const svc = MockLocationService();
    final p = await svc.current();
    expect(p.lat, closeTo(-6.78, 0.05));
    expect(p.lng, closeTo(39.18, 0.05));
  });
}
```

- [ ] **Step 4:** Run `flutter test test/core/location/location_service_test.dart` (PASS, 1 test). Commit: `git add lib/core/location lib/core/providers.dart test/core/location` then `feat: add LocationService with mock Dar location`.

---

## Task 3: Cabinet link/QR parser (pure)

**Files:** Create `app/lib/core/deeplink/cabinet_link.dart`; test `app/test/core/deeplink/cabinet_link_test.dart`.

- [ ] **Step 1:** Test `cabinet_link_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/deeplink/cabinet_link.dart';

void main() {
  test('parses deviceId from a full deep-link URL', () {
    expect(parseCabinetId('https://app.marijoy.co.tz/c/CAB001'), 'CAB001');
    expect(parseCabinetId('https://app.marijoy.co.tz/c/CAB001?x=1'), 'CAB001');
  });
  test('parses a path-only deep link', () {
    expect(parseCabinetId('/c/CAB002'), 'CAB002');
  });
  test('accepts a bare device code', () {
    expect(parseCabinetId('CAB003'), 'CAB003');
    expect(parseCabinetId('  cab003  '), 'CAB003'); // trimmed + upper-cased
  });
  test('rejects junk', () {
    expect(parseCabinetId(''), isNull);
    expect(parseCabinetId('https://example.com/foo'), isNull);
    expect(parseCabinetId('hello world'), isNull);
  });
}
```

- [ ] **Step 2:** Run to confirm FAIL.

- [ ] **Step 3:** Implement `cabinet_link.dart`:
```dart
/// Extracts a cabinet deviceId from a scanned QR string or deep link.
/// Accepts: 'https://<host>/c/{id}', '/c/{id}', or a bare '{id}'.
/// Device codes are alphanumeric (3–32 chars); returned upper-cased.
String? parseCabinetId(String input) {
  final raw = input.trim();
  if (raw.isEmpty) return null;

  String candidate = raw;
  final uri = Uri.tryParse(raw);
  if (uri != null && uri.pathSegments.isNotEmpty) {
    final segs = uri.pathSegments;
    final i = segs.indexOf('c');
    if (i != -1 && i + 1 < segs.length) {
      candidate = segs[i + 1];
    } else if (raw.contains('/')) {
      // A path/URL that doesn't contain a /c/{id} segment is not a cabinet link.
      return null;
    }
  }

  candidate = candidate.toUpperCase();
  if (RegExp(r'^[A-Z0-9]{3,32}$').hasMatch(candidate)) return candidate;
  return null;
}
```

- [ ] **Step 4:** Run `flutter test test/core/deeplink/cabinet_link_test.dart` (PASS, 4 tests). Commit: `git add lib/core/deeplink test/core/deeplink` then `feat: add cabinet QR/deep-link parser`.

---

## Task 4: HomeController (nearby cabinets)

**Files:** Create `app/lib/features/home/presentation/home_controller.dart`; test `app/test/features/home/home_controller_test.dart`.

- [ ] **Step 1:** Write `home_controller.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/cabinet.dart';

class HomeController extends AsyncNotifier<List<Cabinet>> {
  Future<List<Cabinet>> _load() async {
    final loc = await ref.read(locationServiceProvider).current();
    return ref.read(cabinetsRepositoryProvider).nearby(lat: loc.lat, lng: loc.lng);
  }

  @override
  Future<List<Cabinet>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, List<Cabinet>>(HomeController.new);
```

- [ ] **Step 2:** Test `home_controller_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/features/home/presentation/home_controller.dart';

void main() {
  test('loads cabinets from the mock repository', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cabinets = await c.read(homeControllerProvider.future);
    expect(cabinets, isNotEmpty);
    expect(cabinets.first.id, isNotEmpty);
  });
}
```

- [ ] **Step 3:** Run `flutter test test/features/home/home_controller_test.dart` (PASS, 1 test). Commit: `git add lib/features/home/presentation/home_controller.dart test/features/home` then `feat: add HomeController loading nearby cabinets`.

---

## Task 5: CabinetCard widget

**Files:** Create `app/lib/features/home/presentation/cabinet_card.dart`; test `app/test/features/home/cabinet_card_test.dart`.

- [ ] **Step 1:** Write `cabinet_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/marijoy_colors.dart';
import '../../../domain/models/cabinet.dart';

class CabinetCard extends StatelessWidget {
  const CabinetCard({super.key, required this.cabinet, this.onTap});
  final Cabinet cabinet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final distance = cabinet.distanceMeters;
    final distanceText = distance == null
        ? ''
        : distance < 1000
            ? '${distance.round()} m'
            : '${(distance / 1000).toStringAsFixed(1)} km';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: cabinet.online ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: cabinet.online ? MariJoyColors.chargeGreen : MariJoyColors.slate,
          child: Icon(cabinet.online ? Icons.bolt : Icons.bolt_outlined, color: Colors.white),
        ),
        title: Text(cabinet.label),
        subtitle: Row(
          children: [
            Icon(Icons.battery_charging_full, size: 16, color: MariJoyColors.chargeGreen),
            const SizedBox(width: 4),
            Text('${cabinet.banksAvailable}'),
            const SizedBox(width: 12),
            Icon(Icons.local_parking, size: 16, color: MariJoyColors.info),
            const SizedBox(width: 4),
            Text('${cabinet.freeSlots}'),
            const Spacer(),
            if (distanceText.isNotEmpty) Text(distanceText),
          ],
        ),
        trailing: cabinet.online
            ? const Icon(Icons.chevron_right)
            : Text('Nje ya mtandao', style: TextStyle(color: MariJoyColors.error, fontSize: 12)),
      ),
    );
  }
}
```

- [ ] **Step 2:** Test `cabinet_card_test.dart`:
```dart
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
```

- [ ] **Step 3:** Run `flutter test test/features/home/cabinet_card_test.dart` (PASS, 2 tests). Commit: `git add lib/features/home/presentation/cabinet_card.dart test/features/home/cabinet_card_test.dart` then `feat: add CabinetCard widget`.

---

## Task 6: HomeScreen (map + list)

**Files:** Create `app/lib/features/home/presentation/home_screen.dart`; test `app/test/features/home/home_screen_test.dart`.

- [ ] **Step 1:** Write `home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/models/cabinet.dart';
import 'cabinet_card.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinetsAsync = ref.watch(homeControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cabinets karibu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(homeControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Skani / Scan'),
      ),
      body: cabinetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Imeshindikana kupakia. Jaribu tena.')),
        data: (cabinets) => Column(
          children: [
            SizedBox(height: 200, child: _CabinetMap(cabinets: cabinets)),
            Expanded(
              child: cabinets.isEmpty
                  ? const Center(child: Text('Hakuna cabinets karibu.'))
                  : ListView.builder(
                      itemCount: cabinets.length,
                      itemBuilder: (_, i) => CabinetCard(
                        cabinet: cabinets[i],
                        onTap: () => context.push('/c/${cabinets[i].id}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinetMap extends StatelessWidget {
  const _CabinetMap({required this.cabinets});
  final List<Cabinet> cabinets;

  @override
  Widget build(BuildContext context) {
    final center = cabinets.isNotEmpty
        ? LatLng(cabinets.first.lat, cabinets.first.lng)
        : const LatLng(-6.776, 39.178);
    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 12),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'tz.marijoy.marijoy_app',
        ),
        MarkerLayer(
          markers: [
            for (final c in cabinets)
              Marker(
                point: LatLng(c.lat, c.lng),
                child: Icon(Icons.location_on,
                    color: c.online ? Colors.green : Colors.grey, size: 32),
              ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2:** Test `home_screen_test.dart` (verifies the list renders cabinet cards from the mock; the map is present but not asserted on):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marijoy_app/features/home/presentation/cabinet_card.dart';
import 'package:marijoy_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('renders cabinet cards from the mock repository', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/scan', builder: (_, __) => const Scaffold(body: Text('Scan'))),
      GoRoute(path: '/c/:id', builder: (_, __) => const Scaffold(body: Text('Checkout'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
    // Let the async cabinets load.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CabinetCard), findsWidgets);
    expect(find.text('Mlimani City - Gate'), findsOneWidget);
  });
}
```
NOTE: do NOT call `pumpAndSettle()` here — the map's tile loading and any progress indicators can keep the frame scheduler busy; use explicit `pump()` calls as above. If the `flutter_map` widget throws in the test environment, wrap the test pump in `tester.runAsync(() async { ... })` for the loads, or assert on the list after `pump()`. Keep the assertions (CabinetCard present, label visible).

- [ ] **Step 3:** Run `flutter test test/features/home/home_screen_test.dart` (PASS). Commit: `git add lib/features/home/presentation/home_screen.dart test/features/home/home_screen_test.dart` then `feat: add HomeScreen with map and cabinet list`.

---

## Task 7: ScanScreen + manual entry + router wiring

**Files:** Create `app/lib/features/scan/presentation/cabinet_code_field.dart`, `scan_screen.dart`; modify `app/lib/core/router/app_router.dart`; test `app/test/features/scan/cabinet_code_field_test.dart`.

- [ ] **Step 1:** Write `cabinet_code_field.dart` (the testable manual-entry widget):
```dart
import 'package:flutter/material.dart';
import '../../../core/deeplink/cabinet_link.dart';

class CabinetCodeField extends StatefulWidget {
  const CabinetCodeField({super.key, required this.onSubmit});
  final void Function(String deviceId) onSubmit;

  @override
  State<CabinetCodeField> createState() => _CabinetCodeFieldState();
}

class _CabinetCodeFieldState extends State<CabinetCodeField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final id = parseCabinetId(_controller.text);
    if (id == null) {
      setState(() => _error = 'Namba ya cabinet si sahihi / Invalid cabinet code');
      return;
    }
    setState(() => _error = null);
    widget.onSubmit(id);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Namba ya cabinet', errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: _submit, child: const Text('Fungua / Open')),
      ],
    );
  }
}
```

- [ ] **Step 2:** Write `scan_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/deeplink/cabinet_link.dart';
import 'cabinet_code_field.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _handled = false;

  void _open(BuildContext context, String deviceId) {
    if (_handled) return;
    _handled = true;
    context.go('/c/$deviceId');
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final id = parseCabinetId(raw);
      if (id != null) {
        _open(context, id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skani QR / Scan QR')),
      body: Column(
        children: [
          Expanded(child: MobileScanner(onDetect: _onDetect)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Au weka namba / Or enter code'),
                const SizedBox(height: 8),
                CabinetCodeField(onSubmit: (id) => _open(context, id)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3:** In `app/lib/core/router/app_router.dart`, replace the `/home` and `/scan` placeholder routes with the real screens, and add the imports. Change:
  - `import '../../features/home/presentation/home_screen.dart';`
  - `import '../../features/scan/presentation/scan_screen.dart';`
  - `GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),`
  - `GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),`
  Leave `/c/:deviceId`, `/orders/:id`, `/rentals` as the existing `_Placeholder`s (Plan 4 replaces `/c/:deviceId`).

- [ ] **Step 4:** Test `cabinet_code_field_test.dart`:
```dart
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
```

- [ ] **Step 5 — Definition of done.** Run the FULL suite `flutter test` (all Plans 1–3 tests must pass; report count) and `flutter analyze` (clean). The `scan_screen.dart` is not widget-tested directly (camera plugin); its logic is covered by `cabinet_link_test` (parser) and `cabinet_code_field_test` (manual entry + navigation callback). Commit: `git add lib/features/scan lib/core/router/app_router.dart test/features/scan` then `feat: add ScanScreen with QR + manual entry and wire routes`.

---

## Self-review notes (against the design spec)

- **Spec coverage:** Home map (OSM, no Google billing) ✓ T6; nearby cabinet list with availability badges + distance + online state ✓ T5/T6; offline cabinet shown non-tappable ✓ T5 (§9 #5); QR scan ✓ T7; OS-camera deep link path `/c/{deviceId}` ✓ (router route + parser T3, T7); manual code-entry fallback ✓ T7; tamper-proofing (QR carries deviceId only, availability re-fetched server-side at checkout) preserved — scanning only routes to `/c/{id}`.
- **Deferred (noted):** real geolocator + permission UI (mock fixed location now, T2); App Links / Universal Links *platform manifest* setup (needs the production domain) — the in-app route + parser are in place so go_router handles delivered links; the Checkout screen at `/c/{deviceId}` lands in Plan 4 (placeholder for now).
- **Plugin isolation for tests:** `flutter_map` and `mobile_scanner` are confined to `HomeScreen`/`ScanScreen`; all asserted logic (parser, controller, `CabinetCard`, `CabinetCodeField`) is plugin-free and unit/widget-tested. `home_screen_test` uses explicit `pump()` (not `pumpAndSettle`) to avoid the map's tile scheduler.
- **Type/name consistency:** `locationServiceProvider`, `homeControllerProvider`, `cabinetsRepositoryProvider`, `parseCabinetId`, `CabinetCard`, `CabinetCodeField` are referenced consistently across controller, screens, router, and tests.
```
