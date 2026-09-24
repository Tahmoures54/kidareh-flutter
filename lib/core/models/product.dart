class Product {
  const Product({
    required this.id,
    required this.name,
    this.price,
    this.status = '',
    this.description = '',
    this.imageUrl = '',
    this.storeId,
    this.storeName = '',
    this.storeCity = '',
    this.storeAddress = '',
    this.storePhone = '',
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final num? price;
  final String status;
  final String description;
  final String imageUrl;
  final int? storeId;
  final String storeName;
  final String storeCity;
  final String storeAddress;
  final String storePhone;
  final double? latitude;
  final double? longitude;

  bool get available {
    final normalized = status.trim().toLowerCase();
    return normalized == 'موجود' ||
        normalized == 'فقط ۱ عدد' ||
        normalized == 'available';
  }

  String get priceLabel {
    final value = price;
    if (value != null && value > 0) return '${value.toInt()} تومان';
    return 'قیمت توافقی';
  }

  String get statusLabel => status.trim().isEmpty ? 'ناموجود' : status.trim();

  factory Product.fromJson(Map<String, dynamic> json) {
    final storeRaw = json['store'];
    final store = storeRaw is Map ? Map<String, dynamic>.from(storeRaw) : const <String, dynamic>{};
    return Product(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? json['title'] ?? 'کالا').toString(),
      price: json['price'] is num
          ? json['price'] as num
          : num.tryParse(json['price']?.toString().replaceAll(',', '') ?? ''),
      status: (json['status'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['image'] ?? store['image_url'] ?? '').toString().trim(),
      storeId: int.tryParse(json['store_id']?.toString() ?? store['id']?.toString() ?? ''),
      storeName: (json['store_name'] ?? store['name'] ?? '').toString(),
      storeCity: (json['store_city'] ?? store['city'] ?? json['city'] ?? '').toString(),
      storeAddress: (json['address'] ?? store['address'] ?? json['store_address'] ?? '').toString(),
      storePhone: (json['store_phone'] ?? store['phone'] ?? json['phone'] ?? '').toString().trim(),
      latitude: double.tryParse(
        json['lat']?.toString() ??
            json['latitude']?.toString() ??
            store['lat']?.toString() ??
            store['latitude']?.toString() ??
            '',
      ),
      longitude: double.tryParse(
        json['lng']?.toString() ??
            json['longitude']?.toString() ??
            store['lng']?.toString() ??
            store['longitude']?.toString() ??
            '',
      ),
    );
  }
}
