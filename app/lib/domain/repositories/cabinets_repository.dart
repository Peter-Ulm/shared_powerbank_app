import '../models/cabinet.dart';

abstract class CabinetsRepository {
  Future<List<Cabinet>> nearby({required double lat, required double lng, double radiusM});
  Future<Cabinet> byId(String id);
}
