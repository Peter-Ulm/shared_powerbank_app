import 'package:flutter_test/flutter_test.dart';
import 'package:marijoy_app/core/notifications/notification_service.dart';

void main() {
  test('noop notification service returns null token and clears quietly', () async {
    const svc = NoopNotificationService();
    expect(await svc.registerToken(), isNull);
    await svc.clear(); // no throw
  });
}
