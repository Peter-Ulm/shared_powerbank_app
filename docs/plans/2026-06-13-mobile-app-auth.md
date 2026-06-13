# MariJoy App — Auth & Onboarding Implementation Plan (Plan 2 of 5)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the first real user flow — language pick → phone entry (+255) → SMS OTP → JWT session → T&Cs acceptance → Home — running against a mock auth backend, with auth status driving a reactive router and the chosen locale persisted across launches.

**Architecture:** Builds on Plan 1's foundation. Adds an `AppPrefs` wrapper (shared_preferences) for non-sensitive prefs (locale, T&Cs accepted), a `MockAuthRepository`, a `Notifier<AuthState>` auth controller that persists tokens via the existing `TokenStore` and restores the session on launch, a locale controller wired into `MaterialApp`, and a reactive `go_router` whose redirect gates on auth state + T&Cs. The onboarding screens live under `features/onboarding/`.

**Tech Stack:** Same as Plan 1, plus `shared_preferences`. Auth state is a `freezed` union; the controller is a Riverpod `Notifier`.

**Reference:** `docs/specs/2026-06-13-mobile-app-design.md` §3 (screen 1) and §4 (auth/cross-cutting); `Powerbank_shared/SPEC.md` §6 (`/auth/*`, `/me`), §8 (JWT/OTP).

**Prerequisite:** Plan 1 merged (foundation on `main`, 22 tests green). This plan modifies `lib/core/providers.dart`, `lib/core/router/app_router.dart`, `lib/app.dart`, `lib/main.dart`, and rewrites `test/core/router/app_router_test.dart`.

**Environment note for implementers:** Flutter is at `C:\Users\USER\flutter\bin` and is NOT on the default PATH for fresh shells — prepend `$env:Path = "C:\Users\USER\flutter\bin;$env:Path"` in every PowerShell command. Work in `C:\Users\USER\Desktop\shared_powerbank_app`, package `marijoy_app`, project dir `app/`.

---

## File structure built by this plan

```
app/lib/
├── core/
│   ├── storage/app_prefs.dart            # Task 1 (NEW)
│   ├── phone/tz_phone.dart               # Task 2 (NEW)
│   ├── providers.dart                    # MODIFY (Tasks 1,4,5,6)
│   ├── router/app_router.dart            # MODIFY (Task 6)
│   └── l10n/locale_controller.dart       # Task 5 (NEW)
├── domain/models/auth_state.dart         # Task 3 (NEW, freezed union)
├── mock/mock_auth_repository.dart        # Task 3 (NEW)
├── features/onboarding/presentation/
│   ├── auth_controller.dart              # Task 4 (NEW)
│   ├── splash_screen.dart                # Task 6 (NEW)
│   ├── onboarding_flow.dart              # Task 7 (NEW)
│   ├── language_step.dart                # Task 7 (NEW)
│   ├── phone_step.dart                   # Task 7 (NEW)
│   ├── otp_step.dart                     # Task 7 (NEW)
│   └── terms_screen.dart                 # Task 8 (NEW)
├── app.dart                              # MODIFY (Task 5)
└── main.dart                             # MODIFY (Task 1)
```

---

## Task 1: AppPrefs (shared_preferences wrapper)

**Files:** Create `app/lib/core/storage/app_prefs.dart`; modify `app/pubspec.yaml`, `app/lib/main.dart`, `app/lib/core/providers.dart`; test `app/test/core/storage/app_prefs_test.dart`.

- [ ] **Step 1: Add dependency.** In `app/pubspec.yaml` under `dependencies`, add `shared_preferences: ^2.3.2`. Run (with PATH prepend, in `app/`): `flutter pub get`. Expected: resolves cleanly.

- [ ] **Step 2: Write `app_prefs.dart`.**

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive app preferences (locale, T&Cs acceptance). Sensitive data
/// (tokens) lives in TokenStore, not here.
abstract class AppPrefs {
  String? get locale;            // 'sw' | 'en' | null
  set locale(String? value);
  bool get termsAccepted;
  set termsAccepted(bool value);
}

