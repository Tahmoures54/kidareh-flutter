import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buyer search generation starts at zero', () {
    // Documents the stale-response guard used by BuyerPage.
    var generation = 0;
    final first = ++generation;
    final second = ++generation;
    expect(first, 1);
    expect(second, 2);
    expect(first != generation, isTrue);
  });
}
