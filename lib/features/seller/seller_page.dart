import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../../core/network/api_client.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) => SellerRepository());
final sellerStoreRepositoryProvider = Provider<SellerStoreRepository>((ref) => SellerStoreRepository());
final sellerStatsRepositoryProvider = Provider<SellerStatsRepository>((ref) => SellerStatsRepository());
final sellerFollowersRepositoryProvider = Provider<SellerFollowersRepository>((ref) => SellerFollowersRepository());

class SellerRepository {
  SellerRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final data = (await _dio.get('/products/seller')).data;
    final raw = data is List ? data : data is Map ? data['products'] : null;
    if (raw is! List) throw const FormatException('فهرست کالاهای فروشنده نامعتبر است');
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  Future<void> deleteProduct(int id) => _dio.delete('/products/$id').then((_) {});
  Future<Map<String, dynamic>> updateProduct(int id, {required String name, required num price, required String status, String? description}) async {
    final data = (await _dio.put('/products/$id', data: {'name': name.trim(), 'price': price, 'status': status.trim(), if (description != null) 'description': description.trim()})).data;
    if (data is! Map) throw const FormatException('پاسخ بروزرسانی کالا نامعتبر است');
    return Map<String, dynamic>.from(data);
  }
  Future<Map<String, dynamic>> createProduct({required String name, required num price, required String status, String? description}) async {
    final data = (await _dio.post('/products', data: {'name': name.trim(), 'price': price, 'status': status.trim(), if (description?.trim().isNotEmpty == true) 'description': description!.trim()})).data;
    if (data is! Map) throw const FormatException('پاسخ ثبت کالا نامعتبر است');
    return Map<String, dynamic>.from(data);
  }
}

class SellerStoreRepository {
  SellerStoreRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;
  Future<Map<String, dynamic>> fetchMyStore() async {
    final data = (await _dio.get('/stores/my/store')).data;
    if (data is! Map) throw const FormatException('اطلاعات فروشگاه نامعتبر است');
    return Map<String, dynamic>.from(data);
  }
  Future<Map<String, dynamic>> updateMyStore({required String name, required String address, required String phone, String? description, String? category, String? city, String? province}) async {
    final data = (await _dio.put('/stores/my/store', data: {'name': name.trim(), 'address': address.trim(), 'phone': phone.trim(), if (description != null) 'description': description.trim(), if (category != null) 'category': category.trim(), if (city != null) 'city': city.trim(), if (province != null) 'province': province.trim()})).data;
    if (data is! Map) throw const FormatException('پاسخ بروزرسانی فروشگاه نامعتبر است');
    return Map<String, dynamic>.from(data);
  }
}

class SellerStatsRepository {
  SellerStatsRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;
  Future<Map<String, dynamic>> fetchMyStats() async {
    final data = (await _dio.get('/stores/my/stats')).data;
    if (data is! Map) throw const FormatException('آمار فروشگاه نامعتبر است');
    return Map<String, dynamic>.from(data);
  }
}

