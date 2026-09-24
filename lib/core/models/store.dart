import 'product.dart';

class Store {
  const Store({
    required this.id,
    required this.name,
    this.city = '',
    this.province = '',
    this.address = '',
    this.phone = '',
    this.description = '',
    this.category = '',
    this.imageUrl = '',
    this.latitude,
    this.longitude,
    this.products = const [],
  });

  final int id;
  final String name;
  final String city;
  final String province;
  final String address;
  final String phone;
  final String description;
  final String category;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final List<Product> products;

  factory Store.fromJson(Map<String, dynamic> json) {
    final raw = json['store'] is Map ? Map<String, dynamic>.from(json['store'] as Map) : json;
    final productsRaw = raw['products'];
    return Store(
      id: int.tryParse(raw['id']?.toString() ?? '') ?? 0,
      name: (raw['name'] ?? 'فروشگاه').toString(),
      city: (raw['city'] ?? '').toString(),
      province: (raw['province'] ?? '').toString(),
      address: (raw['address'] ?? '').toString(),
      phone: (raw['phone'] ?? '').toString().trim(),
      description: (raw['description'] ?? '').toString(),
      category: (raw['category'] ?? '').toString(),
      imageUrl: (raw['image'] ?? raw['image_url'] ?? '').toString().trim(),
      latitude: double.tryParse(raw['latitude']?.toString() ?? raw['lat']?.toString() ?? ''),
      longitude: double.tryParse(raw['longitude']?.toString() ?? raw['lng']?.toString() ?? ''),
      products: productsRaw is List
          ? productsRaw.whereType<Map>().map((item) => Product.fromJson(Map<String, dynamic>.from(item))).toList()
          : const [],
    );
  }
}

class SellerStats {
  const SellerStats({
    this.productCount = 0,
    this.totalViews = 0,
    this.followerCount = 0,
  });

  final int productCount;
  final int totalViews;
  final int followerCount;

  factory SellerStats.fromJson(Map<String, dynamic> json) {
    return SellerStats(
      productCount: int.tryParse(json['product_count']?.toString() ?? '') ?? 0,
      totalViews: int.tryParse(json['total_views']?.toString() ?? '') ?? 0,
      followerCount: int.tryParse(json['follower_count']?.toString() ?? '') ?? 0,
    );
  }
}
