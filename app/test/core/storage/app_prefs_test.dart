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
