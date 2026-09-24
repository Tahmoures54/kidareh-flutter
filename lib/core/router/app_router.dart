import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/buyer/buyer_page.dart';
import '../../features/buyer/product_detail_page.dart';
import '../../features/buyer/store_detail_page.dart';
import '../../features/seller/seller_page.dart';
import '../../features/referral/referral_page.dart';
import '../../features/profile/profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/buyer', builder: (_, __) => const BuyerPage()),
      GoRoute(path: '/stores/:id', builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const Scaffold(body: Center(child: Text('فروشگاه نامعتبر')));
        return StoreDetailPage(storeId: id);
      }),
      GoRoute(path: '/products/:id', builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const Scaffold(body: Center(child: Text('کالای نامعتبر')));
        return ProductDetailPage(productId: id);
      }),
      GoRoute(path: '/seller', builder: (_, __) => const SellerPage()),
      GoRoute(path: '/referral', builder: (_, __) => const ReferralPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('صفحه یافت نشد: ${state.uri}')),
    ),
  );
});
