import 'package:dio/dio.dart';\nimport 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../auth/auth_controller.dart';\nimport '../../core/network/api_client.dart';\n\nfinal sellerRepositoryProvider = Provider<SellerRepository>((ref) => SellerRepository());
final sellerStoreRepositoryProvider = Provider<SellerStoreRepository>((ref) => SellerStoreRepository());\n\nclass SellerRepository {\n  SellerRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;\n  final Dio _dio;\n\n  Future<List<Map<String, dynamic>>> fetchProducts() async {\n    final response = await _dio.get('/products/seller');\n    final data = response.data;\n    final raw = data is List ? data : data is Map ? data['products'] : null;\n    if (raw is! List) throw const FormatException('فهرست کالاهای فروشنده نامعتبر است');\n    return raw.whereType<Map>().map(Map<String, dynamic>.from).toList();\n  }\n\n  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
  }

  Future<Map<String, dynamic>> updateProduct(int id, {required String name, required num price, required String status, String? description}) async {
    final response = await _dio.put('/products/$id', data: {
      'name': name.trim(), 'price': price, 'status': status.trim(),
      if (description != null) 'description': description.trim(),
    });
    final data = response.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('پاسخ بروزرسانی کالا نامعتبر است');
  }

  Future<Map<String, dynamic>> createProduct({required String name, required num price, required String status, String? description}) async {\n    final response = await _dio.post('/products', data: {\n      'name': name.trim(), 'price': price, 'status': status.trim(),\n      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),\n    });\n    final data = response.data;\n    if (data is Map) return Map<String, dynamic>.from(data);\n    throw const FormatException('پاسخ ثبت کالا نامعتبر است');\n  }\n}\n\n
class SellerStoreRepository {
  SellerStoreRepository({Dio? dio}) : _dio = dio ?? dioProvider.dio;
  final Dio _dio;

