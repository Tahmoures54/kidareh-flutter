import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/app_shell.dart';
import '../../features/auth/login_page.dart';
import '../../features/buyer/buyer_page.dart';
import '../../features/buyer/product_detail_page.dart';
import '../../features/buyer/store_detail_page.dart';
import '../../features/seller/seller_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/auth/auth_controller.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      if (authState.isLoading || authState.hasError) return null;

      final loggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      final isAuth = location == '/login';
      final protected = location == '/profile' || location == '/seller';
      if (protected && !loggedIn) {
        return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (isAuth && loggedIn) return '/';
      if (location == '/buyer') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/stores/:id', builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(body: Center(child: Text('فروشگاه نامعتبر')));
        }
        return StoreDetailPage(storeId: id);
      }),
      GoRoute(path: '/products/:id', builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const Scaffold(body: Center(child: Text('کالای نامعتبر')));
        }
        return ProductDetailPage(productId: id);
      }),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, __) => const BuyerPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/seller', builder: (_, __) => const SellerPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfilePage())],
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('صفحه یافت نشد: ${state.uri}')),
    ),
  );
  ref.listen(authControllerProvider, (_, __) => router.refresh());
  return router;
});
