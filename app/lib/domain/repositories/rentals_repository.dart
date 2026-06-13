import '../models/rental.dart';

abstract class RentalsRepository {
  Future<List<Rental>> list({RentalStatus? status});
  Future<Rental> byId(String id);
  Stream<List<Rental>> watchActive();
}
