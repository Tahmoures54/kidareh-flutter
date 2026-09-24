import 'package:dio/dio.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';
import '../../core/network/api_client.dart';

bool isBuyerProductAvailable(Object? status) {
  if (status is! String) return false;
  final normalized = status.trim().toLowerCase();
  return normalized == 'موجود' ||
      normalized == 'فقط ۱ عدد' ||
      normalized == 'available';
}

String buyerPriceLabel(Object? value) {
  if (value is num && value > 0) {
    return '${value.toInt()} تومان';
  }
  if (value is String) {
    final normalized = value.trim().replaceAll(',', '');
    final parsed = num.tryParse(normalized);
    if (parsed != null && parsed > 0) {
      return '${parsed.toInt()} تومان';
    }
  }
  return 'قیمت توافقی';
}

String buyerStatusLabel(Object? value) {
  if (value is! String || value.trim().isEmpty) return 'ناموجود';
  return value.trim();
}

class BuyerSearchPage {
  const BuyerSearchPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<Product> items;
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
    if (raw is! List) {
      throw const FormatException('فهرست نتایج جستجو نامعتبر است');
    }
    final products = raw
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id > 0)
        .toList();
    final hasMore = data['hasMore'] == true;
    final rawCursor = data['nextCursor'];
    final nextCursor = rawCursor is String && rawCursor.trim().isNotEmpty
        ? rawCursor.trim()
        : null;
    if (hasMore && nextCursor == null) {
      throw const FormatException('ادامه نتایج جستجو نامعتبر است');
    }
    return BuyerSearchPage(
      items: products,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  Future<Product> getProduct(int id) async {
    if (id <= 0) throw const FormatException('شناسه کالا نامعتبر است');
    final response = await _dio.get('/products/$id');
    final data = response.data;
    if (data is Map) {
      final raw = data['product'] ?? data;
      if (raw is Map) {
        final product = Product.fromJson(Map<String, dynamic>.from(raw));
        if (product.id <= 0) {
          throw const FormatException('اطلاعات کالا نامعتبر است');
        }
        return product;
      }
    }
    throw const FormatException('اطلاعات کالا نامعتبر است');
  }

  Future<Store> getStore(int id) async {
    if (id <= 0) throw const FormatException('شناسه فروشگاه نامعتبر است');
    final response = await _dio.get('/stores/$id');
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('اطلاعات فروشگاه نامعتبر است');
    }
    final store = Store.fromJson(Map<String, dynamic>.from(data));
    if (store.id <= 0) {
      throw const FormatException('اطلاعات فروشگاه نامعتبر است');
    }
    return store;
  }
}
