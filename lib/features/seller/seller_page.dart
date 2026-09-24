import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';

class SellerPage extends ConsumerWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final role = user?['role']?.toString();
    final isSeller = role == 'seller' || role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('فروشگاه من')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(user?['name']?.toString() ?? 'فروشگاه من'),
              subtitle: Text(isSeller
                  ? 'مدیریت ویترین و کالاها'
                  : 'حساب شما هنوز فروشنده نیست'),
            ),
          ),
          const SizedBox(height: 16),
          if (!isSeller)
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_business_outlined),
                title: const Text('ثبت فروشگاه'),
                subtitle: const Text('برای شروع فروش، فروشگاه خود را ثبت کنید.'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ثبت فروشگاه از نسخه وب انجام می‌شود.')),
                ),
              ),
            )
          else ...[
            _Metric(title: 'کالاهای ثبت‌شده'),
            const SizedBox(height: 12),
            _Metric(title: 'موجودی‌های فعال'),
            const SizedBox(height: 12),
            _Metric(title: 'درخواست‌های مشتریان'),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
            label: const Text('بازگشت به خانه'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(title: Text(title), trailing: const Text('—')),
  );
}
