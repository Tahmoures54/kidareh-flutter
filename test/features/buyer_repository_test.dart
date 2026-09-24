import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/features/buyer/buyer_repository.dart';

void main() {
  group('buyer product helpers', () {
    test('recognizes supported available statuses', () {
      expect(isBuyerProductAvailable('موجود'), isTrue);
      expect(isBuyerProductAvailable(' فقط ۱ عدد '), isTrue);
      expect(isBuyerProductAvailable('available'), isTrue);
      expect(isBuyerProductAvailable('ناموجود'), isFalse);
      expect(isBuyerProductAvailable(null), isFalse);
    });

    test('formats numeric and string prices as toman', () {
      expect(buyerPriceLabel(125000), '125000 تومان');
      expect(buyerPriceLabel('125,000'), '125000 تومان');
      expect(buyerPriceLabel(' 125000 '), '125000 تومان');
      expect(buyerPriceLabel(0), 'قیمت توافقی');
      expect(buyerPriceLabel(null), 'قیمت توافقی');
    });

    test('normalizes missing product status', () {
      expect(buyerStatusLabel(' موجود '), 'موجود');
      expect(buyerStatusLabel(''), 'ناموجود');
      expect(buyerStatusLabel('   '), 'ناموجود');
      expect(buyerStatusLabel(null), 'ناموجود');
    });
  });
}
