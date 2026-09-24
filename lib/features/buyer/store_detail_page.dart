import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'buyer_repository.dart';
import '../../core/network/api_client.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({super.key, required this.storeId});
  final int storeId;
  @override State<StoreDetailPage> createState() => _StoreDetailPageState();
}
class _StoreDetailPageState extends State<StoreDetailPage> {
  final repo = BuyerRepository();
  Map<String, dynamic>? store; bool loading = true; String? error;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try { final data = await repo.getStore(widget.storeId); if (!mounted) return; setState(() { store=data; loading=false; }); }
    catch (e) { if (mounted) setState(() { loading=false; error=networkErrorMessage(e); }); }
  }
  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان باز کردن این مورد وجود ندارد')));
    }
  }
  @override Widget build(BuildContext context) {
    final data=store;
    return Scaffold(appBar: AppBar(title: const Text('فروشگاه')), body: loading ? const Center(child:CircularProgressIndicator()) : error != null ? Center(child:FilledButton(onPressed:_load,child:Text(error!))) : data==null ? const Center(child:Text('فروشگاه پیدا نشد')) : _content(context,data));
  }
  Widget _content(BuildContext context, Map<String,dynamic> data) {
    final name=(data['name']??'فروشگاه').toString();
    final city=(data['city']??'').toString(); final province=(data['province']??'').toString();
    final address=(data['address']??'').toString(); final phone=(data['phone']??'').toString().trim();
    final description=(data['description']??'').toString().trim();
    final imageUrl=(data['image']??data['image_url']??'').toString().trim();
    final lat=double.tryParse(data['latitude']?.toString()??data['lat']?.toString()??'');
    final lng=double.tryParse(data['longitude']?.toString()??data['lng']?.toString()??'');
    final products=data['products'] is List ? (data['products'] as List).whereType<Map>().toList() : <Map>[];
    return ListView(padding:const EdgeInsets.fromLTRB(16,16,16,32),children:[
      if (imageUrl.isNotEmpty) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 2.2,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.storefront_outlined)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Text(name,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w800)),
      if(city.isNotEmpty||province.isNotEmpty) Padding(padding:const EdgeInsets.only(top:6),child:Text([city,province].where((e)=>e.isNotEmpty).join('، '))),
      if(description.isNotEmpty) Padding(padding:const EdgeInsets.only(top:16),child:Text(description)),
      if(address.isNotEmpty) Card(child:ListTile(leading:const Icon(Icons.location_on_outlined),title:const Text('آدرس'),subtitle:Text(address),trailing:IconButton(tooltip:'مسیریابی',onPressed:()=>_open(lat!=null&&lng!=null?Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'):Uri.parse('https://www.google.com/maps/search/?api=1&query='+Uri.encodeComponent(address))),icon:const Icon(Icons.directions_outlined)))),
      if(phone.isNotEmpty) FilledButton.icon(onPressed:()=>_open(Uri(scheme:'tel',path:phone)),icon:const Icon(Icons.phone_outlined),label:const Text('تماس با فروشگاه')),
      if(products.isNotEmpty) ...[const SizedBox(height:24),Text('کالاهای فروشگاه',style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),const SizedBox(height:8),...products.map((p){ final id=int.tryParse(p['id']?.toString()??''); final price=p['price']; final priceText=buyerPriceLabel(price); return Card(child:ListTile(onTap:id==null?null:()=>context.push('/products/$id'),title:Text((p['name']??'کالا').toString(),maxLines:2,overflow:TextOverflow.ellipsis),subtitle:Text('$priceText • ${(p['status']??'ناموجود').toString()}'),trailing:id!=null?const Icon(Icons.chevron_left):null)); })],
    ]);
  }
}