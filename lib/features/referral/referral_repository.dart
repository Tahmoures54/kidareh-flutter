import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
class ReferralRepository{
 ReferralRepository({Dio? dio}):_dio=dio??dioProvider.dio;final Dio _dio;
 Future<Map<String,dynamic>> stats()async=>Map<String,dynamic>.from((await _dio.get('/referral/stats')).data);
 Future<List<Map<String,dynamic>>> transactions()async{final d=(await _dio.get('/referral/transactions')).data;return List<Map<String,dynamic>>.from((d['transactions'] as List).map((e)=>Map<String,dynamic>.from(e)));}
}
