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
