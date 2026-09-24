import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import '../../core/storage/token_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());
final authControllerProvider =
    AsyncNotifierProvider<AuthController, Map<String, dynamic>?>(AuthController.new);

class AuthController extends AsyncNotifier<Map<String, dynamic>?> {
  late final AuthRepository repo;

  @override
  Future<Map<String, dynamic>?> build() async {
    repo = ref.read(authRepositoryProvider);
    final storage = const TokenStorage();
    final token = await storage.read();
    if (token == null || token.isEmpty) return null;

    try {
      final data = await repo.me();
      final rawUser = data['user'];
      if (rawUser is! Map) {
        await storage.clear();
        return null;
      }
      return Map<String, dynamic>.from(rawUser);
    } on DioException catch (error) {
      // Only an explicit authentication failure invalidates the saved session.
      // Transient network/server failures must not log the user out.
      if (error.response?.statusCode == 401) {
        await storage.clear();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    state = AsyncData(user);
  }

  Future<void> logout() async {
    try {
      await repo.logout();
    } finally {
      state = const AsyncData(null);
    }
  }
}