  Future<Map<String, dynamic>> fetchMyStore() async {
    final response = await _dio.get('/stores/my/store');
    final data = response.data;
    if (data is! Map) throw const FormatException('اطلاعات فروشگاه نامعتبر است');
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> updateMyStore({
    required String name,
    required String address,
    required String phone,
    String? description,
    String? category,
    String? city,
    String? province,
    double? lat,
    double? lng,
    String? openingHours,
  }) async {
    final response = await _dio.put('/stores/my/store', data: {
      'name': name.trim(),
      'address': address.trim(),
      'phone': phone.trim(),
      if (description != null) 'description': description.trim(),
      if (category != null) 'category': category.trim(),
      if (city != null) 'city': city.trim(),
      if (province != null) 'province': province.trim(),
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (openingHours != null) 'opening_hours': openingHours.trim(),
    });
    final data = response.data;
    if (data is! Map) throw const FormatException('پاسخ بروزرسانی فروشگاه نامعتبر است');
    return Map<String, dynamic>.from(data);
  }
}

class SellerPage extends ConsumerStatefulWidget {\n  const SellerPage({super.key});\n  @override\n  ConsumerState<SellerPage> createState() => _SellerPageState();\n}\n\nclass _SellerPageState extends ConsumerState<SellerPage> {\n  bool loading = true;\n  String? error;\n  List<Map<String, dynamic>> products = [];\n\n  @override\n  void initState() { super.initState(); _load(); }\n\n  Future<void> _editStore() async {
    Map<String, dynamic> store;
    try {
      store = await ref.read(sellerStoreRepositoryProvider).fetchMyStore();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
      return;
    }
    final name = TextEditingController(text: store['name']?.toString() ?? '');
    final address = TextEditingController(text: store['address']?.toString() ?? '');
    final phone = TextEditingController(text: store['phone']?.toString() ?? '');
    final city = TextEditingController(text: store['city']?.toString() ?? '');
    final province = TextEditingController(text: store['province']?.toString() ?? '');
    final description = TextEditingController(text: store['description']?.toString() ?? '');
    final category = TextEditingController(text: store['category']?.toString() ?? '');
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('ویرایش فروشگاه'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'نام فروشگاه')),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'تلفن فروشگاه')),
            TextField(controller: city, decoration: const InputDecoration(labelText: 'شهر')),
            TextField(controller: province, decoration: const InputDecoration(labelText: 'استان')),
            TextField(controller: address, maxLines: 2, decoration: const InputDecoration(labelText: 'آدرس')),
            TextField(controller: category, decoration: const InputDecoration(labelText: 'دسته‌بندی')),
            TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
            FilledButton(onPressed: () async {
              final n = name.text.trim(), a = address.text.trim(), p = phone.text.trim();
              if (n.length < 2 || a.length < 5 || !RegExp(r'^09\d{9}(Map<String, dynamic> product) async {
    final id = int.tryParse(product['id']?.toString() ?? '');
    if (id == null) return;
    final name = product['name']?.toString() ?? 'این کالا';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف کالا'),
        content: Text('«$name» حذف شود؟ این عملیات قابل برگشت نیست.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(sellerRepositoryProvider).deleteProduct(id);
      if (!mounted) return;
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا حذف شد.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
    }
  }

  Future<void> _editProduct(Map<String, dynamic> product) async {
    final id = int.tryParse(product['id']?.toString() ?? '');
    if (id == null) return;
    final name = TextEditingController(text: product['name']?.toString() ?? '');
    final price = TextEditingController(text: product['price']?.toString() ?? '');
    final description = TextEditingController(text: product['description']?.toString() ?? '');
    var status = product['status']?.toString() ?? 'موجود';
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('ویرایش کالا'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'نام کالا')),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت (تومان)')),
            DropdownButtonFormField<String>(value: status, items: const [
              DropdownMenuItem(value: 'موجود', child: Text('موجود')),
              DropdownMenuItem(value: 'فقط ۱ عدد', child: Text('فقط ۱ عدد')),
              DropdownMenuItem(value: 'ناموجود', child: Text('ناموجود')),
            ], onChanged: (v) => setDialogState(() => status = v ?? status)),
            TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
            FilledButton(onPressed: () async {
              final n = name.text.trim();
              final p = num.tryParse(price.text.trim().replaceAll(',', ''));
              if (n.isEmpty || p == null || p < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('نام و قیمت معتبر وارد کنید.')));
                return;
              }
              try {
                await ref.read(sellerRepositoryProvider).updateProduct(id, name: n, price: p, status: status, description: description.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (e) {
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
              }
            }, child: const Text('ذخیره')),
          ],
        )),
      );
      if (result == true && mounted) {
        await _load();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا بروزرسانی شد.')));
      }
    } finally {
      name.dispose(); price.dispose(); description.dispose();
    }
  }

  Future<void> _createProduct() async {\n    final name = TextEditingController();\n    final price = TextEditingController();\n    final description = TextEditingController();\n    var status = 'موجود';\n    try {\n      final result = await showDialog<bool>(\n        context: context,\n        builder: (dialogContext) => StatefulBuilder(\n          builder: (dialogContext, setDialogState) => AlertDialog(\n            title: const Text('ثبت کالا'),\n            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [\n              TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'نام کالا')),\n              TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت (تومان)')),\n              DropdownButtonFormField<String>(value: status, items: const [\n                DropdownMenuItem(value: 'موجود', child: Text('موجود')),\n                DropdownMenuItem(value: 'فقط ۱ عدد', child: Text('فقط ۱ عدد')),\n                DropdownMenuItem(value: 'ناموجود', child: Text('ناموجود')),\n              ], onChanged: (v) => setDialogState(() => status = v ?? status)),\n              TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)')),\n            ])),\n            actions: [\n              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),\n              FilledButton(onPressed: () async {\n                final n = name.text.trim();\n                final p = num.tryParse(price.text.trim().replaceAll(',', ''));\n                if (n.isEmpty || p == null || p < 0) {\n                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('نام و قیمت معتبر وارد کنید.')));\n                  return;\n                }\n                try {\n                  await ref.read(sellerRepositoryProvider).createProduct(name: n, price: p, status: status, description: description.text);\n                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);\n                } catch (e) {\n                  if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));\n                }\n              }, child: const Text('ثبت کالا')),\n            ],\n          ),\n        ),\n      );\n      if (result == true && mounted) {\n        await _load();\n        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا ثبت شد.')));\n      }\n    } finally {\n      name.dispose(); price.dispose(); description.dispose();\n    }\n  }\n  Future<void> _load() async {\n    setState(() { loading = true; error = null; });\n    try {\n      final user = ref.read(authControllerProvider).valueOrNull;\n      final role = user?['role']?.toString();\n      if (role != 'seller' && role != 'admin') {\n        if (mounted) setState(() { products = []; loading = false; });\n        return;\n      }\n      final items = await ref.read(sellerRepositoryProvider).fetchProducts();\n      if (!mounted) return;\n      setState(() { products = items; loading = false; });\n    } catch (e) {\n      if (!mounted) return;\n      setState(() { error = networkErrorMessage(e); loading = false; });\n    }\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    final user = ref.watch(authControllerProvider).valueOrNull;\n    final role = user?['role']?.toString();\n    final isSeller = role == 'seller' || role == 'admin';\n    return Scaffold(\n      appBar: AppBar(title: const Text('فروشگاه من'), actions: [IconButton(onPressed: _editStore, icon: const Icon(Icons.store_outlined)), IconButton(onPressed: loading ? null : _load, icon: const Icon(Icons.refresh))]),\n      body: RefreshIndicator(\n        onRefresh: _load,\n        child: ListView(\n          physics: const AlwaysScrollableScrollPhysics(),\n          padding: const EdgeInsets.all(20),\n          children: [\n            Card(child: ListTile(leading: const Icon(Icons.storefront_outlined), title: Text(user?['name']?.toString() ?? 'فروشگاه من'), subtitle: Text(isSeller ? 'مدیریت ویترین و کالاها' : 'حساب شما هنوز فروشنده نیست'))),\n            const SizedBox(height: 16),\n            if (!isSeller) const Card(child: ListTile(leading: Icon(Icons.add_business_outlined), title: Text('ثبت فروشگاه'), subtitle: Text('برای شروع فروش، فروشگاه خود را ثبت کنید.')))\n            else if (loading) const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))\n            else if (error != null) Card(child: ListTile(leading: const Icon(Icons.error_outline), title: const Text('دریافت کالاها ناموفق بود'), subtitle: Text(error!), trailing: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))))\n            else if (products.isEmpty) ...[const Card(child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('هنوز کالایی ثبت نکرده‌اید'), subtitle: Text('اولین کالا را ثبت کنید تا در کی‌داره دیده شود.'))), const SizedBox(height: 8), FilledButton.icon(onPressed: _createProduct, icon: const Icon(Icons.add), label: const Text('ثبت اولین کالا'))]\n            else ...[\n              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('کالاهای من (' + products.length.toString() + ')', style: Theme.of(context).textTheme.titleMedium), FilledButton.icon(onPressed: _createProduct, icon: const Icon(Icons.add), label: const Text('افزودن کالا'))]),\n              const SizedBox(height: 8),\n              ...products.map((p) => Card(child: ListTile(title: Text(p['name']?.toString() ?? 'کالای بدون نام'), subtitle: Text('${p['price'] ?? 'قیمت توافقی'} • ${p['status'] ?? 'نامشخص'}'), trailing: PopupMenuButton<String>(onSelected: (action) { if (action == 'edit') _editProduct(p); if (action == 'delete') _deleteProduct(p); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'delete', child: Text('حذف'))]))),\n            ],\n          ],\n        ),\n      ),\n    );\n  }\n}).hasMatch(p)) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('نام، آدرس و شماره تلفن معتبر وارد کنید.')));
                return;
              }
              try {
                await ref.read(sellerStoreRepositoryProvider).updateMyStore(
                  name: n, address: a, phone: p,
                  city: city.text, province: province.text,
                  category: category.text, description: description.text,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (e) {
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
              }
            }, child: const Text('ذخیره')),
          ],
        ),
      );
      if (result == true && mounted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات فروشگاه بروزرسانی شد.')));
        setState(() {});
      }
    } finally {
      name.dispose(); address.dispose(); phone.dispose(); city.dispose(); province.dispose(); description.dispose(); category.dispose();
    }
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    final id = int.tryParse(product['id']?.toString() ?? '');
    if (id == null) return;
    final name = product['name']?.toString() ?? 'این کالا';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف کالا'),
        content: Text('«$name» حذف شود؟ این عملیات قابل برگشت نیست.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(sellerRepositoryProvider).deleteProduct(id);
      if (!mounted) return;
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا حذف شد.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
    }
  }

  Future<void> _editProduct(Map<String, dynamic> product) async {
    final id = int.tryParse(product['id']?.toString() ?? '');
    if (id == null) return;
    final name = TextEditingController(text: product['name']?.toString() ?? '');
    final price = TextEditingController(text: product['price']?.toString() ?? '');
    final description = TextEditingController(text: product['description']?.toString() ?? '');
    var status = product['status']?.toString() ?? 'موجود';
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('ویرایش کالا'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'نام کالا')),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت (تومان)')),
            DropdownButtonFormField<String>(value: status, items: const [
              DropdownMenuItem(value: 'موجود', child: Text('موجود')),
              DropdownMenuItem(value: 'فقط ۱ عدد', child: Text('فقط ۱ عدد')),
              DropdownMenuItem(value: 'ناموجود', child: Text('ناموجود')),
            ], onChanged: (v) => setDialogState(() => status = v ?? status)),
            TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),
            FilledButton(onPressed: () async {
              final n = name.text.trim();
              final p = num.tryParse(price.text.trim().replaceAll(',', ''));
              if (n.isEmpty || p == null || p < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('نام و قیمت معتبر وارد کنید.')));
                return;
              }
              try {
                await ref.read(sellerRepositoryProvider).updateProduct(id, name: n, price: p, status: status, description: description.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (e) {
                if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
              }
            }, child: const Text('ذخیره')),
          ],
        )),
      );
      if (result == true && mounted) {
        await _load();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا بروزرسانی شد.')));
      }
    } finally {
      name.dispose(); price.dispose(); description.dispose();
    }
  }

  Future<void> _createProduct() async {\n    final name = TextEditingController();\n    final price = TextEditingController();\n    final description = TextEditingController();\n    var status = 'موجود';\n    try {\n      final result = await showDialog<bool>(\n        context: context,\n        builder: (dialogContext) => StatefulBuilder(\n          builder: (dialogContext, setDialogState) => AlertDialog(\n            title: const Text('ثبت کالا'),\n            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [\n              TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'نام کالا')),\n              TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت (تومان)')),\n              DropdownButtonFormField<String>(value: status, items: const [\n                DropdownMenuItem(value: 'موجود', child: Text('موجود')),\n                DropdownMenuItem(value: 'فقط ۱ عدد', child: Text('فقط ۱ عدد')),\n                DropdownMenuItem(value: 'ناموجود', child: Text('ناموجود')),\n              ], onChanged: (v) => setDialogState(() => status = v ?? status)),\n              TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)')),\n            ])),\n            actions: [\n              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('انصراف')),\n              FilledButton(onPressed: () async {\n                final n = name.text.trim();\n                final p = num.tryParse(price.text.trim().replaceAll(',', ''));\n                if (n.isEmpty || p == null || p < 0) {\n                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('نام و قیمت معتبر وارد کنید.')));\n                  return;\n                }\n                try {\n                  await ref.read(sellerRepositoryProvider).createProduct(name: n, price: p, status: status, description: description.text);\n                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);\n                } catch (e) {\n                  if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));\n                }\n              }, child: const Text('ثبت کالا')),\n            ],\n          ),\n        ),\n      );\n      if (result == true && mounted) {\n        await _load();\n        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا ثبت شد.')));\n      }\n    } finally {\n      name.dispose(); price.dispose(); description.dispose();\n    }\n  }\n  Future<void> _load() async {\n    setState(() { loading = true; error = null; });\n    try {\n      final user = ref.read(authControllerProvider).valueOrNull;\n      final role = user?['role']?.toString();\n      if (role != 'seller' && role != 'admin') {\n        if (mounted) setState(() { products = []; loading = false; });\n        return;\n      }\n      final items = await ref.read(sellerRepositoryProvider).fetchProducts();\n      if (!mounted) return;\n      setState(() { products = items; loading = false; });\n    } catch (e) {\n      if (!mounted) return;\n      setState(() { error = networkErrorMessage(e); loading = false; });\n    }\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    final user = ref.watch(authControllerProvider).valueOrNull;\n    final role = user?['role']?.toString();\n    final isSeller = role == 'seller' || role == 'admin';\n    return Scaffold(\n      appBar: AppBar(title: const Text('فروشگاه من'), actions: [IconButton(onPressed: loading ? null : _load, icon: const Icon(Icons.refresh))]),\n      body: RefreshIndicator(\n        onRefresh: _load,\n        child: ListView(\n          physics: const AlwaysScrollableScrollPhysics(),\n          padding: const EdgeInsets.all(20),\n          children: [\n            Card(child: ListTile(leading: const Icon(Icons.storefront_outlined), title: Text(user?['name']?.toString() ?? 'فروشگاه من'), subtitle: Text(isSeller ? 'مدیریت ویترین و کالاها' : 'حساب شما هنوز فروشنده نیست'))),\n            const SizedBox(height: 16),\n            if (!isSeller) const Card(child: ListTile(leading: Icon(Icons.add_business_outlined), title: Text('ثبت فروشگاه'), subtitle: Text('برای شروع فروش، فروشگاه خود را ثبت کنید.')))\n            else if (loading) const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))\n            else if (error != null) Card(child: ListTile(leading: const Icon(Icons.error_outline), title: const Text('دریافت کالاها ناموفق بود'), subtitle: Text(error!), trailing: IconButton(onPressed: _load, icon: const Icon(Icons.refresh))))\n            else if (products.isEmpty) ...[const Card(child: ListTile(leading: Icon(Icons.inventory_2_outlined), title: Text('هنوز کالایی ثبت نکرده‌اید'), subtitle: Text('اولین کالا را ثبت کنید تا در کی‌داره دیده شود.'))), const SizedBox(height: 8), FilledButton.icon(onPressed: _createProduct, icon: const Icon(Icons.add), label: const Text('ثبت اولین کالا'))]\n            else ...[\n              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('کالاهای من (' + products.length.toString() + ')', style: Theme.of(context).textTheme.titleMedium), FilledButton.icon(onPressed: _createProduct, icon: const Icon(Icons.add), label: const Text('افزودن کالا'))]),\n              const SizedBox(height: 8),\n              ...products.map((p) => Card(child: ListTile(title: Text(p['name']?.toString() ?? 'کالای بدون نام'), subtitle: Text('${p['price'] ?? 'قیمت توافقی'} • ${p['status'] ?? 'نامشخص'}'), trailing: PopupMenuButton<String>(onSelected: (action) { if (action == 'edit') _editProduct(p); if (action == 'delete') _deleteProduct(p); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'delete', child: Text('حذف'))]))),\n            ],\n          ],\n        ),\n      ),\n    );\n  }\n}