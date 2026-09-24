import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class ReferralRepository {
  ReferralRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;

  Future<Map<String, dynamic>> stats() async {
    final data = (await _dio.get('/referral/stats')).data;
    if (data is! Map) {
      throw const FormatException('پاسخ کیف پول نامعتبر است');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<List<Map<String, dynamic>>> transactions() async {
    final data = (await _dio.get('/referral/transactions')).data;
    final raw = data is Map ? data['transactions'] : data;
    if (raw is! List) {
      throw const FormatException('فهرست تراکنش‌ها نامعتبر است');
    }
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}
