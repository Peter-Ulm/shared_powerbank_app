import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:marijoy_app/data/http/http_auth_repository.dart';
import 'package:marijoy_app/data/http/http_cabinets_repository.dart';
import 'package:marijoy_app/data/http/http_orders_repository.dart';
import 'package:marijoy_app/domain/models/order.dart';
import 'package:marijoy_app/domain/models/wallet.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'));
    adapter = DioAdapter(dio: dio);
  });

  test('verifyOtp parses tokens and user', () async {
    adapter.onPost('/auth/otp/verify', (s) => s.reply(200, {
          'accessToken': 'a',
          'refreshToken': 'r',
          'user': {'id': 'U1', 'phone': '+255712345678', 'locale': 'sw', 'status': 'active'},
        }), data: {'phone': '+255712345678', 'code': '123456'});
    final res = await HttpAuthRepository(dio).verifyOtp('+255712345678', '123456');
    expect(res.tokens.accessToken, 'a');
    expect(res.user.phone, '+255712345678');
  });

  test('cabinets nearby parses a list', () async {
    adapter.onGet('/cabinets', (s) => s.reply(200, [
          {
            'id': 'CAB001', 'label': 'Posta', 'banksAvailable': 4, 'freeSlots': 6,
            'online': true, 'lat': -6.8, 'lng': 39.2,
          },
        ]));
    final list = await HttpCabinetsRepository(dio).nearby(lat: -6.8, lng: 39.2);
    expect(list, hasLength(1));
    expect(list.first.id, 'CAB001');
  });

  test('order create sends Idempotency-Key and parses orderId', () async {
    String? capturedKey;
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      capturedKey = o.headers['Idempotency-Key'] as String?;
      h.next(o);
    }));
    adapter.onPost('/orders', (s) => s.reply(201, {
          'orderId': 'ORD9', 'status': 'payment_pending', 'amountTzs': 1000,
        }), data: {'cabinetId': 'CAB001', 'qty': 1, 'wallet': 'mpesa'});
    final order = await HttpOrdersRepository(dio).create(
      cabinetId: 'CAB001', qty: 1, wallet: Wallet.mpesa, idempotencyKey: 'idem-1',
    );
    expect(order.id, 'ORD9');
    expect(order.status, OrderStatus.paymentPending);
    expect(capturedKey, 'idem-1');
  });
}
