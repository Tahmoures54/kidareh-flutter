import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/product.dart';
import '../../core/network/api_client.dart';
import 'buyer_repository.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});
  final int productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final repo = BuyerRepository();
  Product? product;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await repo.getProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        product = result;
        loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          error = networkErrorMessage(e);
        });
      }
    }
  }

  Future<void> _openExternal(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان باز کردن این مورد وجود ندارد')),
      );
    }
  }

  Future<void> _openMap(Product item) async {
    final hasCoords = item.latitude != null &&
        item.longitude != null &&
        item.latitude! >= -90 &&
        item.latitude! <= 90 &&
        item.longitude! >= -180 &&
        item.longitude! <= 180;
    if (!hasCoords && item.storeAddress.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('آدرس فروشگاه ثبت نشده است')),
        );
      }
      return;
    }
    final query = hasCoords ? '${item.latitude},${item.longitude}' : item.storeAddress.trim();
    await _openExternal(Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}));
  }

  @override
  Widget build(BuildContext context) {
    final item = product;
    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات کالا')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: FilledButton(onPressed: _load, child: Text(error!)))
              : item == null
                  ? const Center(child: Text('کالا پیدا نشد'))
                  : _content(context, item),
    );
  }

  Widget _content(BuildContext context, Product item) {
    final hasLocation = item.storeAddress.isNotEmpty ||
        (item.latitude != null && item.longitude != null);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (item.imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: Image.network(
                item.imageUrl,
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
        Text(item.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(item.priceLabel, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Chip(
              label: Text(item.statusLabel),
              avatar: Icon(item.available ? Icons.check_circle_outline : Icons.remove_circle_outline, size: 18),
            ),
          ],
        ),
        if (item.storeName.isNotEmpty || item.storeCity.isNotEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(item.storeName.isNotEmpty ? item.storeName : 'فروشگاه'),
              subtitle: item.storeCity.isNotEmpty ? Text(item.storeCity) : null,
            ),
          ),
        if (hasLocation)
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('آدرس فروشگاه'),
              subtitle: Text(item.storeAddress.isNotEmpty ? item.storeAddress : 'موقعیت فروشگاه ثبت شده است'),
              trailing: IconButton(
                tooltip: 'مسیریابی',
                onPressed: () => _openMap(item),
                icon: const Icon(Icons.directions_outlined),
              ),
            ),
          ),
        if (item.storeId != null || item.storePhone.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (item.storeId != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/stores/${item.storeId}'),
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('مشاهده فروشگاه'),
                  ),
                ),
              if (item.storeId != null && item.storePhone.isNotEmpty) const SizedBox(width: 8),
              if (item.storePhone.isNotEmpty)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openExternal(Uri(scheme: 'tel', path: item.storePhone)),
                    icon: const Icon(Icons.phone_outlined),
                    label: const Text('تماس با فروشگاه'),
                  ),
                ),
            ],
          ),
        ],
        if (item.description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('توضیحات', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(item.description),
        ],
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.available
                  ? 'خرید این کالا به‌صورت حضوری از فروشگاه انجام می‌شود.'
                  : 'این کالا در حال حاضر موجود نیست؛ برای اطلاع از موجودی می‌توانی با فروشگاه تماس بگیری.',
            ),
          ),
        ),
      ],
    );
  }
}
