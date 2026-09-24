import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class BuyerSearchPage {
  const BuyerSearchPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<Map<String, dynamic>> items;
  final bool hasMore;
  final String? nextCursor;
}

class BuyerRepository {
  BuyerRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;

  final Dio _dio;

  Future<BuyerSearchPage> search(
    String query, {
    String? cursor,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {
        'q': query,
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'sort': 'newest',
        'scope': 'all',
      },
    );

    final data = response.data;
    if (data is! Map) {
      throw const FormatException('پاسخ جستجو نامعتبر است');
    }

    final raw = data['products'];
    final products = raw is List
        ? raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    return BuyerSearchPage(
      items: products,
      hasMore: data['hasMore'] == true,
      nextCursor: data['nextCursor']?.toString(),
    );
  }
  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await _dio.get('/products/$id');
    final data = response.data;
    if (data is Map) {
      final raw = data['product'] ?? data;
      if (raw is Map) return Map<String, dynamic>.from(raw);
    }
    throw const FormatException('اطلاعات کالا نامعتبر است');
  }
  Future<Map<String, dynamic>> getStore(int id) async {
    final response = await _dio.get('/stores/$id');
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('اطلاعات فروشگاه نامعتبر است');
  }
}
