import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/web_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کی‌داره؟')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('همراه موبایل کی‌داره', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('جستجو، تماس با فروشگاه و مدیریت کالا اینجاست. نقشه، چت، پرداخت و معرفی روی سایت کامل می‌ماند.'),
          const SizedBox(height: 24),
          _Action(title: 'جستجوی کالا', icon: Icons.search, onTap: () => context.go('/buyer')),
          _Action(title: 'پنل فروشنده', icon: Icons.storefront_outlined, onTap: () => context.go('/seller')),
          _Action(title: 'حساب کاربری', icon: Icons.person_outline, onTap: () => context.go('/profile')),
          _Action(
            title: 'باز کردن سایت کامل',
            icon: Icons.open_in_new,
            onTap: () => WebConfig.open('/'),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_left),
      onTap: onTap,
    ),
  );
}
