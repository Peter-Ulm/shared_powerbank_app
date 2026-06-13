# MariJoy App — Foundation & Mock Infrastructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up a running Flutter app shell with the MariJoy design system, bilingual (sw/en) localization, environment config, networking + error mapping, secure token storage, core domain models, repository interfaces, and a mock "scenario engine" that simulates the full rental loop — all under test — so every feature plan that follows can be built and demoed against a fully mockable backend with no server.

**Architecture:** Feature-first folders with three thin layers (presentation / domain / data). Every backend dependency sits behind a repository *interface* with two implementations (`MockX`, `HttpX`); a single `AppEnvironment` flag selects which. This plan builds the `core/`, `mock/`, and the repository interfaces + mock implementations only — no feature screens yet (those are Plans 2–5).

**Tech Stack:** Flutter 3.x / Dart 3, `flutter_riverpod`, `go_router`, `dio`, `freezed` + `json_serializable`, `intl` + `flutter_localizations`, `flutter_secure_storage`, `connectivity_plus`. Dev/test: `build_runner`, `freezed`, `json_serializable`, `flutter_lints`, `http_mock_adapter`, `fake_async`.

**Reference:** `docs/specs/2026-06-13-mobile-app-design.md` (this repo) and `Powerbank_shared/SPEC.md` §6 (API contract), §5 (data model), §9 (failure modes).

**Subsequent plans (for context, not built here):** 2 Auth & onboarding · 3 Discovery (map + scan) · 4 Rental loop · 5 Periphery & real backend.

---

## File structure built by this plan

```
app/
├── pubspec.yaml                       # deps + Inter font + assets
├── analysis_options.yaml              # flutter_lints
├── lib/
│   ├── main.dart                      # bootstrap (Task 12)
│   ├── app.dart                       # MaterialApp.router (Task 12)
│   ├── core/
│   │   ├── env/app_environment.dart   # Task 2
│   │   ├── error/app_exception.dart   # Task 4
│   │   ├── error/error_mapper.dart    # Task 4
│   │   ├── l10n/app_*.arb             # Task 5
│   │   ├── theme/marijoy_theme.dart   # Task 6
│   │   ├── theme/marijoy_colors.dart  # Task 6
│   │   ├── storage/token_store.dart   # Task 7
│   │   ├── network/dio_client.dart    # Task 8
│   │   ├── network/auth_interceptor.dart  # Task 8
│   │   └── router/app_router.dart     # Task 11
│   ├── domain/
│   │   ├── models/*.dart              # Task 3 (freezed)
│   │   └── repositories/*.dart        # Task 9 (abstract interfaces)
│   └── mock/
│       ├── scenario_engine.dart       # Task 10
│       ├── mock_repositories.dart     # Task 10
│       └── fixtures.dart              # Task 10
└── test/
    └── ... mirrors lib/ ...
```

---

## Task 1: Scaffold the Flutter project

**Files:**
- Create: `app/` (via `flutter create`)
- Modify: `app/pubspec.yaml`
- Create: `app/analysis_options.yaml`

- [ ] **Step 1: Create the Flutter project**

Run from the repo root (`C:\Users\USER\Desktop\shared_powerbank_app`):
```bash
flutter create --org tz.marijoy --project-name marijoy_app app
```
Expected: `app/` created with a runnable counter app.

- [ ] **Step 2: Replace `pubspec.yaml` dependencies**

Set the `dependencies` and `dev_dependencies` and `flutter:` sections in `app/pubspec.yaml` to:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  dio: ^5.5.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  intl: any
  flutter_secure_storage: ^9.2.2
  connectivity_plus: ^6.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  http_mock_adapter: ^0.6.1
  fake_async: ^1.3.1

flutter:
  uses-material-design: true
  generate: true          # enables gen-l10n
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Variable.ttf
  assets:
    - assets/
```

- [ ] **Step 3: Download the Inter font**

Download Inter (variable) and save the single file to `app/assets/fonts/Inter-Variable.ttf`. Source: https://github.com/rsms/inter/releases (file `InterVariable.ttf`, rename to `Inter-Variable.ttf`). Create `app/assets/.gitkeep` so the dir exists.

- [ ] **Step 4: Add `l10n.yaml` at `app/l10n.yaml`**

```yaml
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

- [ ] **Step 5: Set `analysis_options.yaml`**

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  exclude:
    - "**/*.freezed.dart"
    - "**/*.g.dart"
```

- [ ] **Step 6: Install and verify**

Run: `cd app && flutter pub get`
Expected: resolves with no errors.

- [ ] **Step 7: Commit**

```bash
git add app/pubspec.yaml app/analysis_options.yaml app/l10n.yaml app/assets
git commit -m "chore: scaffold flutter app with dependencies and Inter font"
```

---

## Task 2: AppEnvironment config

**Files:**
- Create: `app/lib/core/env/app_environment.dart`
- Test: `app/test/core/env/app_environment_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/core/env/app_environment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/env/app_environment.dart';

