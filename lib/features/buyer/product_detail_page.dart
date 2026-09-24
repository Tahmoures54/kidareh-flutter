import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'buyer_repository.dart';
import '../../core/network/api_client.dart';

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
    setState(() { loading = true; error = null; });
    try { final result = await repo.getProduct(widget.productId); if (!mounted) return; setState(() { product = result; loading = false; }); }
    catch (e) { if (mounted) setState(() { loading = false; error = networkErrorMessage(e); }); }
  }
  @override Widget build(BuildContext context) {
    final item = product;
    return Scaffold(appBar: AppBar(title: const Text('جزئیات کالا')), body: loading
      ? const Center(child: CircularProgressIndicator())
      : error != null ? Center(child: FilledButton(onPressed: _load, child: Text(error!)))
      : item == null ? const Center(child: Text('کالا پیدا نشد')) : _content(context, item));
  }
  Future<void> _openExternal(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('امکان باز کردن این مورد وجود ندارد')));
    }
  }

  Future<void> _callStore(String phone) => _openExternal(Uri(scheme: 'tel', path: phone));

  Future<void> _openMap(Map<String, dynamic> item, String address) async {
    final lat = double.tryParse(item['lat']?.toString() ?? item['latitude']?.toString() ?? '');
    final lng = double.tryParse(item['lng']?.toString() ?? item['longitude']?.toString() ?? '');
    final label = Uri.encodeComponent(address.isNotEmpty ? address : 'فروشگاه کی‌داره');
    final uri = lat != null && lng != null
        ? Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$label');
    await _openExternal(uri);
  }

  Widget _content(BuildContext context, Map<String, dynamic> item) {
    final name = (item['name'] ?? item['title'] ?? 'کالا').toString();
    final status = buyerStatusLabel(item['status']);
    final store = (item['store_name'] ?? '').toString();
    final city = (item['store_city'] ?? item['city'] ?? '').toString();
    final address = (item['address'] ?? item['store_address'] ?? '').toString();
    final phone = (item['store_phone'] ?? item['phone'] ?? '').toString().trim();
    final description = (item['description'] ?? '').toString().trim();
    final imageUrl = (item['image_url'] ?? '').toString().trim();
    final storeId = int.tryParse(item['store_id']?.toString() ?? '');
    final price = item['price'];
    final priceText = buyerPriceLabel(price);
    final normalizedStatus = status.trim().toLowerCase();
    final available = normalizedStatus == 'موجود' || normalizedStatus == 'فقط ۱ عدد' || normalizedStatus == 'available';
    return ListView(padding: const EdgeInsets.fromLTRB(16,16,16,32), children: [
      if (imageUrl.isNotEmpty) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.35,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.image_not_supported_outlined)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
      Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      Row(children: [Expanded(child: Text(priceText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
        Chip(label: Text(status), avatar: Icon(available ? Icons.check_circle_outline : Icons.remove_circle_outline, size: 18))]),
      if (store.isNotEmpty || city.isNotEmpty) Card(child: ListTile(leading: const Icon(Icons.storefront_outlined), title: Text(store.isNotEmpty ? store : 'فروشگاه'), subtitle: city.isNotEmpty ? Text(city) : null)),
      if (address.isNotEmpty)
        Card(child: ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: const Text('آدرس فروشگاه'),
          subtitle: Text(address),
          trailing: IconButton(
            tooltip: 'مسیریابی',
            onPressed: () => _openMap(item, address),
            icon: const Icon(Icons.directions_outlined),
          ),
        )),
      if (store.isNotEmpty || phone.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          if (storeId != null)
            Expanded(child: OutlinedButton.icon(
              onPressed: () => context.push('/stores/$storeId'),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('مشاهده فروشگاه'),
            )),
          if (storeId != null && phone.isNotEmpty) const SizedBox(width: 8),
          if (phone.isNotEmpty)
            Expanded(child: FilledButton.icon(
              onPressed: () => _callStore(phone),
              icon: const Icon(Icons.phone_outlined),
              label: const Text('تماس با فروشگاه'),
            )),
        ]),
      ],
      if (description.isNotEmpty) ...[const SizedBox(height:16), const Text('توضیحات', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height:6), Text(description)],
      const SizedBox(height:24),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(available ? 'خرید این کالا به‌صورت حضوری از فروشگاه انجام می‌شود.' : 'این کالا در حال حاضر موجود نیست؛ برای اطلاع از موجودی می‌توانی با فروشگاه تماس بگیری.'))),
    ]);
  }
}