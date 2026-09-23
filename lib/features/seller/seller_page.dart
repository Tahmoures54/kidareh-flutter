import 'package:flutter/material.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فروشگاه من')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Metric(title: 'کالاهای ثبت‌شده'),
          SizedBox(height: 12),
          _Metric(title: 'موجودی‌های فعال'),
          SizedBox(height: 12),
          _Metric(title: 'درخواست‌های مشتریان'),
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
