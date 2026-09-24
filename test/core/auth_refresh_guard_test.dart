import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/core/network/api_client.dart';

void main() {
  RequestOptions request(String path) => RequestOptions(path: path);

  test('does not refresh authentication endpoints after 401', () {
    expect(shouldRefreshAfterUnauthorized(request('/auth/send-otp')), isFalse);
    expect(shouldRefreshAfterUnauthorized(request('/auth/verify-otp')), isFalse);
    expect(shouldRefreshAfterUnauthorized(request('/auth/refresh')), isFalse);
    expect(shouldRefreshAfterUnauthorized(request('/auth/logout')), isFalse);
  });

  test('refreshes ordinary authenticated endpoints after 401', () {
    expect(shouldRefreshAfterUnauthorized(request('/auth/me')), isTrue);
    expect(shouldRefreshAfterUnauthorized(request('/products/search')), isTrue);
    expect(shouldRefreshAfterUnauthorized(request('/stores/my/store')), isTrue);
  });
}
