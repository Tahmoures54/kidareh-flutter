import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/store.dart';
import '../../core/network/api_client.dart';
import 'buyer_repository.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  final repo = BuyerRepository();
  Store? store;
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
      final data = await repo.getStore(widget.storeId);
      if (!mounted) return;
      setState(() {
        store = data;
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

  Future<void> _open(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان باز کردن این مورد وجود ندارد')),
      );
    }
  }

  Future<void> _openMap(Store data) async {
    final validCoords = data.latitude != null &&
        data.longitude != null &&
        data.latitude! >= -90 &&
        data.latitude! <= 90 &&
        data.longitude! >= -180 &&
        data.longitude! <= 180;
    final query = validCoords ? '${data.latitude},${data.longitude}' : data.address.trim();
    if (query.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('موقعیت یا آدرس فروشگاه ثبت نشده است')),
        );
      }
      return;
    }
    await _open(Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}));
  }

  @override
  Widget build(BuildContext context) {
    final data = store;
    return Scaffold(
      appBar: AppBar(title: const Text('فروشگاه')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: FilledButton(onPressed: _load, child: Text(error!)))
              : data == null
                  ? const Center(child: Text('فروشگاه پیدا نشد'))
                  : _content(context, data),
    );
  }

  Widget _content(BuildContext context, Store data) {
    final place = [data.city, data.province].where((e) => e.isNotEmpty).join('، ');
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (data.imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 2.2,
              child: Image.network(
                data.imageUrl,
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
        Text(data.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        if (place.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(place)),
        if (data.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text(data.description)),
        if (data.address.isNotEmpty || (data.latitude != null && data.longitude != null))
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('آدرس'),
              subtitle: Text(data.address.isNotEmpty ? data.address : 'موقعیت فروشگاه ثبت شده است'),
              trailing: IconButton(
                tooltip: 'مسیریابی',
                onPressed: () => _openMap(data),
                icon: const Icon(Icons.directions_outlined),
              ),
            ),
          ),
        if (data.phone.isNotEmpty)
          FilledButton.icon(
            onPressed: () => _open(Uri(scheme: 'tel', path: data.phone)),
            icon: const Icon(Icons.phone_outlined),
            label: const Text('تماس با فروشگاه'),
          ),
        if (data.products.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('کالاهای فروشگاه', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...data.products.map((p) {
            return Card(
              child: ListTile(
                onTap: () => context.push('/products/${p.id}'),
                leading: p.imageUrl.isEmpty
                    ? const CircleAvatar(child: Icon(Icons.inventory_2_outlined))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.imageUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                        ),
                      ),
                title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${p.priceLabel} • ${p.statusLabel}'),
                trailing: Icon(p.available ? Icons.chevron_left : Icons.info_outline),
              ),
            );
          }),
        ],
      ],
    );
  }
}
