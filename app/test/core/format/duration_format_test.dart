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