class SharedAppPrefs implements AppPrefs {
  SharedAppPrefs(this._prefs);
  final SharedPreferences _prefs;
  static const _kLocale = 'locale';
  static const _kTerms = 'terms_accepted';

  @override
  String? get locale => _prefs.getString(_kLocale);
  @override
  set locale(String? value) {
    if (value == null) {
      _prefs.remove(_kLocale);
    } else {
      _prefs.setString(_kLocale, value);
    }
  }

  @override
  bool get termsAccepted => _prefs.getBool(_kTerms) ?? false;
  @override
  set termsAccepted(bool value) => _prefs.setBool(_kTerms, value);
}

class InMemoryAppPrefs implements AppPrefs {
  InMemoryAppPrefs({this.locale, this.termsAccepted = false});
  @override
  String? locale;
  @override
  bool termsAccepted;
}
```

- [ ] **Step 3: Add provider.** In `app/lib/core/providers.dart` add an import `import 'storage/app_prefs.dart';` and a provider that MUST be overridden at startup:
```dart
final appPrefsProvider = Provider<AppPrefs>((ref) {
  throw UnimplementedError('appPrefsProvider must be overridden in main()');
});
```

- [ ] **Step 4: Override in `main.dart`.** Replace `app/lib/main.dart` with:
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers.dart';
import 'core/storage/app_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      appPrefsProvider.overrideWithValue(SharedAppPrefs(prefs)),
    ],
    child: const MariJoyApp(),
  ));
}
```

- [ ] **Step 5: Write the test** `app/test/core/storage/app_prefs_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';

void main() {
  test('in-memory prefs round-trips locale and termsAccepted', () {
    final prefs = InMemoryAppPrefs();
    expect(prefs.locale, isNull);
    expect(prefs.termsAccepted, isFalse);
    prefs.locale = 'sw';
    prefs.termsAccepted = true;
    expect(prefs.locale, 'sw');
    expect(prefs.termsAccepted, isTrue);
  });
}
```

- [ ] **Step 6: Run & commit.** `flutter test test/core/storage/app_prefs_test.dart` (PASS, 1 test). Note: the existing `test/app_test.dart` now needs the prefs override; it will be fixed in Task 6 when the router changes — for now run only the targeted test. Commit: `git add pubspec.yaml lib/core/storage/app_prefs.dart lib/main.dart lib/core/providers.dart test/core/storage/app_prefs_test.dart` then `feat: add AppPrefs (shared_preferences) for locale and terms`.

---

## Task 2: Tanzania phone validation/normalization

**Files:** Create `app/lib/core/phone/tz_phone.dart`; test `app/test/core/phone/tz_phone_test.dart`.

- [ ] **Step 1: Write the test.**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/phone/tz_phone.dart';

