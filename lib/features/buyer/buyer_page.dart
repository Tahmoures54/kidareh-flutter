import 'package:flutter/material.dart';

class BuyerPage extends StatelessWidget {
  const BuyerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پیدا کردن کالا')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          TextField(
            decoration: InputDecoration(
              hintText: 'چه چیزی می‌خواهید؟',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text('موقعیت شما'),
              subtitle: Text('شهر یا موقعیت را برای نمایش فروشگاه‌های نزدیک انتخاب کنید.'),
            ),
          ),
        ],
      ),
    );
  }
}
