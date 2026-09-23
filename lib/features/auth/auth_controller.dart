import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';

final authRepositoryProvider=Provider<AuthRepository>((_)=>AuthRepository());
final authControllerProvider=AsyncNotifierProvider<AuthController,Map<String,dynamic>?>(AuthController.new);

class AuthController extends AsyncNotifier<Map<String,dynamic>?> {
  late final AuthRepository repo;
  @override Future<Map<String,dynamic>?> build() async {
    repo=ref.read(authRepositoryProvider);
    try{return Map<String,dynamic>.from((await repo.me())['user'] as Map);}catch(_){return null;}
  }
  Future<void> setUser(Map<String,dynamic> user) async {state=AsyncData(user);}
  Future<void> logout() async {await repo.logout();state=const AsyncData(null);}
}
