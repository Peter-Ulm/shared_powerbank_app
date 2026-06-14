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
    expect(parseCabinetId('  cab003  '), 'CAB003');
  });
  test('rejects junk', () {
    expect(parseCabinetId(''), isNull);
    expect(parseCabinetId('https://example.com/foo'), isNull);
    expect(parseCabinetId('hello world'), isNull);
  });
}