void main() {
  test('normalizes local 0-prefixed number to E.164', () {
    expect(TzPhone.normalize('0712345678'), '+255712345678');
  });
  test('normalizes spaced and 255-prefixed inputs', () {
    expect(TzPhone.normalize('255 712 345 678'), '+255712345678');
    expect(TzPhone.normalize('+255712345678'), '+255712345678');
  });
  test('returns null for invalid numbers', () {
    expect(TzPhone.normalize('12345'), isNull);
    expect(TzPhone.normalize('071234567'), isNull); // too short
    expect(TzPhone.normalize('07123456789'), isNull); // too long
  });
  test('isValid reflects normalization', () {
    expect(TzPhone.isValid('0712 345 678'), isTrue);
    expect(TzPhone.isValid('abc'), isFalse);
  });
}
```

- [ ] **Step 2: Run to confirm it fails.** `flutter test test/core/phone/tz_phone_test.dart` → FAIL (file missing).

- [ ] **Step 3: Implement `tz_phone.dart`.**
```dart
/// Tanzania MSISDN normalization to E.164 (+255XXXXXXXXX, 9 national digits).
/// Lightweight, dependency-free; a fuller libphonenumber can replace it later.
class TzPhone {
  /// Returns E.164 (+255XXXXXXXXX) if the input is a valid TZ mobile number,
  /// else null. Accepts 07XXXXXXXX, 7XXXXXXXX, 255..., +255..., with spaces.
  static String? normalize(String input) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('255')) {
      digits = digits.substring(3);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    // National significant number must be 9 digits starting with 6 or 7.
    if (digits.length != 9) return null;
    if (!RegExp(r'^[67]\d{8}$').hasMatch(digits)) return null;
    return '+255$digits';
  }

  static bool isValid(String input) => normalize(input) != null;
}
```

- [ ] **Step 4: Run & commit.** `flutter test test/core/phone/tz_phone_test.dart` (PASS, 4 tests). Commit: `git add lib/core/phone test/core/phone` then `feat: add TZ phone normalization`.

---

## Task 3: AuthState (freezed) + MockAuthRepository

**Files:** Create `app/lib/domain/models/auth_state.dart`, `app/lib/mock/mock_auth_repository.dart`; test `app/test/mock/mock_auth_repository_test.dart`.

- [ ] **Step 1: Write `auth_state.dart`** (freezed union):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth.dart';
part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unknown() = AuthUnknown;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.otpSent({required String phone}) = AuthOtpSent;
  const factory AuthState.authenticated({required AppUser user}) = AuthAuthenticated;
}
```

- [ ] **Step 2: Write `mock_auth_repository.dart`:**
```dart
import '../domain/models/auth.dart';
import '../domain/repositories/auth_repository.dart';

/// Mock auth: any 6-digit code verifies. Records the last OTP request so the
/// scenario/demo can show it. No real SMS/JWT.
class MockAuthRepository implements AuthRepository {
  String? lastOtpPhone;

  @override
  Future<void> requestOtp(String phone) async {
    lastOtpPhone = phone;
  }

  @override
  Future<({AuthTokens tokens, AppUser user})> verifyOtp(String phone, String code) async {
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      throw const AuthException('OTP_INVALID');
    }
    final user = AppUser(id: 'U-$phone', phone: phone, locale: 'sw', status: 'active');
    const tokens = AuthTokens(accessToken: 'mock-access', refreshToken: 'mock-refresh');
    return (tokens: tokens, user: user);
  }

  @override
  Future<AppUser> me() async =>
      AppUser(id: 'U-restored', phone: '+255700000000', locale: 'sw', status: 'active');
}

class AuthException implements Exception {
  const AuthException(this.code);
  final String code;
  @override
  String toString() => 'AuthException($code)';
}
```

- [ ] **Step 3: Codegen.** Run `dart run build_runner build --delete-conflicting-outputs` (generates `auth_state.freezed.dart`).

- [ ] **Step 4: Write the test** `app/test/mock/mock_auth_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/mock/mock_auth_repository.dart';

void main() {
  test('requestOtp records the phone', () async {
    final repo = MockAuthRepository();
    await repo.requestOtp('+255712345678');
    expect(repo.lastOtpPhone, '+255712345678');
  });

  test('verifyOtp returns tokens + user for a 6-digit code', () async {
    final repo = MockAuthRepository();
    final res = await repo.verifyOtp('+255712345678', '123456');
    expect(res.tokens.accessToken, isNotEmpty);
    expect(res.user.phone, '+255712345678');
  });

  test('verifyOtp rejects a non-6-digit code', () async {
    final repo = MockAuthRepository();
    expect(() => repo.verifyOtp('+255712345678', '12'), throwsA(isA<AuthException>()));
  });
}
```

- [ ] **Step 5: Run & commit.** `flutter test test/mock/mock_auth_repository_test.dart` (PASS, 3 tests). Commit: `git add lib/domain/models/auth_state.dart lib/mock/mock_auth_repository.dart test/mock/mock_auth_repository_test.dart` then `feat: add AuthState union and MockAuthRepository`.

