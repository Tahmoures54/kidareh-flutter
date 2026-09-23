import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class BuyerRepository {
  BuyerRepository({Dio? dio}):_dio=dio??dioProvider.dio;
  final Dio _dio;
  Future<List<Map<String,dynamic>>> search(String query) async {
    final data=(await _dio.get('/products',queryParameters:{'q':query})).data;
    final list=data is Map ? (data['products']??data['items']??[]) : data;
    return List<Map<String,dynamic>>.from((list as List).map((e)=>Map<String,dynamic>.from(e)));
  }
}
