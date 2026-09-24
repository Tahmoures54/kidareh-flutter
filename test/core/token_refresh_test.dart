import 'package:flutter_test/flutter_test.dart';

bool isValidAccessTokenResponse(Object? data) {
  if (data is! Map) return false;
  final token = data['accessToken'];
  return token is String && token.isNotEmpty;
}

void main() {
  test('accepts a non-empty access token', () {
    expect(isValidAccessTokenResponse({'accessToken': 'token'}), isTrue);
  });

  test('rejects malformed refresh responses', () {
    expect(isValidAccessTokenResponse(null), isFalse);
    expect(isValidAccessTokenResponse([]), isFalse);
    expect(isValidAccessTokenResponse({'accessToken': null}), isFalse);
    expect(isValidAccessTokenResponse({'accessToken': 123}), isFalse);
    expect(isValidAccessTokenResponse({'accessToken': ''}), isFalse);
  });
}
