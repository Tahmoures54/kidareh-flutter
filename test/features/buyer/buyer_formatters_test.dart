import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/features/buyer/buyer_repository.dart';

void main() {
  test('price label accepts numeric values', () {
    expect(buyerPriceLabel(125000), '125000 تومان');
    expect(buyerPriceLabel(125000.5), '125000 تومان');
  });

  test('price label treats zero, null and strings as agreement price', () {
    expect(buyerPriceLabel(0), 'قیمت توافقی');
    expect(buyerPriceLabel(null), 'قیمت توافقی');
    expect(buyerPriceLabel('125000'), '125000 تومان');
    expect(buyerPriceLabel('125,000'), '125000 تومان');
  });

  test('availability matches supported backend statuses', () {
    expect(isBuyerProductAvailable('موجود'), isTrue);
    expect(isBuyerProductAvailable('فقط ۱ عدد'), isTrue);
    expect(isBuyerProductAvailable('available'), isTrue);
    expect(isBuyerProductAvailable('ناموجود'), isFalse);
    expect(isBuyerProductAvailable(null), isFalse);
  });

  test('status label normalizes empty values', () {
    expect(buyerStatusLabel('  موجود  '), 'موجود');
    expect(buyerStatusLabel(''), 'ناموجود');
    expect(buyerStatusLabel(null), 'ناموجود');
  });
}
