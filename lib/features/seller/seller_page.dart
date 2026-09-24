import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/product.dart';
import '../../core/models/store.dart';
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
  SellerStats? stats;

  bool get _isSeller {
    final role = ref.read(authControllerProvider).valueOrNull?['role']?.toString();
    return role == 'seller' || role == 'admin';
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    await Future.wait([_loadProducts(), _loadStats()]);
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

  Future<void> _loadStats() async {
    if (!_isSeller) {
      if (mounted) setState(() => stats = null);
      return;
    }
    try {
      final value = await ref.read(sellerRepositoryProvider).fetchMyStats();
      if (mounted) setState(() => stats = value);
    } catch (_) {
      if (mounted) setState(() => stats = null);
    }
  }

  Future<void> _showFollowers() async {
    try {
      final followers = await ref.read(sellerRepositoryProvider).fetchMyFollowers();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .72,
            child: followers.isEmpty
                ? const Center(child: Text('هنوز کسی ویترین شما را دنبال نکرده است.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: followers.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final f = followers[i];
                      final name = f['name']?.trim() ?? '';
                      final details = [
                        if ((f['phone'] ?? '').isNotEmpty) f['phone'],
                        if ((f['followed_at'] ?? '').isNotEmpty) 'دنبال‌کردن: ${f['followed_at']}',
                      ].join(' • ');
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                        title: Text(name.isNotEmpty ? name : 'دنبال‌کننده'),
                        subtitle: details.isEmpty ? null : Text(details),
                      );
                    },
                  ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
      }
    }
  }

  Future<void> _editStore() async {
    try {
      final store = await ref.read(sellerRepositoryProvider).fetchMyStore();
      if (!mounted) return;
      final name = TextEditingController(text: store.name);
      final address = TextEditingController(text: store.address);
      final phone = TextEditingController(text: store.phone);
      final city = TextEditingController(text: store.city);
      final province = TextEditingController(text: store.province);
      final category = TextEditingController(text: store.category);
      final description = TextEditingController(text: store.description);
      try {
        final ok = await showDialog<bool>(
          context: context,
          builder: (dc) => AlertDialog(
            title: const Text('ویرایش فروشگاه'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: const InputDecoration(labelText: 'نام فروشگاه')),
                  TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'تلفن فروشگاه')),
                  TextField(controller: city, decoration: const InputDecoration(labelText: 'شهر')),
                  TextField(controller: province, decoration: const InputDecoration(labelText: 'استان')),
                  TextField(controller: address, maxLines: 2, decoration: const InputDecoration(labelText: 'آدرس')),
                  TextField(controller: category, decoration: const InputDecoration(labelText: 'دسته‌بندی')),
                  TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('انصراف')),
              FilledButton(
                onPressed: () async {
                  final n = name.text.trim();
                  final a = address.text.trim();
                  final p = phone.text.trim();
                  if (n.length < 2 || a.length < 5 || !RegExp(r'^09\d{9}$').hasMatch(p)) {
                    ScaffoldMessenger.of(dc).showSnackBar(const SnackBar(content: Text('نام، آدرس و شماره تلفن معتبر وارد کنید.')));
                    return;
                  }
                  try {
                    await ref.read(sellerRepositoryProvider).updateMyStore(
                      name: n,
                      address: a,
                      phone: p,
                      city: city.text,
                      province: province.text,
                      category: category.text,
                      description: description.text,
                    );
                    if (dc.mounted) Navigator.pop(dc, true);
                  } catch (e) {
                    if (dc.mounted) {
                      ScaffoldMessenger.of(dc).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
                    }
                  }
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        );
        if (ok == true && mounted) {
          await _loadStats();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات فروشگاه بروزرسانی شد.')));
        }
      } finally {
        name.dispose();
        address.dispose();
        phone.dispose();
        city.dispose();
        province.dispose();
        category.dispose();
        description.dispose();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
      }
    }
  }

  Future<void> _productDialog({Product? product}) async {
    final editing = product != null;
    final name = TextEditingController(text: product?.name ?? '');
    final price = TextEditingController(text: product?.price?.toString() ?? '');
    final description = TextEditingController(text: product?.description ?? '');
    var status = product?.status.isNotEmpty == true ? product!.status : 'موجود';

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (dc) => StatefulBuilder(
          builder: (dc, set) => AlertDialog(
            title: Text(editing ? 'ویرایش کالا' : 'ثبت کالا'),
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
                  TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات (اختیاری)')),
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
                      await repo.updateProduct(product.id, name: n, price: p, status: status, description: description.text);
                    } else {
                      await repo.createProduct(name: n, price: p, status: status, description: description.text);
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
        await _reload();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(editing ? 'کالا بروزرسانی شد.' : 'کالا ثبت شد.')),
        );
      }
    } finally {
      name.dispose();
      price.dispose();
      description.dispose();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('حذف کالا'),
        content: Text('«${product.name}» حذف شود؟ این عملیات قابل برگشت نیست.'),
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
      await _reload();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کالا حذف شد.')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(networkErrorMessage(e))));
      }
    }
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final seller = _isSeller;
    return Scaffold(
      appBar: AppBar(
        title: const Text('فروشگاه من'),
        actions: [
          IconButton(onPressed: _showFollowers, tooltip: 'دنبال‌کنندگان', icon: const Icon(Icons.people_outline)),
          IconButton(onPressed: _editStore, tooltip: 'ویرایش فروشگاه', icon: const Icon(Icons.store_outlined)),
          IconButton(onPressed: loading ? null : _reload, tooltip: 'بازخوانی', icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('فروشگاه من'),
                subtitle: Text(seller ? 'مدیریت ویترین و کالاها' : 'حساب شما هنوز فروشنده نیست'),
              ),
            ),
            if (seller && stats != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('کالا', stats!.productCount),
                  _stat('بازدید', stats!.totalViews),
                  _stat('دنبال‌کننده', stats!.followerCount),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (!seller)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.add_business_outlined),
                  title: Text('ثبت فروشگاه'),
                  subtitle: Text('برای شروع فروش، فروشگاه خود را ثبت کنید.'),
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
                  title: Text('هنوز کالایی ثبت نکرده‌اید'),
                  subtitle: Text('اولین کالا را ثبت کنید تا در کی‌داره دیده شود.'),
                ),
              ),
              FilledButton.icon(onPressed: () => _productDialog(), icon: const Icon(Icons.add), label: const Text('ثبت اولین کالا')),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('کالاهای من (${products.length})', style: Theme.of(context).textTheme.titleMedium),
                  FilledButton.icon(onPressed: () => _productDialog(), icon: const Icon(Icons.add), label: const Text('افزودن کالا')),
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
          ],
        ),
      ),
    );
  }
}
