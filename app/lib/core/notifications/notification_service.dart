/// Push-notification abstraction. The mock is a no-op; a real
/// FcmNotificationService (firebase_messaging) is a drop-in once Firebase is
/// configured. The app never depends on push for correctness (SMS is the
/// backend's fallback for money events) — only convenience.
abstract class NotificationService {
  Future<String?> registerToken();
  Future<void> clear();
}

class NoopNotificationService implements NotificationService {
  const NoopNotificationService();
  @override
  Future<String?> registerToken() async => null;
  @override
  Future<void> clear() async {}
}