class SellerFollowersRepository {
  SellerFollowersRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;
  Future<List<Map<String, dynamic>>> fetchMyFollowers() async {
    final data = (await _dio.get('/stores/my/followers')).data;
    final raw = data is List ? data : data is Map ? data['followers'] : null;
    if (raw is! List) throw const FormatException('فهرست دنبال‌کنندگان نامعتبر است');
    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
}

class SellerPage extends ConsumerStatefulWidget {
  const SellerPage({super.key});
  @override ConsumerState<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends ConsumerState<SellerPage> {
  bool loading = true, statsLoading = false;
  String? error;
  List<Map<String, dynamic>> products = [];
  Map<String, dynamic>? stats;

  @override void initState() { super.initState(); _load(); _loadStats(); }

  Future<void> _load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final role = ref.read(authControllerProvider).valueOrNull?['role']?.toString();
      if (role != 'seller' && role != 'admin') { if (mounted) setState(() { products = []; loading = false; }); return; }
      final items = await ref.read(sellerRepositoryProvider).fetchProducts();
      if (mounted) setState(() { products = items; loading = false; });
    } catch (e) { if (mounted) setState(() { error = networkErrorMessage(e); loading = false; }); }
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => statsLoading = true);
    try { final value = await ref.read(sellerStatsRepositoryProvider).fetchMyStats(); if (mounted) setState(() => stats = value); }
    catch (_) { if (mounted) setState(() => stats = null); }
    finally { if (mounted) setState(() => statsLoading = false); }
  }

  Future<void> _showFollowers() async {
    try {
      final followers = await ref.read(sellerFollowersRepositoryProvider).fetchMyFollowers();
      if (!mounted) return;
      await showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: SizedBox(height: MediaQuery.of(context).size.height * .72, child: followers.isEmpty ? const Center(child: Text('هنوز کسی ویترین شما را دنبال نکرده است.')) : ListView.separated(padding: const EdgeInsets.all(20), itemCount: followers.length, separatorBuilder: (_, __) => const Divider(), itemBuilder: (_, i) { final f = followers[i]; return ListTile(leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: Text(f['name']?.toString().trim().isNotEmpty == true ? f['name'].toString() : 'دنبال‌کننده'), subtitle: Text([if (f['phone']?.toString().trim().isNotEmpty == true) f['phone'].toString(), if (f['followed_at']?.toString().trim().isNotEmpty == true) 'دنبال‌کردن: ${f['followed_at']}'].join(' • '))); })));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e)))); }
  }

  Future<void> _editStore() async {
    try {
      final s = await ref.read(sellerStoreRepositoryProvider).fetchMyStore();
      if (!mounted) return;
      final name = TextEditingController(text: s['name']?.toString() ?? ''), address = TextEditingController(text: s['address']?.toString() ?? ''), phone = TextEditingController(text: s['phone']?.toString() ?? ''), city = TextEditingController(text: s['city']?.toString() ?? ''), province = TextEditingController(text: s['province']?.toString() ?? ''), category = TextEditingController(text: s['category']?.toString() ?? ''), description = TextEditingController(text: s['description']?.toString() ?? '');
      try {
        final ok = await showDialog<bool>(context: context, builder: (dc) => AlertDialog(title: const Text('ویرایش فروشگاه'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'نام فروشگاه')), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'تلفن فروشگاه')), TextField(controller: city, decoration: const InputDecoration(labelText: 'شهر')), TextField(controller: province, decoration: const InputDecoration(labelText: 'استان')), TextField(controller: address, maxLines: 2, decoration: const InputDecoration(labelText: 'آدرس')), TextField(controller: category, decoration: const InputDecoration(labelText: 'دسته‌بندی')), TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات'))])), actions: [TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('انصراف')), FilledButton(onPressed: () async { final n=name.text.trim(), a=address.text.trim(), p=phone.text.trim(); if(n.length<2||a.length<5||!RegExp(r'^09\d{9}$').hasMatch(p)){ScaffoldMessenger.of(dc).showSnackBar(const SnackBar(content: Text('نام، آدرس و شماره تلفن معتبر وارد کنید.')));return;} try { await ref.read(sellerStoreRepositoryProvider).updateMyStore(name:n,address:a,phone:p,city:city.text,province:province.text,category:category.text,description:description.text); if(dc.mounted) Navigator.pop(dc,true); } catch(e){if(dc.mounted) ScaffoldMessenger.of(dc).showSnackBar(SnackBar(content:Text(networkErrorMessage(e))));}}, child: const Text('ذخیره'))]));
        if (ok == true && mounted) { await _loadStats(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات فروشگاه بروزرسانی شد.'))); }
      } finally { name.dispose(); address.dispose(); phone.dispose(); city.dispose(); province.dispose(); category.dispose(); description.dispose(); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e)))); }
  }

  Future<void> _productDialog({Map<String,dynamic>? product}) async {
    final editing = product != null, name=TextEditingController(text: product?['name']?.toString()??''), price=TextEditingController(text: product?['price']?.toString()??''), description=TextEditingController(text: product?['description']?.toString()??'');
    var status=product?['status']?.toString()??'موجود';
    try {
      final ok=await showDialog<bool>(context:context,builder:(dc)=>StatefulBuilder(builder:(dc,set)=>AlertDialog(title:Text(editing?'ویرایش کالا':'ثبت کالا'),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:name,autofocus:true,decoration:const InputDecoration(labelText:'نام کالا')),TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'قیمت (تومان)')),DropdownButtonFormField<String>(value:status,items:const[DropdownMenuItem(value:'موجود',child:Text('موجود')),DropdownMenuItem(value:'فقط ۱ عدد',child:Text('فقط ۱ عدد')),DropdownMenuItem(value:'ناموجود',child:Text('ناموجود'))],onChanged:(v)=>set(()=>status=v??status)),TextField(controller:description,maxLines:3,decoration:const InputDecoration(labelText:'توضیحات (اختیاری)'))])),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:const Text('انصراف')),FilledButton(onPressed:()async{final n=name.text.trim(),raw=price.text.trim().replaceAll(',','');final p=num.tryParse(raw);if(n.isEmpty||p==null||p<0){ScaffoldMessenger.of(dc).showSnackBar(const SnackBar(content:Text('نام و قیمت معتبر وارد کنید.')));return;}try{final repo=ref.read(sellerRepositoryProvider);if(editing){await repo.updateProduct(int.parse(product['id'].toString()),name:n,price:p,status:status,description:description.text);}else{await repo.createProduct(name:n,price:p,status:status,description:description.text);}if(dc.mounted)Navigator.pop(dc,true);}catch(e){if(dc.mounted)ScaffoldMessenger.of(dc).showSnackBar(SnackBar(content:Text(networkErrorMessage(e))));}},child:Text(editing?'ذخیره':'ثبت کالا'))]));
      if(ok==true&&mounted){await _load();await _loadStats();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(editing?'کالا بروزرسانی شد.':'کالا ثبت شد.')));}
    } finally {name.dispose();price.dispose();description.dispose();}
  }

  Future<void> _deleteProduct(Map<String,dynamic> product) async {
    final id=int.tryParse(product['id']?.toString()??'');if(id==null)return;final ok=await showDialog<bool>(context:context,builder:(dc)=>AlertDialog(title:const Text('حذف کالا'),content:Text('«${product['name']??'این کالا'}» حذف شود؟ این عملیات قابل برگشت نیست.'),actions:[TextButton(onPressed:()=>Navigator.pop(dc,false),child:const Text('انصراف')),FilledButton.tonal(onPressed:()=>Navigator.pop(dc,true),child:const Text('حذف'))]));if(ok!=true)return;try{await ref.read(sellerRepositoryProvider).deleteProduct(id);if(!mounted)return;await _load();await _loadStats();ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('کالا حذف شد.')));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(networkErrorMessage(e))));}
  }

  @override Widget build(BuildContext context){final user=ref.watch(authControllerProvider).valueOrNull;final role=user?['role']?.toString();final seller=role=='seller'||role=='admin';return Scaffold(appBar:AppBar(title:const Text('فروشگاه من'),actions:[IconButton(onPressed:_showFollowers,tooltip:'دنبال‌کنندگان',icon:const Icon(Icons.people_outline)),IconButton(onPressed:_editStore,tooltip:'ویرایش فروشگاه',icon:const Icon(Icons.store_outlined)),IconButton(onPressed:loading?null:(){_load();_loadStats();},tooltip:'بازخوانی',icon:const Icon(Icons.refresh))]),body:RefreshIndicator(onRefresh:()async{await _load();await _loadStats();},child:ListView(physics:const AlwaysScrollableScrollPhysics(),padding:const EdgeInsets.all(20),children:[Card(child:ListTile(leading:const Icon(Icons.storefront_outlined),title:Text('فروشگاه من'),subtitle:Text(seller?'مدیریت ویترین و کالاها':'حساب شما هنوز فروشنده نیست'))),if(seller&&stats!=null)...[const SizedBox(height:8),Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[_stat('کالا',stats!['product_count']),_stat('بازدید',stats!['total_views']),_stat('دنبال‌کننده',stats!['follower_count'])]),const SizedBox(height:16)],if(!seller)const Card(child:ListTile(leading:Icon(Icons.add_business_outlined),title:Text('ثبت فروشگاه'),subtitle:Text('برای شروع فروش، فروشگاه خود را ثبت کنید.')))else if(loading)const Center(child:Padding(padding:EdgeInsets.all(32),child:CircularProgressIndicator()))else if(error!=null)Card(child:ListTile(title:const Text('دریافت کالاها ناموفق بود'),subtitle:Text('خطا: $error'),trailing:IconButton(onPressed:_load,icon:const Icon(Icons.refresh))))else if(products.isEmpty)...[const Card(child:ListTile(leading:Icon(Icons.inventory_2_outlined),title:Text('هنوز کالایی ثبت نکرده‌اید'),subtitle:Text('اولین کالا را ثبت کنید تا در کی‌داره دیده شود.'))),FilledButton.icon(onPressed:()=>_productDialog(),icon:const Icon(Icons.add),label:const Text('ثبت اولین کالا'))]else...[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('کالاهای من (${products.length})',style:Theme.of(context).textTheme.titleMedium),FilledButton.icon(onPressed:()=>_productDialog(),icon:const Icon(Icons.add),label:const Text('افزودن کالا'))]),const SizedBox(height:8),...products.map((p)=>Card(child:ListTile(title:Text(p['name']?.toString()??'کالای بدون نام'),subtitle:Text('${p['price']??'قیمت توافقی'} تومان • ${p['status']??'نامشخص'}'),trailing:PopupMenuButton<String>(onSelected:(a){if(a=='edit')_productDialog(product:p);else _deleteProduct(p);},itemBuilder:(_)=>const[PopupMenuItem(value:'edit',child:Text('ویرایش')),PopupMenuItem(value:'delete',child:Text('حذف'))]))))]])));}

  Widget _stat(String label,Object? value)=>Column(children:[Text(value?.toString()??'۰',style:Theme.of(context).textTheme.titleMedium),Text(label,style:Theme.of(context).textTheme.bodySmall)]);
}