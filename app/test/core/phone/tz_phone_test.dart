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
    expect(TzPhone.normalize('071234567'), isNull);
    expect(TzPhone.normalize('07123456789'), isNull);
  });
  test('isValid reflects normalization', () {
    expect(TzPhone.isValid('0712 345 678'), isTrue);
    expect(TzPhone.isValid('abc'), isFalse);
  });
}
