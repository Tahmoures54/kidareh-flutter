import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidareh_flutter/core/network/api_client.dart';

DioException dioError(
  DioExceptionType type, {
  int? statusCode,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    response: statusCode == null
        ? null
        : Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          ),
  );
}

void main() {
  test('timeout errors use a retryable Persian message', () {
    expect(
      networkErrorMessage(dioError(DioExceptionType.connectionTimeout)),
      'ارتباط با سرور زمان‌بر شد. دوباره تلاش کن.',
    );
    expect(
      networkErrorMessage(dioError(DioExceptionType.receiveTimeout)),
      'ارتباط با سرور زمان‌بر شد. دوباره تلاش کن.',
    );
  });

  test('connection errors explain that internet should be checked', () {
    expect(
      networkErrorMessage(dioError(DioExceptionType.connectionError)),
      'اتصال اینترنت برقرار نیست. اینترنت را بررسی کن و دوباره تلاش کن.',
    );
  });

  test('server and not-found responses get distinct messages', () {
    expect(
      networkErrorMessage(dioError(DioExceptionType.badResponse, statusCode: 500)),
      'سرور موقتاً در دسترس نیست. دوباره تلاش کن.',
    );
    expect(
      networkErrorMessage(dioError(DioExceptionType.badResponse, statusCode: 404)),
      'این مورد پیدا نشد.',
    );
  });

  test('unknown errors keep a safe generic message', () {
    expect(
      networkErrorMessage(StateError('unexpected')),
      'ارتباط با سرور انجام نشد. دوباره تلاش کن.',
    );
  });
}