---

## Task 4: AuthController (Notifier) + providers

**Files:** Create `app/lib/features/onboarding/presentation/auth_controller.dart`; modify `app/lib/core/providers.dart`; test `app/test/features/onboarding/auth_controller_test.dart`.

- [ ] **Step 1: Add repo/token providers to `providers.dart`.** Add imports and:
```dart
// imports
import 'storage/token_store.dart';
import '../domain/repositories/auth_repository.dart';
import '../mock/mock_auth_repository.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) {
  // Real secure storage on device; tests override with InMemoryTokenStore.
  return SecureTokenStore(const FlutterSecureStorage());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});
```
Add `import 'package:flutter_secure_storage/flutter_secure_storage.dart';` at the top of providers.dart.

- [ ] **Step 2: Write `auth_controller.dart`:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthState.unknown();
  }

  Future<void> _restore() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens == null) {
      state = const AuthState.unauthenticated();
      return;
    }
    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = AuthState.authenticated(user: user);
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> requestOtp(String phoneE164) async {
    await ref.read(authRepositoryProvider).requestOtp(phoneE164);
    state = AuthState.otpSent(phone: phoneE164);
  }

  Future<void> verifyOtp(String code) async {
    final phone = state.maybeWhen(otpSent: (p) => p, orElse: () => null);
    if (phone == null) {
      throw StateError('verifyOtp called before an OTP was requested');
    }
    final res = await ref.read(authRepositoryProvider).verifyOtp(phone, code);
    await ref.read(tokenStoreProvider).write(res.tokens);
    state = AuthState.authenticated(user: res.user);
  }

  Future<void> signOut() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
```

- [ ] **Step 3: Write the test** `app/test/features/onboarding/auth_controller_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/domain/models/auth_state.dart';
import 'package:marijoy_app/features/onboarding/presentation/auth_controller.dart';

ProviderContainer _container(TokenStore store) {
  final c = ProviderContainer(overrides: [
    tokenStoreProvider.overrideWithValue(store),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('restores to unauthenticated when no token', () async {
    final c = _container(InMemoryTokenStore());
    // build() schedules async restore; let it settle.
    c.read(authControllerProvider);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(authControllerProvider), const AuthState.unauthenticated());
  });

  test('requestOtp -> otpSent, verifyOtp -> authenticated and persists token', () async {
    final store = InMemoryTokenStore();
    final c = _container(store);
    final ctrl = c.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero); // settle restore

    await ctrl.requestOtp('+255712345678');
    expect(c.read(authControllerProvider), const AuthState.otpSent(phone: '+255712345678'));

    await ctrl.verifyOtp('123456');
    final state = c.read(authControllerProvider);
    expect(state, isA<AuthAuthenticated>());
    expect((state as AuthAuthenticated).user.phone, '+255712345678');
    expect(await store.read(), isNotNull); // token persisted
  });

  test('signOut clears token and returns to unauthenticated', () async {
    final store = InMemoryTokenStore();
    final c = _container(store);
    final ctrl = c.read(authControllerProvider.notifier);
    await ctrl.requestOtp('+255712345678');
    await ctrl.verifyOtp('123456');
    await ctrl.signOut();
    expect(c.read(authControllerProvider), const AuthState.unauthenticated());
    expect(await store.read(), isNull);
  });
}
```

- [ ] **Step 4: Run & commit.** `flutter test test/features/onboarding/auth_controller_test.dart` (PASS, 3 tests). Commit: `git add lib/core/providers.dart lib/features/onboarding/presentation/auth_controller.dart test/features/onboarding` then `feat: add AuthController with session restore and token persistence`.

---

## Task 5: Locale controller + wire into MaterialApp

**Files:** Create `app/lib/core/l10n/locale_controller.dart`; modify `app/lib/core/providers.dart`, `app/lib/app.dart`; test `app/test/core/l10n/locale_controller_test.dart`.

- [ ] **Step 1: Write `locale_controller.dart`:**
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Holds the active locale (null = follow device, resolved to sw default).
/// Initial value comes from persisted AppPrefs; changes persist back.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(appPrefsProvider).locale;
    return code == null ? null : Locale(code);
  }

  void setLocale(Locale locale) {
    ref.read(appPrefsProvider).locale = locale.languageCode;
    state = locale;
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
```

