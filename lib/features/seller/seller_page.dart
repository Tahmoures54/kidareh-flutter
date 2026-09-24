import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/web_config.dart';
import '../../core/models/product.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_controller.dart';
import 'seller_repository.dart';

class SellerPage extends ConsumerStatefulWidget {
  const SellerPage({super.key});

  @override
  ConsumerState<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends ConsumerState<SellerPage> {
  bool loading = true;
  String? error;
  List<Product> products = [];

  bool get _isSeller {
    final role = ref.read(authControllerProvider).valueOrNull?['role']?.toString();
    return role == 'seller' || role == 'admin';
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      if (!_isSeller) {
        if (mounted) setState(() { products = []; loading = false; });
        return;
      }
      final items = await ref.read(sellerRepositoryProvider).fetchProducts();
      if (mounted) setState(() { products = items; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = networkErrorMessage(e); loading = false; });
    }
  }

  Future<void> _productDialog({Product? product}) async {
    final editing = product != null;
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price?.toString() ?? '');
    var status = product?.status.isNotEmpty == true ? product!.status : 'موجود';

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dc) => StatefulBuilder(
          builder: (dc, set) => AlertDialog(
            title: Text(editing ? 'قیمت و موجودی' : 'ثبت کالا'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'نام کالا')),
                  TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت (تومان)')),
                  DropdownButtonFormField<String>(
                    value: const ['موجود', 'فقط ۱ عدد', 'ناموجود'].contains(status) ? status : 'موجود',
                    items: const [
                      DropdownMenuItem(value: 'موجود', child: Text('موجود')),
                      DropdownMenuItem(value: 'فقط ۱ عدد', child: Text('فقط ۱ عدد')),
                      DropdownMenuItem(value: 'ناموجود', child: Text('ناموجود')),
                    ],
                    onChanged: (value) => set(() => status = value ?? status),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('انصراف')),
              FilledButton(
                onPressed: () async {
                  final n = name.text.trim();
                  final p = num.tryParse(price.text.trim().replaceAll(',', ''));
                  if (n.isEmpty || p == null || p < 0) {
                    ScaffoldMessenger.of(dc).showSnackBar(const SnackBar(content: Text('نام و قیمت معتبر وارد کنید.')));
                    return;
                  }
                  try {
                    final repo = ref.read(sellerRepositoryProvider);
                    if (editing) {
                      await repo.updateProduct(product.id, name: n, price: p, status: status);
                    } else {
                      await repo.createProduct(name: n, price: p, status: status);
                    }
                    if (dc.mounted) Navigator.pop(dc, true);
                  } catch (e) {
                    if (dc.mounted) {
                      ScaffoldMessenger.of(dc).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
                    }
                  }
                },
                child: Text(editing ? 'ذخیره' : 'ثبت کالا'),
              ),
            ],
          ),
        ),
      );
      if (ok == true && mounted) {
        await _loadProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(editing ? 'کالا بروزرسانی شد.' : 'کالا ثبت شد.')),
        );
      }
    } finally {
      name.dispose();
      price.dispose();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('حذف کالا'),
        content: Text('«${product.name}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('انصراف')),
          FilledButton.tonal(onPressed: () => Navigator.pop(dc, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(sellerRepositoryProvider).deleteProduct(product.id);
      if (!mounted) return;
      await _loadProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final seller = _isSeller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('کالاهای من'),
        actions: [
          IconButton(onPressed: loading ? null : _loadProducts, tooltip: 'بازخوانی', icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            if (!seller)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.add_business_outlined),
                  title: Text('ثبت فروشگاه روی سایت'),
                  subtitle: Text('این اپ فقط قیمت و موجودی را عوض می‌کند.'),
                ),
              )
            else if (loading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (error != null)
              Card(
                child: ListTile(
                  title: const Text('دریافت کالاها ناموفق بود'),
                  subtitle: Text(error!),
                  trailing: IconButton(onPressed: _loadProducts, icon: const Icon(Icons.refresh)),
                ),
              )
            else if (products.isEmpty) ...[
              const Card(
                child: ListTile(
                  leading: Icon(Icons.inventory_2_outlined),
                  title: Text('هنوز کالایی نیست'),
                  subtitle: Text('نام، قیمت و وضعیت موجودی را ثبت کن.'),
                ),
              ),
              FilledButton.icon(onPressed: () => _productDialog(), icon: const Icon(Icons.add), label: const Text('ثبت کالا')),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('موجودی و قیمت (${products.length})', style: Theme.of(context).textTheme.titleMedium),
                  FilledButton.icon(onPressed: () => _productDialog(), icon: const Icon(Icons.add), label: const Text('افزودن')),
                ],
              ),
              const SizedBox(height: 8),
              ...products.map(
                (p) => Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text('${p.priceLabel} • ${p.statusLabel}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _productDialog(product: p);
                        } else {
                          _deleteProduct(p);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                        PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => WebConfig.open('/seller'),
              icon: const Icon(Icons.open_in_new),
              label: const Text('تنظیمات کامل فروشگاه در سایت'),
            ),
          ],
        ),
      ),
    );
  }
}
