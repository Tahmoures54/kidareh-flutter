import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository({Dio? dio}) : _dio=dio ?? dioProvider.dio;
  final Dio _dio;
  final TokenStorage _storage=const TokenStorage();

  Future<Map<String,dynamic>> sendOtp(String phone) async =>
    Map<String,dynamic>.from((await _dio.post('/auth/send-otp',data:{'phone':phone})).data);

  Future<Map<String,dynamic>> verifyOtp(String phone,String code) async {
    final r=await _dio.post('/auth/verify-otp',data:{'phone':phone,'code':code},
      options:Options(headers:{'X-Kidareh-Client':'mobile'}));
    final token=r.data['accessToken'] as String?;
    if(token!=null && token.isNotEmpty) await _storage.write(token);
    return Map<String,dynamic>.from(r.data);
  }

  Future<Map<String,dynamic>> me() async =>
    Map<String,dynamic>.from((await _dio.get('/auth/me')).data);

  Future<void> logout() async { try{await _dio.post('/auth/logout');}finally{await _storage.clear();} }
}