- [ ] **Step 2: Wire into `app.dart`.** In `MariJoyApp.build`, watch the locale and pass it to `MaterialApp.router`:
```dart
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: 'MariJoy',
      debugShowCheckedModeBanner: false,
      theme: MariJoyTheme.light(),
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (deviceLocale, supported) {
        for (final l in supported) {
          if (l.languageCode == deviceLocale?.languageCode) return l;
        }
        return const Locale('sw');
      },
    );
```
Add `import 'core/l10n/locale_controller.dart';` to app.dart.

- [ ] **Step 3: Write the test** `app/test/core/l10n/locale_controller_test.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/l10n/locale_controller.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';

void main() {
  test('initial locale follows persisted prefs', () {
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(InMemoryAppPrefs(locale: 'en')),
    ]);
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider), const Locale('en'));
  });

  test('setLocale updates state and persists', () {
    final prefs = InMemoryAppPrefs();
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(prefs),
    ]);
    addTearDown(c.dispose);
    expect(c.read(localeControllerProvider), isNull);
    c.read(localeControllerProvider.notifier).setLocale(const Locale('sw'));
    expect(c.read(localeControllerProvider), const Locale('sw'));
    expect(prefs.locale, 'sw');
  });
}
```

- [ ] **Step 4: Run & commit.** `flutter test test/core/l10n/locale_controller_test.dart` (PASS, 2 tests). Commit: `git add lib/core/l10n/locale_controller.dart lib/app.dart test/core/l10n/locale_controller_test.dart` then `feat: add locale controller wired into MaterialApp`.

---

## Task 6: Reactive router with auth + terms gate

**Files:** Modify `app/lib/core/router/app_router.dart`, `app/lib/core/providers.dart` (remove the obsolete `isAuthenticatedProvider`); create `app/lib/features/onboarding/presentation/splash_screen.dart`; rewrite `app/test/core/router/app_router_test.dart`; fix `app/test/app_test.dart`.

- [ ] **Step 1: Create `splash_screen.dart`:**
```dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
```

- [ ] **Step 2: Remove `isAuthenticatedProvider`** from `providers.dart` (it was a Plan-1 stub; the router now reads `authControllerProvider`).

- [ ] **Step 3: Rewrite `app_router.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../../domain/models/auth_state.dart';
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
        orElse: () => loc == '/onboarding' ? null : '/onboarding', // unauthenticated | otpSent
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
```
NOTE: this imports `onboarding_flow.dart` and `terms_screen.dart` which are created in Tasks 7–8. If you implement strictly task-by-task, temporarily create minimal stub widgets for those two files now (a `Scaffold` with `Text('Onboarding')` / `Text('Terms')`) so this task compiles and its test passes; Tasks 7–8 replace them with the real implementations. Create:
  - `app/lib/features/onboarding/presentation/onboarding_flow.dart` → `class OnboardingFlow extends StatelessWidget { const OnboardingFlow({super.key}); @override Widget build(c)=> const Scaffold(body: Center(child: Text('Onboarding'))); }` (with `import 'package:flutter/material.dart';`)
  - `app/lib/features/onboarding/presentation/terms_screen.dart` → same pattern with `Text('Terms')` and class `TermsScreen`.

