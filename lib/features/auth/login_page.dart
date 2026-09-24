import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override ConsumerState<LoginPage> createState()=>_LoginPageState();
}
class _LoginPageState extends ConsumerState<LoginPage>{
  final phone=TextEditingController(),code=TextEditingController();
  bool sent=false,busy=false; String? error;
  @override void dispose(){phone.dispose();code.dispose();super.dispose();}
  Future<void> submit() async {
    setState(() { busy=true; error=null; });
    try{
      final repo=ref.read(authRepositoryProvider);
      if(!sent){await repo.sendOtp(phone.text.trim());if(!mounted)return;setState(()=>sent=true);}
      else{
        final r=await repo.verifyOtp(phone.text.trim(),code.text.trim());
        await ref.read(authControllerProvider.notifier).setUser(Map<String,dynamic>.from(r['user'] as Map));
        if(mounted)Navigator.pop(context);
      }
    }catch(e){
      final m=e is DioException && e.response?.data is Map ? (e.response!.data['error']??'خطا').toString() : 'ارتباط با سرور برقرار نشد';
      if(mounted)setState(()=>error=m);
    }finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('ورود به کی‌داره')),
    body:ListView(padding:const EdgeInsets.all(20),children:[
      const Text('با شماره موبایل وارد شوید',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      const SizedBox(height:20),
      TextField(controller:phone,enabled:!sent,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'شماره موبایل',hintText:'09123456789')),
      if(sent) TextField(controller:code,keyboardType:TextInputType.number,maxLength:5,decoration:const InputDecoration(labelText:'کد تأیید')),
      if(error!=null) Padding(padding:const EdgeInsets.only(top:8),child:Text(error!,style:const TextStyle(color:Colors.red))),
      const SizedBox(height:16),
      FilledButton(onPressed:busy?null:submit,child:Text(busy?'در حال ارسال...':sent?'ورود':'دریافت کد تأیید')),
    ]),
  );
}
