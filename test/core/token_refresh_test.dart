import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/features/auth/auth_repository.dart';

void main() {
  test('accepts a non-empty access token', () {
    expect(requireAccessToken({'accessToken': 'token'}), 'token');
  });

  test('rejects malformed auth responses', () {
    for (final value in <Object?>[
      null,
      [],
      {'accessToken': null},
      {'accessToken': 123},
      {'accessToken': ''},
    ]) {
      expect(() => requireAccessToken(value), throwsFormatException);
    }
  });

  test('rejects whitespace-only token', () {
    expect(() => requireAccessToken({'accessToken': '   '}), throwsFormatException);
  });
}