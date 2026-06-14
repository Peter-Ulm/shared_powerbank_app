/// A simple lat/lng point (decoupled from any map/geo package).
class LatLngPoint {
  const LatLngPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

abstract class LocationService {
  Future<LatLngPoint> current();
}

/// Fixed Dar es Salaam city-centre location. A real geolocator-backed impl
/// (with permission handling) replaces this in a later plan.
class MockLocationService implements LocationService {
  const MockLocationService();
  @override
  Future<LatLngPoint> current() async => const LatLngPoint(-6.776, 39.178);
}
