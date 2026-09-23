import 'package:flutter/material.dart';
import 'buyer_repository.dart';

class BuyerPage extends StatefulWidget{const BuyerPage({super.key});@override State<BuyerPage> createState()=>_BuyerPageState();}
class _BuyerPageState extends State<BuyerPage>{
 final q=TextEditingController();final repo=BuyerRepository();List<Map<String,dynamic>> items=[];bool loading=false;String? error;
 Future<void> search()async{if(q.text.trim().isEmpty)return;setState(()=>{loading=true,error=null});try{items=await repo.search(q.text.trim());}catch(_){error='دریافت کالاها انجام نشد';}finally{if(mounted)setState(()=>loading=false);}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('پیدا کردن کالا')),body:ListView(padding:const EdgeInsets.all(20),children:[
 TextField(controller:q,textInputAction:TextInputAction.search,onSubmitted:(_)=>search(),decoration:InputDecoration(hintText:'چه چیزی می‌خواهید؟',prefixIcon:const Icon(Icons.search),suffixIcon:IconButton(onPressed:search,icon:const Icon(Icons.arrow_forward)))),
 const SizedBox(height:16),if(loading)const Center(child:CircularProgressIndicator()),if(error!=null)Text(error!,style:const TextStyle(color:Colors.red)),
 ...items.map((p)=>Card(child:ListTile(leading:const Icon(Icons.inventory_2_outlined),title:Text((p['name']??p['title']??'کالا').toString()),subtitle:Text((p['price']??'قیمت نامشخص').toString())))),
 if(!loading&&items.isEmpty&&error==null)const Card(child:ListTile(title:Text('جستجو کنید'),subtitle:Text('کالا را جستجو کنید تا نتایج نمایش داده شود.'))),
 ]));
}
