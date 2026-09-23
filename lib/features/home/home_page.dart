import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کی‌داره؟')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('ببین کی داره، حضوری بگیر', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('کالا را پیدا کن، فروشگاه نزدیک را ببین و قبل از رفتن از موجودی مطمئن شو.'),
          const SizedBox(height: 24),
          _Action(title: 'جستجوی کالا', icon: Icons.search, onTap: () => context.go('/buyer')),
          _Action(title: 'پنل فروشنده', icon: Icons.storefront_outlined, onTap: () => context.go('/seller')),
          _Action(title: 'معرفی و کیف پول', icon: Icons.account_balance_wallet_outlined, onTap: () => context.go('/referral')),
          _Action(title: 'حساب کاربری', icon: Icons.person_outline, onTap: () => context.go('/profile')),
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
