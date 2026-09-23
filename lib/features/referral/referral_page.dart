import 'package:flutter/material.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معرف و کیف پول')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(child: ListTile(title: Text('موجودی قابل برداشت'), subtitle: Text('از API دریافت می‌شود'))),
          SizedBox(height: 12),
          Card(child: ListTile(title: Text('کد معرفی'), subtitle: Text('از API دریافت می‌شود'))),
          SizedBox(height: 12),
          Card(child: ListTile(title: Text('تعداد معرفی‌ها'), subtitle: Text('از API دریافت می‌شود'))),
        ],
      ),
    );
  }
}
