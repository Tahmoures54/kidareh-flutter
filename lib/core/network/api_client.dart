import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';

String networkErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'ارتباط با سرور زمان‌بر شد. دوباره تلاش کن.';
      case DioExceptionType.connectionError:
        return 'اتصال اینترنت برقرار نیست. اینترنت را بررسی کن و دوباره تلاش کن.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code != null && code >= 500) return 'سرور موقتاً در دسترس نیست. دوباره تلاش کن.';
        if (code == 404) return 'این مورد پیدا نشد.';
        break;
      case DioExceptionType.cancel:
        return 'درخواست لغو شد.';
      default:
        break;
    }
  }
  return 'ارتباط با سرور انجام نشد. دوباره تلاش کن.';
}

final dioProvider = DioProvider();

class DioProvider {
  Future<bool>? _refreshFuture;

  DioProvider() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['X-Kidareh-Client'] = 'mobile';
        final token = await _storage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ' + token;
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('/auth/refresh') &&
            error.requestOptions.extra['_kidarehRetried'] != true) {
          if (await _refresh()) {
            final request = error.requestOptions;
            request.extra['_kidarehRetried'] = true;
            final token = await _storage.read();
            request.headers['Authorization'] = 'Bearer ' + (token ?? '');
            try {
              return handler.resolve(await dio.fetch(request));
            } catch (_) {}
          }
        }
        handler.next(error);
      },
    ));
  }

  final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  final TokenStorage _storage = const TokenStorage();

  Future<bool> _refresh() {
    final inFlight = _refreshFuture;
    if (inFlight != null) return inFlight;

    final future = _performRefresh();
    _refreshFuture = future;
    future.whenComplete(() {
      if (identical(_refreshFuture, future)) _refreshFuture = null;
    });
    return future;
  }

  Future<bool> _performRefresh() async {
    try {
      final r = await dio.post('/auth/refresh');
      final data = r.data;
      if (data is! Map) return false;
      final token = data['accessToken'];
      if (token is! String || token.isEmpty) return false;
      await _storage.write(token);
      return true;
    } catch (_) {
      return false;
    }
  }
}
