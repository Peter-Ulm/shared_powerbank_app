import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/format/money.dart';

void main() {
  test('formats thousands', () {
    expect(formatTzs(500), 'TZS 500');
    expect(formatTzs(1000), 'TZS 1,000');
    expect(formatTzs(2500000), 'TZS 2,500,000');
  });
}