- [ ] **Step 4: Rewrite `test/core/router/app_router_test.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/router/app_router.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';

Future<void> _pump(WidgetTester tester, ProviderContainer c) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp.router(routerConfig: c.read(routerProvider)),
  ));
  await tester.pumpAndSettle();
}

ProviderContainer _container({required TokenStore tokens, AppPrefs? prefs}) {
  final c = ProviderContainer(overrides: [
    tokenStoreProvider.overrideWithValue(tokens),
    appPrefsProvider.overrideWithValue(prefs ?? InMemoryAppPrefs()),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  testWidgets('no token -> lands on Onboarding', (tester) async {
    final c = _container(tokens: InMemoryTokenStore());
    await _pump(tester, c);
    expect(find.text('Onboarding'), findsOneWidget);
  });

  testWidgets('valid token but terms not accepted -> Terms', (tester) async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final c = _container(tokens: store, prefs: InMemoryAppPrefs(termsAccepted: false));
    await _pump(tester, c);
    expect(find.text('Terms'), findsOneWidget);
  });

  testWidgets('valid token and terms accepted -> Home', (tester) async {
    final store = InMemoryTokenStore();
    await store.write(const AuthTokens(accessToken: 'a', refreshToken: 'r'));
    final c = _container(tokens: store, prefs: InMemoryAppPrefs(termsAccepted: true));
    await _pump(tester, c);
    expect(find.text('Home'), findsOneWidget);
  });
}
```
(`AuthTokens` is exported via `token_store.dart`'s import of `auth.dart`; if the import isn't visible, add `import 'package:marijoy_app/domain/models/auth.dart';`.)

- [ ] **Step 5: Fix `test/app_test.dart`** so it provides the prefs override and expects Onboarding for a fresh (no-token) user:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/app.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';

