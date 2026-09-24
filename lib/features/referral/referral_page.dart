import 'package:flutter/material.dart';
import '../../core/config/web_config.dart';
import '../../core/network/api_client.dart';
import 'referral_repository.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});
  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final repo = ReferralRepository();
  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> tx = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) setState(() => loading = true);
    try {
      final s = await repo.stats();
      final t = await repo.transactions();
      final rawStats = s['stats'] ?? s;
      if (rawStats is! Map) {
        throw const FormatException('اطلاعات کیف پول نامعتبر است');
      }
      if (!mounted) return;
      setState(() {
        stats = Map<String, dynamic>.from(rawStats);
        tx = t;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = networkErrorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String money(Object? value) {
    final parsed = num.tryParse(value?.toString() ?? '') ?? 0;
    return '${parsed.toStringAsFixed(0)} تومان';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('معرف و کیف پول')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                if (stats != null) ...[
                  Card(
                    child: ListTile(
                      title: const Text('موجودی'),
                      subtitle: Text(
                        money(stats!['balance']),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('کد معرفی'),
                      subtitle: Text((stats!['referralCode'] ?? '—').toString()),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('تعداد معرفی‌ها'),
                      subtitle: Text((stats!['referredUsers'] ?? 0).toString()),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => WebConfig.open('/referral'),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('برداشت و جزئیات کامل در سایت'),
                ),
                const SizedBox(height: 16),
                const Text('تراکنش‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...tx.map(
                  (x) => ListTile(
                    title: Text((x['title'] ?? x['type']).toString()),
                    trailing: Text(money(x['amount'])),
                  ),
                ),
              ],
            ),
          ),
  );
}
