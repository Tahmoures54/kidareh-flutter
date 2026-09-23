import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final user=ref.watch(authControllerProvider).valueOrNull;
    return Scaffold(appBar:AppBar(title:const Text('حساب کاربری')),body:ListView(padding:const EdgeInsets.all(20),children:[
      Card(child:ListTile(leading:const Icon(Icons.person_outline),title:Text(user?['name']?.toString()??'مهمان'),subtitle:Text(user?['phone']?.toString()??'برای ورود، وارد شوید'))),
      if(user!=null)...[
        Card(child:ListTile(title:const Text('نقش کاربری'),subtitle:Text(user['role']?.toString()??'buyer'))),
        Card(child:ListTile(title:const Text('شهر'),subtitle:Text(user['city']?.toString()??'ثبت نشده'))),
        const SizedBox(height:8),
        FilledButton.tonal(onPressed:()=>ref.read(authControllerProvider.notifier).logout(),child:const Text('خروج از حساب')),
      ],
    ]));
  }
}
