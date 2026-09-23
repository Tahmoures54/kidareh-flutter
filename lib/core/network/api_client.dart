import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/token_storage.dart';

final dioProvider = DioProvider();

class DioProvider {
  DioProvider() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['X-Kidareh-Client'] = 'mobile';
        final token = await _storage.read();
        if (token != null && token.isNotEmpty) options.headers['Authorization'] = 'Bearer ' + token;
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/refresh')) {
          if (await _refresh()) {
            final request = error.requestOptions;
            final token = await _storage.read();
            request.headers['Authorization'] = 'Bearer ' + (token ?? '');
            try { return handler.resolve(await dio.fetch(request)); } catch (_) {}
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
    headers: const {'Accept':'application/json','Content-Type':'application/json'},
  ));
  final TokenStorage _storage = const TokenStorage();
  Future<bool> _refresh() async {
    try {
      final r = await dio.post('/auth/refresh');
      final token = r.data['accessToken'] as String?;
      if (token == null || token.isEmpty) return false;
      await _storage.write(token);
      return true;
    } catch (_) { return false; }
  }
}
