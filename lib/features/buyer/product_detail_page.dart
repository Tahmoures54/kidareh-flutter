import 'package:flutter/material.dart';
import 'buyer_repository.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});
  final int productId;
  @override State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final repo = BuyerRepository();
  Map<String, dynamic>? product; bool loading = true; String? error;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final result = await repo.getProduct(widget.productId); if (!mounted) return; setState(() { product = result; loading = false; }); }
    catch (_) { if (mounted) setState(() { loading = false; error = 'اطلاعات کالا دریافت نشد'; }); }
  }
  @override Widget build(BuildContext context) {
    final item = product;
    return Scaffold(appBar: AppBar(title: const Text('جزئیات کالا')), body: loading
      ? const Center(child: CircularProgressIndicator())
      : error != null ? Center(child: FilledButton(onPressed: _load, child: Text(error!)))
      : item == null ? const Center(child: Text('کالا پیدا نشد')) : _content(context, item));
  }
  Widget _content(BuildContext context, Map<String, dynamic> item) {
    final name = (item['name'] ?? item['title'] ?? 'کالا').toString();
    final status = (item['status'] ?? 'ناموجود').toString();
    final store = (item['store_name'] ?? '').toString();
    final city = (item['store_city'] ?? item['city'] ?? '').toString();
    final address = (item['address'] ?? item['store_address'] ?? '').toString();
    final description = (item['description'] ?? '').toString();
    final price = item['price'];
    final priceText = price is num && price > 0 ? '${price.toStringAsFixed(0)} تومان' : 'قیمت توافقی';
    final available = status.trim() == 'موجود' || status.trim() == 'فقط ۱ عدد' || status.trim().toLowerCase() == 'available';
    return ListView(padding: const EdgeInsets.fromLTRB(16,16,16,32), children: [
      Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: Text(priceText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
        Chip(label: Text(status), avatar: Icon(available ? Icons.check_circle_outline : Icons.remove_circle_outline, size: 18))]),
      if (store.isNotEmpty || city.isNotEmpty) Card(child: ListTile(leading: const Icon(Icons.storefront_outlined), title: Text(store.isNotEmpty ? store : 'فروشگاه'), subtitle: city.isNotEmpty ? Text(city) : null)),
      if (address.isNotEmpty) Card(child: ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('آدرس فروشگاه'), subtitle: Text(address))),
      if (description.isNotEmpty) ...[const SizedBox(height:16), const Text('توضیحات', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height:6), Text(description)],
      const SizedBox(height:24),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(available ? 'خرید این کالا به‌صورت حضوری از فروشگاه انجام می‌شود.' : 'این کالا در حال حاضر موجود نیست؛ برای اطلاع از موجودی می‌توانی با فروشگاه تماس بگیری.'))),
    ]);
  }
}