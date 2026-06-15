import 'dart:async';
import 'package:dio/dio.dart';
import '../../domain/models/rental.dart';
import '../../domain/repositories/rentals_repository.dart';

class HttpRentalsRepository implements RentalsRepository {
  HttpRentalsRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Rental>> list({RentalStatus? status}) async {
    final res = await _dio.get('/rentals',
        queryParameters: {if (status != null) 'status': status.name});
    final list = (res.data as List).cast<Map>();
    return list.map((m) => Rental.fromJson(m.cast<String, dynamic>())).toList();
  }

  @override
  Future<Rental> byId(String id) async {
    final res = await _dio.get('/rentals/$id');
    return Rental.fromJson((res.data as Map).cast<String, dynamic>());
  }

  @override
  Stream<List<Rental>> watchActive() async* {
    yield await list(status: RentalStatus.active);
  }
}
