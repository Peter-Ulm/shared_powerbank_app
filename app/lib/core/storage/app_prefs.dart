import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive app preferences (locale, T&Cs acceptance). Sensitive data
/// (tokens) lives in TokenStore, not here.
abstract class AppPrefs {
  String? get locale;
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