void main() {
  test('mock environment uses mock data source and local base url', () {
    const env = AppEnvironment(flavor: AppFlavor.mock, apiBaseUrl: 'http://localhost');
    expect(env.useMockData, isTrue);
  });

  test('dev environment does not use mock data', () {
    const env = AppEnvironment(flavor: AppFlavor.dev, apiBaseUrl: 'https://dev.example');
    expect(env.useMockData, isFalse);
  });

  test('fromDartDefine defaults to mock flavor', () {
    final env = AppEnvironment.fromDartDefine();
    expect(env.flavor, AppFlavor.mock);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/core/env/app_environment_test.dart`
Expected: FAIL — `app_environment.dart` not found.

- [ ] **Step 3: Write the implementation**

```dart
// app/lib/core/env/app_environment.dart
enum AppFlavor { mock, dev, prod }

class AppEnvironment {
  const AppEnvironment({required this.flavor, required this.apiBaseUrl});

  final AppFlavor flavor;
  final String apiBaseUrl;

  bool get useMockData => flavor == AppFlavor.mock;

  factory AppEnvironment.fromDartDefine() {
    const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'mock');
    const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000');
    final flavor = AppFlavor.values.firstWhere(
      (f) => f.name == flavorName,
      orElse: () => AppFlavor.mock,
    );
    return AppEnvironment(flavor: flavor, apiBaseUrl: baseUrl);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/core/env/app_environment_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add app/lib/core/env app/test/core/env
git commit -m "feat: add AppEnvironment flavor config"
```

---

## Task 3: Core domain models (freezed)

**Files:**
- Create: `app/lib/domain/models/wallet.dart`, `order.dart`, `cabinet.dart`, `rental.dart`, `auth.dart`
- Test: `app/test/domain/models/models_test.dart`

- [ ] **Step 1: Write the enums and models**

```dart
// app/lib/domain/models/wallet.dart
import 'package:json_annotation/json_annotation.dart';

enum Wallet {
  @JsonValue('mpesa') mpesa,
  @JsonValue('mixx') mixx,
  @JsonValue('airtel') airtel,
  @JsonValue('halopesa') halopesa,
}
```

```dart
// app/lib/domain/models/cabinet.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'cabinet.freezed.dart';
part 'cabinet.g.dart';

@freezed
class Cabinet with _$Cabinet {
  const factory Cabinet({
    required String id,
    required String label,
    required int banksAvailable,
    required int freeSlots,
    required bool online,
    required double lat,
    required double lng,
    double? distanceMeters,
    int? unitPriceTzs,
  }) = _Cabinet;

  factory Cabinet.fromJson(Map<String, dynamic> json) => _$CabinetFromJson(json);
}
```

```dart
// app/lib/domain/models/order.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  @JsonValue('created') created,
  @JsonValue('payment_pending') paymentPending,
  @JsonValue('paid') paid,
  @JsonValue('fulfilling') fulfilling,
  @JsonValue('fulfilled') fulfilled,
  @JsonValue('partially_fulfilled') partiallyFulfilled,
  @JsonValue('expired') expired,
  @JsonValue('cancelled') cancelled,
  @JsonValue('refund_pending') refundPending,
  @JsonValue('refunded') refunded,
  @JsonValue('failed') failed,
}

enum FulfilmentStatus {
  @JsonValue('pending') pending,
  @JsonValue('ejecting') ejecting,
  @JsonValue('ejected') ejected,
  @JsonValue('failed') failed,
  @JsonValue('refunded') refunded,
}

@freezed
class FulfilmentUnit with _$FulfilmentUnit {
  const factory FulfilmentUnit({
    required int unit,
    required FulfilmentStatus status,
    int? slot,
  }) = _FulfilmentUnit;

  factory FulfilmentUnit.fromJson(Map<String, dynamic> json) =>
      _$FulfilmentUnitFromJson(json);
}

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required OrderStatus status,
    required int amountTzs,
    @Default(<FulfilmentUnit>[]) List<FulfilmentUnit> fulfilment,
    String? payInstructions,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
```

```dart
// app/lib/domain/models/rental.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'rental.freezed.dart';
part 'rental.g.dart';

enum RentalStatus {
  @JsonValue('active') active,
  @JsonValue('completed') completed,
  @JsonValue('overdue') overdue,
  @JsonValue('lost') lost,
  @JsonValue('disputed') disputed,
  @JsonValue('closed_by_admin') closedByAdmin,
}

@freezed
class Rental with _$Rental {
  const factory Rental({
    required String id,
    required String powerbankId,
    required RentalStatus status,
    required DateTime startedAt,
    required DateTime dueAt,
    @Default(0) int overageTzs,
    DateTime? returnedAt,
    String? cabinetOutId,
  }) = _Rental;

  factory Rental.fromJson(Map<String, dynamic> json) => _$RentalFromJson(json);
}
```

```dart
// app/lib/domain/models/auth.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String phone,
    required String locale,
    required String status,
    String? name,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}

@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
```

- [ ] **Step 2: Run code generation**

Run: `cd app && dart run build_runner build --delete-conflicting-outputs`
Expected: generates `*.freezed.dart` and `*.g.dart` for each model, no errors.

- [ ] **Step 3: Write the serialization test**

```dart
// app/test/domain/models/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/domain/models/rental.dart';

void main() {
  test('Order parses snake_case status from API json', () {
    final order = Order.fromJson({
      'id': '01ORD',
      'status': 'partially_fulfilled',
      'amountTzs': 2000,
      'fulfilment': [
        {'unit': 1, 'status': 'ejected', 'slot': 7},
        {'unit': 2, 'status': 'failed'},
      ],
    });
    expect(order.status, OrderStatus.partiallyFulfilled);
    expect(order.fulfilment.first.slot, 7);
    expect(order.fulfilment[1].status, FulfilmentStatus.failed);
  });

  test('Rental parses ISO timestamps and defaults overage to 0', () {
    final rental = Rental.fromJson({
      'id': '01RNT',
      'powerbankId': 'PB1',
      'status': 'active',
      'startedAt': '2026-06-13T10:00:00Z',
      'dueAt': '2026-06-13T15:00:00Z',
    });
    expect(rental.status, RentalStatus.active);
    expect(rental.overageTzs, 0);
    expect(rental.dueAt.difference(rental.startedAt).inHours, 5);
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/domain/models/models_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add app/lib/domain/models app/test/domain/models
git commit -m "feat: add core domain models (freezed)"
```

---

## Task 4: AppException + ErrorMapper

**Files:**
- Create: `app/lib/core/error/app_exception.dart`, `app/lib/core/error/error_mapper.dart`
- Test: `app/test/core/error/error_mapper_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/core/error/error_mapper_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/error/app_exception.dart';
import 'package:marijoy_app/core/error/error_mapper.dart';

void main() {
  test('maps known code to swahili and english messages', () {
    final ex = AppException(code: 'CABINET_OFFLINE');
    expect(ErrorMapper.message(ex, 'sw'), isNotEmpty);
    expect(ErrorMapper.message(ex, 'en'), 'This cabinet is offline. Try another nearby.');
    expect(ErrorMapper.message(ex, 'sw'),
        isNot(ErrorMapper.message(ex, 'en')));
  });

  test('unknown code falls back to generic message', () {
    final ex = AppException(code: 'SOMETHING_NEW');
    expect(ErrorMapper.message(ex, 'en'), 'Something went wrong. Please try again.');
  });

  test('network exception maps to connectivity message', () {
    final ex = AppException(code: AppException.networkCode);
    expect(ErrorMapper.message(ex, 'en'), 'No connection. Check your internet and retry.');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/core/error/error_mapper_test.dart`
Expected: FAIL — files not found.

- [ ] **Step 3: Write `app_exception.dart`**

```dart
// app/lib/core/error/app_exception.dart
class AppException implements Exception {
  const AppException({required this.code, this.serverMessage, this.details});

  static const String networkCode = 'NETWORK_ERROR';
  static const String unknownCode = 'UNKNOWN';

  final String code;
  final String? serverMessage;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'AppException($code)';
}
```

- [ ] **Step 4: Write `error_mapper.dart`**

```dart
// app/lib/core/error/error_mapper.dart
import 'app_exception.dart';

class ErrorMapper {
  // code -> { 'sw': ..., 'en': ... }
  static const Map<String, Map<String, String>> _messages = {
    'CABINET_OFFLINE': {
      'sw': 'Cabinet hii haipo mtandaoni. Jaribu nyingine karibu nawe.',
      'en': 'This cabinet is offline. Try another nearby.',
    },
    'INSUFFICIENT_BANKS': {
      'sw': 'Hakuna benki za kutosha kwa sasa. Punguza idadi au jaribu cabinet nyingine.',
      'en': 'Not enough power banks right now. Lower the quantity or try another cabinet.',
    },
    'PAYMENT_TIMEOUT': {
      'sw': 'Muda wa malipo umeisha. Tuma ombi tena.',
      'en': 'The payment prompt expired. Resend it to try again.',
    },
    'USER_BLOCKED': {
      'sw': 'Akaunti yako imezuiwa. Lipa deni lililobaki ili kuendelea.',
      'en': 'Your account is blocked. Settle the outstanding balance to continue.',
    },
    AppException.networkCode: {
      'sw': 'Hakuna mtandao. Angalia intaneti yako kisha jaribu tena.',
      'en': 'No connection. Check your internet and retry.',
    },
  };

  static const Map<String, String> _generic = {
    'sw': 'Hitilafu imetokea. Tafadhali jaribu tena.',
    'en': 'Something went wrong. Please try again.',
  };

  static String message(AppException ex, String locale) {
    final lang = locale == 'sw' ? 'sw' : 'en';
    final entry = _messages[ex.code] ?? _generic;
    return entry[lang] ?? _generic[lang]!;
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd app && flutter test test/core/error/error_mapper_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add app/lib/core/error app/test/core/error
git commit -m "feat: add AppException and bilingual ErrorMapper"
```

---

## Task 5: Localization (sw default, en)

**Files:**
- Create: `app/lib/core/l10n/app_en.arb`, `app/lib/core/l10n/app_sw.arb`
- Test: `app/test/core/l10n/l10n_test.dart`

- [ ] **Step 1: Write `app_en.arb` (template)**

```json
{
  "@@locale": "en",
  "appTitle": "MariJoy",
  "payCheckPhone": "Check your phone and enter your PIN",
  "findReturnCabinet": "Find a return cabinet",
  "resendPrompt": "Resend prompt"
}
```

- [ ] **Step 2: Write `app_sw.arb`**

```json
{
  "@@locale": "sw",
  "appTitle": "MariJoy",
  "payCheckPhone": "Angalia simu yako, weka namba yako ya siri",
  "findReturnCabinet": "Tafuta cabinet ya kurudisha",
  "resendPrompt": "Tuma ombi tena"
}
```

- [ ] **Step 3: Generate localizations**

Run: `cd app && flutter gen-l10n`
Expected: generates `lib/core/l10n/app_localizations.dart` (and `app_localizations_en.dart`, `_sw.dart`).

- [ ] **Step 4: Write the failing test**

Note: generated `supportedLocales` are alphabetical (`en`, `sw`); the app forces Swahili as the fallback default via `localeResolutionCallback` in Task 12, so this test only asserts membership and that the sw string resolves.

```dart
// app/test/core/l10n/l10n_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:marijoy_app/core/l10n/app_localizations.dart';

void main() {
  test('swahili and english are supported locales', () {
    expect(AppLocalizations.supportedLocales, contains(const Locale('sw')));
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
  });

  testWidgets('resolves swahili payment string', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('sw'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ),
    );
    expect(l10n.payCheckPhone, 'Angalia simu yako, weka namba yako ya siri');
  });
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd app && flutter test test/core/l10n/l10n_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add app/lib/core/l10n app/test/core/l10n app/l10n.yaml
git commit -m "feat: add sw/en localization scaffolding"
```

---

## Task 6: MariJoy theme

**Files:**
- Create: `app/lib/core/theme/marijoy_colors.dart`, `app/lib/core/theme/marijoy_theme.dart`
- Test: `app/test/core/theme/marijoy_theme_test.dart`

- [ ] **Step 1: Write `marijoy_colors.dart`**

```dart
// app/lib/core/theme/marijoy_colors.dart
import 'package:flutter/material.dart';

class MariJoyColors {
  static const chargeGreen = Color(0xFF0E9F6E);
  static const marigold = Color(0xFFF59E0B);
  static const ink = Color(0xFF111827);
  static const slate = Color(0xFF6B7280);
  static const mist = Color(0xFFF3F4F6);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
}
```

- [ ] **Step 2: Write `marijoy_theme.dart`**

```dart
// app/lib/core/theme/marijoy_theme.dart
import 'package:flutter/material.dart';
import 'marijoy_colors.dart';

class MariJoyTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MariJoyColors.chargeGreen,
      primary: MariJoyColors.chargeGreen,
      secondary: MariJoyColors.marigold,
      error: MariJoyColors.error,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: Colors.white,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      // tabular figures for countdowns/prices
      textTheme: const TextTheme().apply(fontFamily: 'Inter'),
    );
  }
}
```

- [ ] **Step 3: Write the failing test**

```dart
// app/test/core/theme/marijoy_theme_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:marijoy_app/core/theme/marijoy_theme.dart';
import 'package:marijoy_app/core/theme/marijoy_colors.dart';

void main() {
  test('light theme uses Charge Green as primary and Inter font', () {
    final theme = MariJoyTheme.light();
    expect(theme.colorScheme.primary, MariJoyColors.chargeGreen);
    expect(theme.colorScheme.secondary, MariJoyColors.marigold);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.useMaterial3, isTrue);
  });

  test('primary buttons are at least 56dp tall for tap targets', () {
    final theme = MariJoyTheme.light();
    final style = theme.filledButtonTheme.style!;
    final size = style.minimumSize!.resolve({})!;
    expect(size.height, greaterThanOrEqualTo(56));
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/core/theme/marijoy_theme_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add app/lib/core/theme app/test/core/theme
git commit -m "feat: add MariJoy Material 3 theme and color tokens"
```

---

## Task 7: Secure token store

**Files:**
- Create: `app/lib/core/storage/token_store.dart`
- Test: `app/test/core/storage/token_store_test.dart`

- [ ] **Step 1: Write `token_store.dart` (interface + secure impl + in-memory fake)**

```dart
// app/lib/core/storage/token_store.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/auth.dart';

abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);
  final FlutterSecureStorage _storage;
  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  @override
  Future<AuthTokens?> read() async {
    final a = await _storage.read(key: _access);
    final r = await _storage.read(key: _refresh);
    if (a == null || r == null) return null;
    return AuthTokens(accessToken: a, refreshToken: r);
  }

  @override
  Future<void> write(AuthTokens tokens) async {
    await _storage.write(key: _access, value: tokens.accessToken);
    await _storage.write(key: _refresh, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}

class InMemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;
  @override
  Future<AuthTokens?> read() async => _tokens;
  @override
  Future<void> write(AuthTokens tokens) async => _tokens = tokens;
  @override
  Future<void> clear() async => _tokens = null;
}
```

- [ ] **Step 2: Write the test (using the in-memory fake)**

```dart
// app/test/core/storage/token_store_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth.dart';

void main() {
  test('write then read returns the same tokens', () async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final read = await store.read();
    expect(read?.accessToken, 'a');
    expect(read?.refreshToken, 'r');
  });

  test('clear removes tokens', () async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    await store.clear();
    expect(await store.read(), isNull);
  });
}
```

- [ ] **Step 3: Run test to verify it passes**

Run: `cd app && flutter test test/core/storage/token_store_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 4: Commit**

```bash
git add app/lib/core/storage app/test/core/storage
git commit -m "feat: add secure token store with in-memory fake"
```

---

## Task 8: Dio client + auth interceptor + error mapping

**Files:**
- Create: `app/lib/core/network/auth_interceptor.dart`, `app/lib/core/network/dio_client.dart`
- Test: `app/test/core/network/dio_client_test.dart`

- [ ] **Step 1: Write `auth_interceptor.dart`**

```dart
// app/lib/core/network/auth_interceptor.dart
import 'package:dio/dio.dart';
import '../error/app_exception.dart';
import '../storage/token_store.dart';

/// Attaches the bearer token and converts errors to AppException.
/// (Token refresh-on-401 is added in Plan 2 when auth endpoints exist.)
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStore);
  final TokenStore _tokenStore;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await _tokenStore.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: _toAppException(err),
        response: err.response,
        type: err.type,
      ),
    );
  }

  AppException _toAppException(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const AppException(code: AppException.networkCode);
    }
    final data = err.response?.data;
    if (data is Map && data['error'] is Map) {
      final e = data['error'] as Map;
      return AppException(
        code: (e['code'] as String?) ?? AppException.unknownCode,
        serverMessage: e['message'] as String?,
        details: (e['details'] as Map?)?.cast<String, dynamic>(),
      );
    }
    return const AppException(code: AppException.unknownCode);
  }
}
```

- [ ] **Step 2: Write `dio_client.dart`**

```dart
// app/lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../env/app_environment.dart';
import '../storage/token_store.dart';
import 'auth_interceptor.dart';

Dio buildDio(AppEnvironment env, TokenStore tokenStore) {
  final dio = Dio(BaseOptions(
    baseUrl: '${env.apiBaseUrl}/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(AuthInterceptor(tokenStore));
  return dio;
}
```

- [ ] **Step 3: Write the failing test (with http_mock_adapter)**

```dart
// app/test/core/network/dio_client_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:marijoy_app/core/env/app_environment.dart';
import 'package:marijoy_app/core/error/app_exception.dart';
import 'package:marijoy_app/core/network/dio_client.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late InMemoryTokenStore store;

  setUp(() {
    store = InMemoryTokenStore();
    dio = buildDio(
      const AppEnvironment(flavor: AppFlavor.dev, apiBaseUrl: 'https://x'),
      store,
    );
    adapter = DioAdapter(dio: dio);
  });

  test('attaches bearer token when present', () async {
    await store.write(const AuthTokens(accessToken: 'tok123', refreshToken: 'r'));
    adapter.onGet('/me', (s) => s.reply(200, {'ok': true}));
    final res = await dio.get('/me');
    expect(res.requestOptions.headers['Authorization'], 'Bearer tok123');
  });

  test('maps error envelope to AppException with code', () async {
    adapter.onPost('/orders', (s) => s.reply(409, {
          'error': {'code': 'INSUFFICIENT_BANKS', 'message': 'no banks'}
        }));
    try {
      await dio.post('/orders');
      fail('should have thrown');
    } on DioException catch (e) {
      expect(e.error, isA<AppException>());
      expect((e.error as AppException).code, 'INSUFFICIENT_BANKS');
    }
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/core/network/dio_client_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add app/lib/core/network app/test/core/network
git commit -m "feat: add dio client with auth interceptor and error mapping"
```

---

## Task 9: Repository interfaces

**Files:**
- Create: `app/lib/domain/repositories/auth_repository.dart`, `cabinets_repository.dart`, `orders_repository.dart`, `rentals_repository.dart`
- Test: none yet (interfaces only; exercised via mocks in Task 10)

- [ ] **Step 1: Write the interfaces**

```dart
// app/lib/domain/repositories/cabinets_repository.dart
import '../models/cabinet.dart';

abstract class CabinetsRepository {
  Future<List<Cabinet>> nearby({required double lat, required double lng, double radiusM});
  Future<Cabinet> byId(String id);
}
```

```dart
// app/lib/domain/repositories/orders_repository.dart
import '../models/order.dart';
import '../models/wallet.dart';

abstract class OrdersRepository {
  Future<Order> create({
    required String cabinetId,
    required int qty,
    Wallet? wallet,
    required String idempotencyKey,
  });
  Future<Order> byId(String id);
  Stream<Order> watch(String id); // mock & http both poll/emit
  Future<void> repush(String id);
  Future<void> cancel(String id);
}
```

```dart
// app/lib/domain/repositories/rentals_repository.dart
import '../models/rental.dart';

abstract class RentalsRepository {
  Future<List<Rental>> list({RentalStatus? status});
  Future<Rental> byId(String id);
  Stream<List<Rental>> watchActive();
}
```

```dart
// app/lib/domain/repositories/auth_repository.dart
import '../models/auth.dart';

abstract class AuthRepository {
  Future<void> requestOtp(String phone);
  Future<({AuthTokens tokens, AppUser user})> verifyOtp(String phone, String code);
  Future<AppUser> me();
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd app && flutter analyze lib/domain/repositories`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add app/lib/domain/repositories
git commit -m "feat: add repository interfaces"
```

---

## Task 10: Mock scenario engine + mock repositories

**Files:**
- Create: `app/lib/mock/fixtures.dart`, `app/lib/mock/scenario_engine.dart`, `app/lib/mock/mock_repositories.dart`
- Test: `app/test/mock/scenario_engine_test.dart`

- [ ] **Step 1: Write `fixtures.dart`**

```dart
// app/lib/mock/fixtures.dart
import '../domain/models/cabinet.dart';

const kUnitPriceTzs = 1000;

final mockCabinets = <Cabinet>[
  const Cabinet(
    id: 'CAB001', label: 'Mlimani City - Gate', banksAvailable: 6,
    freeSlots: 10, online: true, lat: -6.770, lng: 39.241,
    distanceMeters: 120, unitPriceTzs: kUnitPriceTzs,
  ),
  const Cabinet(
    id: 'CAB002', label: 'Posta - CBD', banksAvailable: 2,
    freeSlots: 3, online: true, lat: -6.816, lng: 39.289,
    distanceMeters: 640, unitPriceTzs: kUnitPriceTzs,
  ),
  const Cabinet(
    id: 'CAB003', label: 'Mwenge', banksAvailable: 0,
    freeSlots: 0, online: false, lat: -6.772, lng: 39.226,
    distanceMeters: 1500, unitPriceTzs: kUnitPriceTzs,
  ),
];
```

- [ ] **Step 2: Write `scenario_engine.dart`**

```dart
// app/lib/mock/scenario_engine.dart
import 'dart:async';
import '../domain/models/order.dart';
import '../domain/models/rental.dart';

/// Fault branches the engine can simulate (SPEC §9).
enum MockFault { none, ejectFail, partial, pushTimeout }

/// Drives the mock rental loop on timers. Uses an injectable [now] so tests
/// can run it with fake_async. Tick durations are short for demo/tests.
class ScenarioEngine {
  ScenarioEngine({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  MockFault fault = MockFault.none;

  final _orders = <String, Order>{};
  final _orderControllers = <String, StreamController<Order>>{};
  final _rentals = <Rental>[];
  final _rentalsController = StreamController<List<Rental>>.broadcast();

  static const tick = Duration(seconds: 2);

  Order createOrder(String id, int qty, int amountTzs) {
    final order = Order(
      id: id,
      status: OrderStatus.paymentPending,
      amountTzs: amountTzs,
      fulfilment: [
        for (var i = 1; i <= qty; i++)
          FulfilmentUnit(unit: i, status: FulfilmentStatus.pending),
      ],
    );
    _orders[id] = order;
    _orderControllers[id] = StreamController<Order>.broadcast();
    _schedule(id, qty);
    return order;
  }

  Stream<Order> watchOrder(String id) async* {
    yield _orders[id]!;
    yield* _orderControllers[id]!.stream;
  }

  Order order(String id) => _orders[id]!;
  Stream<List<Rental>> watchRentals() => _rentalsController.stream;
  List<Rental> get rentals => List.unmodifiable(_rentals);

  void _emit(Order o) {
    _orders[o.id] = o;
    _orderControllers[o.id]?.add(o);
  }

  void _schedule(String id, int qty) {
    if (fault == MockFault.pushTimeout) {
      Timer(tick * 2, () => _emit(_orders[id]!.copyWith(status: OrderStatus.failed)));
      return;
    }
    // pending -> paid
    Timer(tick, () {
      _emit(_orders[id]!.copyWith(status: OrderStatus.fulfilling));
      _ejectUnits(id, qty);
    });
  }

  void _ejectUnits(String id, int qty) {
    var delay = tick;
    for (var i = 1; i <= qty; i++) {
      final unit = i;
      final fails = (fault == MockFault.ejectFail) ||
          (fault == MockFault.partial && unit == qty);
      Timer(delay, () => _completeUnit(id, unit, fails));
      delay += tick;
    }
  }

  void _completeUnit(String id, int unit, bool fails) {
    final o = _orders[id]!;
    final updated = o.fulfilment
        .map((u) => u.unit == unit
            ? u.copyWith(
                status: fails ? FulfilmentStatus.failed : FulfilmentStatus.ejected,
                slot: fails ? null : 6 + unit)
            : u)
        .toList();
    final allDone = updated.every((u) =>
        u.status == FulfilmentStatus.ejected || u.status == FulfilmentStatus.failed);
    final anyOk = updated.any((u) => u.status == FulfilmentStatus.ejected);
    final anyFail = updated.any((u) => u.status == FulfilmentStatus.failed);
    var status = o.status;
    if (allDone) {
      status = anyFail && anyOk
          ? OrderStatus.partiallyFulfilled
          : anyOk
              ? OrderStatus.fulfilled
              : OrderStatus.refunded;
    }
    _emit(o.copyWith(fulfilment: updated, status: status));
    if (!fails) _activateRental(id, unit);
  }

  void _activateRental(String orderId, int unit) {
    final started = _now();
    _rentals.add(Rental(
      id: '$orderId-R$unit',
      powerbankId: 'PB-$orderId-$unit',
      status: RentalStatus.active,
      startedAt: started,
      dueAt: started.add(const Duration(hours: 5)),
    ));
    _rentalsController.add(List.of(_rentals));
  }

  void dispose() {
    for (final c in _orderControllers.values) {
      c.close();
    }
    _rentalsController.close();
  }
}
```

- [ ] **Step 3: Write `mock_repositories.dart`**

```dart
// app/lib/mock/mock_repositories.dart
import '../domain/models/cabinet.dart';
import '../domain/models/order.dart';
import '../domain/models/rental.dart';
import '../domain/models/wallet.dart';
import '../domain/repositories/cabinets_repository.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/repositories/rentals_repository.dart';
import 'fixtures.dart';
import 'scenario_engine.dart';

class MockCabinetsRepository implements CabinetsRepository {
  @override
  Future<List<Cabinet>> nearby({required double lat, required double lng, double radiusM = 2000}) async =>
      mockCabinets;
  @override
  Future<Cabinet> byId(String id) async =>
      mockCabinets.firstWhere((c) => c.id == id);
}

class MockOrdersRepository implements OrdersRepository {
  MockOrdersRepository(this._engine);
  final ScenarioEngine _engine;
  var _seq = 0;

  @override
  Future<Order> create({
    required String cabinetId,
    required int qty,
    Wallet? wallet,
    required String idempotencyKey,
  }) async {
    final id = 'ORD${(++_seq).toString().padLeft(3, '0')}';
    return _engine.createOrder(id, qty, qty * kUnitPriceTzs);
  }

  @override
  Future<Order> byId(String id) async => _engine.order(id);
  @override
  Stream<Order> watch(String id) => _engine.watchOrder(id);
  @override
  Future<void> repush(String id) async {}
  @override
  Future<void> cancel(String id) async {}
}

class MockRentalsRepository implements RentalsRepository {
  MockRentalsRepository(this._engine);
  final ScenarioEngine _engine;

  @override
  Future<List<Rental>> list({RentalStatus? status}) async => _engine.rentals
      .where((r) => status == null || r.status == status)
      .toList();
  @override
  Future<Rental> byId(String id) async =>
      _engine.rentals.firstWhere((r) => r.id == id);
  @override
  Stream<List<Rental>> watchActive() => _engine.watchRentals();
}
```

- [ ] **Step 4: Write the failing test (with fake_async)**

```dart
// app/test/mock/scenario_engine_test.dart
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/mock/scenario_engine.dart';

void main() {
  test('happy path: single bank goes pending -> fulfilled and a rental activates', () {
    fakeAsync((async) {
      final engine = ScenarioEngine(now: () => DateTime(2026, 6, 13, 10));
      engine.createOrder('ORD1', 1, 1000);
      async.elapse(const Duration(seconds: 10));

      final order = engine.order('ORD1');
      expect(order.status, OrderStatus.fulfilled);
      expect(order.fulfilment.single.status, FulfilmentStatus.ejected);
      expect(engine.rentals.length, 1);
      expect(engine.rentals.single.dueAt.difference(engine.rentals.single.startedAt).inHours, 5);
      engine.dispose();
    });
  });

  test('partial fault: 2 of 2 -> one ejected, one failed, status partiallyFulfilled', () {
    fakeAsync((async) {
      final engine = ScenarioEngine(now: () => DateTime(2026, 6, 13, 10))
        ..fault = MockFault.partial;
      engine.createOrder('ORD2', 2, 2000);
      async.elapse(const Duration(seconds: 12));

      final order = engine.order('ORD2');
      expect(order.status, OrderStatus.partiallyFulfilled);
      expect(engine.rentals.length, 1); // only the successful unit
      engine.dispose();
    });
  });

  test('pushTimeout fault: order ends failed, no rentals', () {
    fakeAsync((async) {
      final engine = ScenarioEngine(now: () => DateTime(2026, 6, 13, 10))
        ..fault = MockFault.pushTimeout;
      engine.createOrder('ORD3', 1, 1000);
      async.elapse(const Duration(seconds: 10));

      expect(engine.order('ORD3').status, OrderStatus.failed);
      expect(engine.rentals, isEmpty);
      engine.dispose();
    });
  });
}
```

- [ ] **Step 5: Run code generation (copyWith needs generated code — already done in Task 3) and run the test**

Run: `cd app && flutter test test/mock/scenario_engine_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add app/lib/mock app/test/mock
git commit -m "feat: add mock scenario engine and mock repositories"
```

---

## Task 11: Router skeleton + providers

**Files:**
- Create: `app/lib/core/router/app_router.dart`
- Create: `app/lib/core/providers.dart` (Riverpod wiring that selects mock vs http impls)
- Test: `app/test/core/router/app_router_test.dart`

- [ ] **Step 1: Write `providers.dart`**

```dart
// app/lib/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/cabinets_repository.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/repositories/rentals_repository.dart';
import '../mock/mock_repositories.dart';
import '../mock/scenario_engine.dart';
import 'env/app_environment.dart';

final environmentProvider = Provider<AppEnvironment>((_) => AppEnvironment.fromDartDefine());

final scenarioEngineProvider = Provider<ScenarioEngine>((ref) {
  final engine = ScenarioEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

/// Auth state: true when a token exists. Real wiring lands in Plan 2;
/// for now it defaults to false (unauthenticated).
final isAuthenticatedProvider = StateProvider<bool>((_) => false);

final cabinetsRepositoryProvider = Provider<CabinetsRepository>((ref) {
  // HttpCabinetsRepository arrives in Plan 5; mock is the only impl for now.
  return MockCabinetsRepository();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return MockOrdersRepository(ref.watch(scenarioEngineProvider));
});

final rentalsRepositoryProvider = Provider<RentalsRepository>((ref) {
  return MockRentalsRepository(ref.watch(scenarioEngineProvider));
});
```

- [ ] **Step 2: Write `app_router.dart`**

```dart
// app/lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';

/// Placeholder screens; real ones land in Plans 2–4. Routes and the auth
/// gate are defined now so feature plans only swap the builders.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
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
      GoRoute(path: '/c/:deviceId', builder: (_, s) =>
          _Placeholder('Checkout ${s.pathParameters['deviceId']}')),
      GoRoute(path: '/orders/:id', builder: (_, s) =>
          _Placeholder('Order ${s.pathParameters['id']}')),
      GoRoute(path: '/rentals', builder: (_, __) => const _Placeholder('Rentals')),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));
```

- [ ] **Step 3: Write the failing test**

GoRouter's `redirect` is awkward to unit-test in isolation, so this drives the real router through a widget pump and asserts the resulting screen.

```dart
// app/test/core/router/app_router_test.dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/core/router/app_router_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add app/lib/core/router app/lib/core/providers.dart app/test/core/router
git commit -m "feat: add go_router skeleton with auth gate and DI providers"
```

---

## Task 12: App bootstrap

**Files:**
- Modify/Create: `app/lib/app.dart`, `app/lib/main.dart`
- Test: `app/test/app_test.dart`

- [ ] **Step 1: Write `app.dart`**

```dart
// app/lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers.dart';
import 'core/theme/marijoy_theme.dart';

class MariJoyApp extends ConsumerWidget {
  const MariJoyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MariJoy',
      debugShowCheckedModeBanner: false,
      theme: MariJoyTheme.light(),
      routerConfig: router,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Swahili default: if the device locale isn't supported, fall back to sw.
      localeResolutionCallback: (deviceLocale, supported) {
        for (final l in supported) {
          if (l.languageCode == deviceLocale?.languageCode) return l;
        }
        return const Locale('sw');
      },
    );
  }
}
```

- [ ] **Step 2: Write `main.dart`**

```dart
// app/lib/main.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MariJoyApp()));
}
```

- [ ] **Step 3: Write the smoke test**

```dart
// app/test/app_test.dart
import 'package:flutter/material.dart';
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
```

- [ ] **Step 4: Run the full test suite**

Run: `cd app && flutter test`
Expected: ALL tests PASS across every file built in this plan.

- [ ] **Step 5: Run the analyzer**

Run: `cd app && flutter analyze`
Expected: No issues found.

- [ ] **Step 6: Commit**

```bash
git add app/lib/app.dart app/lib/main.dart app/test/app_test.dart
git commit -m "feat: wire app bootstrap with router, theme, and sw-default l10n"
```

---

## Definition of done

- `flutter test` green; `flutter analyze` clean.
- App launches (`cd app && flutter run --dart-define=FLAVOR=mock`) and shows the Onboarding placeholder.
- The mock scenario engine drives a full order → eject → active-rental loop and the §9 fault branches, all under test — ready for the feature plans to bind UI to it.

---

## Self-review notes (against the design spec)

- **Spec coverage (foundation slice):** env swap point ✓ (Task 2), models matching SPEC §5/§6 ✓ (Task 3), bilingual error mapping ✓ (Task 4), sw-default l10n ✓ (Tasks 5, 12), MariJoy design tokens ✓ (Task 6), secure tokens ✓ (Task 7), dio + interceptor + error envelope ✓ (Task 8), repository interfaces ✓ (Task 9), mock scenario engine incl. §9 faults ✓ (Task 10), router auth gate + deep-link route `/c/:deviceId` ✓ (Task 11), bootstrap ✓ (Task 12). Feature screens, FCM, Sentry, offline cache, and `HttpX` impls are intentionally deferred to Plans 2–5.
- **Placeholder scan:** the only placeholders are the router's `_Placeholder` screens — intentional and replaced by Plans 2–4; no "TBD"/"add error handling"-style gaps.
- **Type consistency:** `OrderStatus`/`FulfilmentStatus`/`RentalStatus` enums and `copyWith` usage in Task 10 match the freezed models defined in Task 3; repository method names in Task 9 match their mock implementations in Task 10 and the provider wiring in Task 11.
