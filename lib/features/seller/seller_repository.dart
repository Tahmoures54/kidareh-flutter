import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';
import '../../core/network/api_client.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) => SellerRepository());

class SellerRepository {
  SellerRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;

  Future<List<Product>> fetchProducts() async {
    final data = (await _dio.get('/products/seller')).data;
    final raw = data is List ? data : data is Map ? data['products'] : null;
    if (raw is! List) {
      throw const FormatException('فهرست کالاهای فروشنده نامعتبر است');
    }
    return raw
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id > 0)
        .toList();
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
  }

  Future<Product> updateProduct(
    int id, {
    required String name,
    required num price,
    required String status,
    String? description,
  }) async {
    final data = (await _dio.put('/products/$id', data: {
      'name': name.trim(),
      'price': price,
      'status': status.trim(),
      if (description != null) 'description': description.trim(),
    })).data;
    if (data is! Map) {
      throw const FormatException('پاسخ بروزرسانی کالا نامعتبر است');
    }
    final raw = data['product'] is Map ? data['product'] : data;
    return Product.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<Product> createProduct({
    required String name,
    required num price,
    required String status,
    String? description,
  }) async {
    final data = (await _dio.post('/products', data: {
      'name': name.trim(),
      'price': price,
      'status': status.trim(),
      if (description?.trim().isNotEmpty == true) 'description': description!.trim(),
    })).data;
    if (data is! Map) {
      throw const FormatException('پاسخ ثبت کالا نامعتبر است');
    }
    final raw = data['product'] is Map ? data['product'] : data;
    return Product.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<Store> fetchMyStore() async {
    final data = (await _dio.get('/stores/my/store')).data;
    if (data is! Map) {
      throw const FormatException('اطلاعات فروشگاه نامعتبر است');
    }
    return Store.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Store> updateMyStore({
    required String name,
    required String address,
    required String phone,
    String? description,
    String? category,
    String? city,
    String? province,
  }) async {
    final data = (await _dio.put('/stores/my/store', data: {
      'name': name.trim(),
      'address': address.trim(),
      'phone': phone.trim(),
      if (description != null) 'description': description.trim(),
      if (category != null) 'category': category.trim(),
      if (city != null) 'city': city.trim(),
      if (province != null) 'province': province.trim(),
    })).data;
    if (data is! Map) {
      throw const FormatException('پاسخ بروزرسانی فروشگاه نامعتبر است');
    }
    return Store.fromJson(Map<String, dynamic>.from(data));
  }

  Future<SellerStats> fetchMyStats() async {
    final data = (await _dio.get('/stores/my/stats')).data;
    if (data is! Map) {
      throw const FormatException('آمار فروشگاه نامعتبر است');
    }
    return SellerStats.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<Map<String, String>>> fetchMyFollowers() async {
    final data = (await _dio.get('/stores/my/followers')).data;
    final raw = data is List ? data : data is Map ? data['followers'] : null;
    if (raw is! List) {
      throw const FormatException('فهرست دنبال‌کنندگان نامعتبر است');
    }
    return raw.whereType<Map>().map((item) {
      return {
        'name': (item['name'] ?? '').toString(),
        'phone': (item['phone'] ?? '').toString(),
        'followed_at': (item['followed_at'] ?? '').toString(),
      };
    }).toList();
  }
}
