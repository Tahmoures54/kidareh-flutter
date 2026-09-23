import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب کاربری')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.person_outline), title: Text('پروفایل'))),
          Card(child: ListTile(leading: Icon(Icons.store_outlined), title: Text('نقش‌های کاربری'))),
          Card(child: ListTile(leading: Icon(Icons.notifications_none), title: Text('اعلان‌ها'))),
        ],
      ),
    );
  }
}
