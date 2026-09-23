import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود به کی‌داره')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'شماره موبایل'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () {}, child: const Text('دریافت کد تأیید')),
          ],
        ),
      ),
    );
  }
}
