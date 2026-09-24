import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/core/models/product.dart';
import 'package:kidareh_flutter/core/models/store.dart';

void main() {
  test('parses product json with nested store', () {
    final product = Product.fromJson({
      'id': '12',
      'title': 'شیر',
      'price': '25000',
      'status': 'موجود',
      'store': {'id': 4, 'name': 'لبنیات', 'city': 'تهران', 'phone': '09120000000'},
    });

    expect(product.id, 12);
    expect(product.name, 'شیر');
    expect(product.priceLabel, '25000 تومان');
    expect(product.available, isTrue);
    expect(product.storeName, 'لبنیات');
    expect(product.storeCity, 'تهران');
  });

  test('parses seller stats', () {
    final stats = SellerStats.fromJson({
      'product_count': '3',
      'total_views': 10,
      'follower_count': '2',
    });
    expect(stats.productCount, 3);
    expect(stats.totalViews, 10);
    expect(stats.followerCount, 2);
  });
}