void main() {
  testWidgets('app boots and shows Onboarding for a new user', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
      child: const MariJoyApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Onboarding'), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run & commit.** Run `flutter test test/core/router/app_router_test.dart test/app_test.dart` (PASS, 4 tests). Commit: `git add lib/core/router/app_router.dart lib/core/providers.dart lib/features/onboarding/presentation/splash_screen.dart lib/features/onboarding/presentation/onboarding_flow.dart lib/features/onboarding/presentation/terms_screen.dart test/core/router/app_router_test.dart test/app_test.dart` then `feat: reactive router with auth and terms gate`.

---

## Task 7: Onboarding flow UI (language → phone → OTP)

**Files:** Replace stub `app/lib/features/onboarding/presentation/onboarding_flow.dart`; create `language_step.dart`, `phone_step.dart`, `otp_step.dart`; test `app/test/features/onboarding/onboarding_flow_test.dart`.

- [ ] **Step 1: `language_step.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/locale_controller.dart';

class LanguageStep extends ConsumerWidget {
  const LanguageStep({super.key, required this.onChosen});
  final VoidCallback onChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void choose(Locale locale) {
      ref.read(localeControllerProvider.notifier).setLocale(locale);
      onChosen();
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MariJoy', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('Chagua lugha / Choose language'),
            const SizedBox(height: 32),
            FilledButton(onPressed: () => choose(const Locale('sw')), child: const Text('Kiswahili')),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => choose(const Locale('en')), child: const Text('English')),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `phone_step.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/phone/tz_phone.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/providers.dart';
import 'auth_controller.dart';

class PhoneStep extends ConsumerStatefulWidget {
  const PhoneStep({super.key});
  @override
  ConsumerState<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends ConsumerState<PhoneStep> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final e164 = TzPhone.normalize(_controller.text);
    if (e164 == null) {
      setState(() => _error = 'Namba si sahihi / Invalid number');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).requestOtp(e164);
    } on AppException catch (ex) {
      final locale = Localizations.localeOf(context).languageCode;
      setState(() => _error = ErrorMapper.message(ex, locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingiza namba / Enter number')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixText: '+255 ',
                labelText: 'Namba ya simu',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Endelea / Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: `otp_step.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/providers.dart';
import '../../../mock/mock_auth_repository.dart';
import 'auth_controller.dart';

class OtpStep extends ConsumerStatefulWidget {
  const OtpStep({super.key, required this.phone});
  final String phone;
  @override
  ConsumerState<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends ConsumerState<OtpStep> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(_controller.text.trim());
    } on AuthException {
      setState(() => _error = 'Msimbo si sahihi / Wrong code');
    } on AppException catch (ex) {
      final locale = Localizations.localeOf(context).languageCode;
      setState(() => _error = ErrorMapper.message(ex, locale));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weka msimbo / Enter code')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Tumetuma msimbo kwa ${widget.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(labelText: 'OTP', errorText: _error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Thibitisha / Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Replace `onboarding_flow.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/auth_state.dart';
import 'auth_controller.dart';
import 'language_step.dart';
import 'phone_step.dart';
import 'otp_step.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});
  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  bool _languageChosen = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final otpPhone = auth.maybeWhen(otpSent: (p) => p, orElse: () => null);
    if (otpPhone != null) return OtpStep(phone: otpPhone);
    if (!_languageChosen) {
      return LanguageStep(onChosen: () => setState(() => _languageChosen = true));
    }
    return const PhoneStep();
  }
}
```

- [ ] **Step 5: Write the widget test** `app/test/features/onboarding/onboarding_flow_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/onboarding/presentation/onboarding_flow.dart';

Widget _wrap(ProviderContainer c) => UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        locale: Locale('sw'),
        supportedLocales: [Locale('sw'), Locale('en')],
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: OnboardingFlow(),
      ),
    );

void main() {
  testWidgets('language -> phone -> otp progression', (tester) async {
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
    ]);
    addTearDown(c.dispose);
    // settle the auth restore (no token -> unauthenticated)
    c.read(authControllerProvider);
    await tester.pumpWidget(_wrap(c));
    await tester.pumpAndSettle();

    // Language step
    expect(find.text('Kiswahili'), findsOneWidget);
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();

    // Phone step
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '0712345678');
    await tester.tap(find.text('Endelea / Continue'));
    await tester.pumpAndSettle();

    // OTP step
    expect(find.text('OTP'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.text('Thibitisha / Verify'));
    await tester.pumpAndSettle();
    // After verify, auth becomes authenticated; flow widget no longer shows OTP.
    // (Routing to /terms is exercised in the integration test, Task 9.)
  });
}
```

- [ ] **Step 6: Run & commit.** `flutter test test/features/onboarding/onboarding_flow_test.dart` (PASS). Commit: `git add lib/features/onboarding/presentation test/features/onboarding/onboarding_flow_test.dart` then `feat: onboarding flow UI (language, phone, OTP)`.

---

## Task 8: Terms & Conditions screen + acceptance

**Files:** Replace stub `app/lib/features/onboarding/presentation/terms_screen.dart`; test `app/test/features/onboarding/terms_screen_test.dart`.

- [ ] **Step 1: Replace `terms_screen.dart`:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import 'auth_controller.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masharti / Terms')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Kwa kukodi benki ya MariJoy, unakubali ada ya ucheleweshaji '
                  'na ada ya kupoteza benki kama ilivyoainishwa.\n\n'
                  'By renting a MariJoy power bank, you agree to the overage and '
                  'lost-bank fees as described.',
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                ref.read(appPrefsProvider).termsAccepted = true;
                // Nudge the router to re-evaluate by re-reading auth state.
                ref.read(authControllerProvider.notifier).acknowledgeTerms();
              },
              child: const Text('Nakubali / I accept'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Add `acknowledgeTerms()` to `AuthController`** (in `auth_controller.dart`) so accepting terms triggers the router's `refreshListenable` (which listens to auth changes). Add this method:
```dart
  /// Re-emit the current authenticated state so the router re-evaluates the
  /// terms gate after the user accepts T&Cs.
  void acknowledgeTerms() {
    final s = state;
    if (s is AuthAuthenticated) {
      state = AuthState.authenticated(user: s.user);
    }
  }
