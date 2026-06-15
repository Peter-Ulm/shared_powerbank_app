import 'package:dio/dio.dart';
import '../../domain/models/cabinet.dart';
import '../../domain/repositories/cabinets_repository.dart';

class HttpCabinetsRepository implements CabinetsRepository {
  HttpCabinetsRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Cabinet>> nearby({required double lat, required double lng, double radiusM = 2000}) async {
    final res = await _dio.get('/cabinets', queryParameters: {'lat': lat, 'lng': lng, 'radius': radiusM});
    final list = (res.data as List).cast<Map>();
    return list.map((m) => Cabinet.fromJson(m.cast<String, dynamic>())).toList();
  }

  @override
  Future<Cabinet> byId(String id) async {
    final res = await _dio.get('/cabinets/$id');
    return Cabinet.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
