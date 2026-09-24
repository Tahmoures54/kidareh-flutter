import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

String requireAccessToken(Object? data) {
  if (data is! Map) throw const FormatException('پاسخ ورود نامعتبر است');
  final token = data['accessToken'];
  if (token is! String || token.trim().isEmpty) {
    throw const FormatException('توکن ورود نامعتبر است');
  }
  return token;
}

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio=dio ?? dioProvider.dio;
  final Dio _dio;
  final TokenStorage _storage=const TokenStorage();

  Future<Map<String,dynamic>> sendOtp(String phone) async =>
    Map<String,dynamic>.from((await _dio.post('/auth/send-otp',data:{'phone':phone})).data);

  Future<Map<String,dynamic>> verifyOtp(String phone,String code) async {
    final r=await _dio.post('/auth/verify-otp',data:{'phone':phone,'code':code},
      options:Options(headers:{'X-Kidareh-Client':'mobile'}));
    final data = r.data;
    final token = requireAccessToken(data);
    await _storage.write(token);
    return Map<String,dynamic>.from(data);
  }

  Future<Map<String,dynamic>> me() async {
    final data = (await _dio.get('/auth/me')).data;
    if (data is! Map) throw const FormatException('پاسخ حساب کاربری نامعتبر است');
    return Map<String,dynamic>.from(data);
  }

  Future<void> logout() async { try{await _dio.post('/auth/logout');}finally{await _storage.clear();} }
}
