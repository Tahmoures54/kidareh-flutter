import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kidareh_flutter/features/buyer/buyer_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late BuyerRepository repo;

  setUp(() {
    dio = MockDio();
    repo = BuyerRepository(dio: dio);
  });

  test('search parses products and cursor pagination', () async {
    when(() => dio.get(
      '/products/search',
      queryParameters: any(named: 'queryParameters'),
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/products/search'),
      data: {
        'products': [{'id': 12, 'name': 'کالای تست'}],
        'hasMore': true,
        'nextCursor': 'abc',
      },
    ));

    final result = await repo.search('کالا');

    expect(result.items.single['id'], 12);
    expect(result.hasMore, isTrue);
    expect(result.nextCursor, 'abc');
  });

  test('search forwards cursor, limit and sort contract', () async {
    when(() => dio.get(
      '/products/search',
      queryParameters: any(named: 'queryParameters'),
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/products/search'),
      data: {'products': [], 'hasMore': false},
    ));

    await repo.search('پیچ', cursor: 'v2:10', limit: 10);

    verify(() => dio.get(
      '/products/search',
      queryParameters: {
        'q': 'پیچ',
        'limit': 10,
        'cursor': 'v2:10',
        'sort': 'newest',
        'scope': 'all',
      },
    )).called(1);
  });

  test('getProduct unwraps product payload', () async {
    when(() => dio.get('/products/12')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/products/12'),
      data: {'product': {'id': 12, 'store_id': 7, 'name': 'کالای تست'}},
    ));

    final result = await repo.getProduct(12);

    expect(result['store_id'], 7);
    expect(result['name'], 'کالای تست');
  });

  test('getStore accepts normalized public store payload', () async {
    when(() => dio.get('/stores/7')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/stores/7'),
      data: {
        'id': 7,
        'name': 'فروشگاه تست',
        'phone': '09120000000',
        'latitude': 35.7,
        'longitude': 51.4,
        'products': [{'id': 12, 'name': 'کالای تست'}],
      },
    ));

    final result = await repo.getStore(7);

    expect(result['id'], 7);
    expect(result['phone'], '09120000000');
    expect(result['products'], isA<List>());
  });

  test('getStore rejects non-map payloads', () async {
    when(() => dio.get('/stores/7')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/stores/7'),
      data: <dynamic>[],
    ));

    expect(() => repo.getStore(7), throwsA(isA<FormatException>()));
  });
}