```
(Notifier setting `state` to an equal value still notifies listeners because it's a new instance.)

- [ ] **Step 3: Write the test** `app/test/features/onboarding/terms_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';
import 'package:marijoy_app/features/onboarding/presentation/terms_screen.dart';

void main() {
  testWidgets('accepting terms persists the flag', (tester) async {
    final prefs = InMemoryAppPrefs();
    final c = ProviderContainer(overrides: [
      appPrefsProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
    ]);
    addTearDown(c.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: TermsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(prefs.termsAccepted, isFalse);
    await tester.tap(find.text('Nakubali / I accept'));
    await tester.pump();
    expect(prefs.termsAccepted, isTrue);
  });
}
```

- [ ] **Step 4: Run & commit.** `flutter test test/features/onboarding/terms_screen_test.dart` (PASS). Commit: `git add lib/features/onboarding/presentation/terms_screen.dart lib/features/onboarding/presentation/auth_controller.dart test/features/onboarding/terms_screen_test.dart` then `feat: add T&Cs screen and acceptance`.

---

## Task 9: Full onboarding integration test + DoD

**Files:** Create `app/test/features/onboarding/onboarding_integration_test.dart`.

- [ ] **Step 1: Write the integration test** (drives the real router end to end):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/app.dart';
import 'package:marijoy_app/core/providers.dart';
import 'package:marijoy_app/core/storage/app_prefs.dart';
import 'package:marijoy_app/core/storage/token_store.dart';

void main() {
  testWidgets('new user: language -> phone -> otp -> terms -> home', (tester) async {
    final c = ProviderScope(
      overrides: [
        appPrefsProvider.overrideWithValue(InMemoryAppPrefs()),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      ],
      child: const MariJoyApp(),
    );
    await tester.pumpWidget(c);
    await tester.pumpAndSettle();

    // Language
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();
    // Phone
    await tester.enterText(find.byType(TextField), '0712345678');
    await tester.tap(find.text('Endelea / Continue'));
    await tester.pumpAndSettle();
    // OTP
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.text('Thibitisha / Verify'));
    await tester.pumpAndSettle();
    // Terms gate
    expect(find.text('Masharti / Terms'), findsOneWidget);
    await tester.tap(find.text('Nakubali / I accept'));
    await tester.pumpAndSettle();
    // Home
    expect(find.text('Home'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Definition of done.** Run the FULL suite: `flutter test` — all tests (Plan 1 + Plan 2) must pass; report the count. Run `flutter analyze` — must be clean.

- [ ] **Step 3: Commit.** `git add test/features/onboarding/onboarding_integration_test.dart` then `test: add onboarding integration test`.

---

## Self-review notes (against the design spec)

- **Spec coverage:** language pick (sw/en, persisted) ✓ T5/T7; phone +255 validation ✓ T2/T7; SMS OTP request+verify ✓ T3/T4/T7; JWT session + secure token persistence ✓ T4; session restore on launch ✓ T4; T&Cs acceptance on first login ✓ T8; auth-gated routing ✓ T6. Deferred (noted): the 401 refresh-on-error interceptor and `/me`-backed profile editing land in Plan 5 (real HTTP repos) — the mock has no real 401 to exercise.
- **Placeholder scan:** `/home`, `/scan`, etc. remain intentional placeholders (Plans 3–4). The temporary stub widgets in Task 6 are explicitly replaced in Tasks 7–8. No "TBD"/vague steps.
- **Type consistency:** `AuthState` union member classes (`AuthUnknown`, `AuthUnauthenticated`, `AuthOtpSent`, `AuthAuthenticated`) are used consistently across the controller (`maybeWhen`), router (`maybeWhen`), and tests (`isA<AuthAuthenticated>()`). `authControllerProvider`, `tokenStoreProvider`, `appPrefsProvider`, `authRepositoryProvider`, `localeControllerProvider` names match across providers, controllers, router, and tests.
```
