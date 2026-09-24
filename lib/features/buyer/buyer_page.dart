import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/product.dart';
import '../../core/network/api_client.dart';
import 'buyer_repository.dart';
import 'city_picker.dart';

class BuyerPage extends StatefulWidget {
  const BuyerPage({super.key});

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  final q = TextEditingController();
  final scroll = ScrollController();
  final repo = BuyerRepository();

  final List<Product> items = [];
  final List<String> recentSearches = [];

  bool loading = false;
  bool loadingMore = false;
  bool hasMore = false;
  bool showingCache = false;
  String? cursor;
  String? error;
  String? selectedCity;
  String lastQuery = '';
  int _searchGeneration = 0;

  static const _queryKey = 'kidareh_last_query';
  static const _cityKey = 'kidareh_last_city';
  static const _resultsKey = 'kidareh_last_results';

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
    q.addListener(_onQueryChanged);
    _restoreLastSearch();
  }

  @override
  void dispose() {
    q.removeListener(_onQueryChanged);
    q.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!scroll.hasClients || scroll.position.extentAfter > 500) return;
    if (lastQuery.isNotEmpty && hasMore && !loading && !loadingMore) {
      _loadMore();
    }
  }

  Future<void> _restoreLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuery = prefs.getString(_queryKey)?.trim() ?? '';
    final savedCity = prefs.getString(_cityKey)?.trim() ?? '';
    final raw = prefs.getString(_resultsKey);
    if (!mounted) return;
    if (savedQuery.isNotEmpty) {
      q.text = savedQuery;
      lastQuery = savedQuery;
    }
    if (savedCity.isNotEmpty) selectedCity = savedCity;
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        items
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map((item) => Product.fromJson(Map<String, dynamic>.from(item))),
          );
        showingCache = items.isNotEmpty;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queryKey, lastQuery);
    await prefs.setString(_cityKey, selectedCity ?? '');
    await prefs.setString(
      _resultsKey,
      jsonEncode(items.take(20).map((item) => item.toJson()).toList()),
    );
  }

  Future<void> search([String? value]) async {
    final query = (value ?? q.text).trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    q.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    final generation = ++_searchGeneration;
    setState(() {
      loading = true;
      loadingMore = false;
      showingCache = items.isNotEmpty && lastQuery == query;
      error = null;
      cursor = null;
      hasMore = false;
      lastQuery = query;
    });

    _remember(query);

    try {
      final page = await repo.search(query, city: selectedCity);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        items
          ..clear()
          ..addAll(page.items);
        hasMore = page.hasMore;
        cursor = page.nextCursor;
        showingCache = false;
      });
      await _persist();
    } catch (e) {
      if (mounted && generation == _searchGeneration) {
        setState(() => error = networkErrorMessage(e));
      }
    } finally {
      if (mounted && generation == _searchGeneration) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (lastQuery.isEmpty || !hasMore || loadingMore || cursor == null) return;
    setState(() {
      loadingMore = true;
      error = null;
    });

    final generation = _searchGeneration;
    try {
      final page = await repo.search(lastQuery, cursor: cursor, city: selectedCity);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        items.addAll(page.items);
        hasMore = page.hasMore;
        cursor = page.nextCursor;
      });
      await _persist();
    } catch (e) {
      if (mounted && generation == _searchGeneration) {
        setState(() => error = networkErrorMessage(e));
      }
    } finally {
      if (mounted && generation == _searchGeneration) {
        setState(() => loadingMore = false);
      }
    }
  }

  void _remember(String query) {
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 5) recentSearches.removeLast();
  }

  void _clearSearch() {
    _searchGeneration++;
    q.clear();
    setState(() {
      items.clear();
      error = null;
      cursor = null;
      hasMore = false;
      lastQuery = '';
      showingCache = false;
    });
  }

  void _onCityChanged(String? city) {
    setState(() => selectedCity = city);
    if (lastQuery.isNotEmpty) search(lastQuery);
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امکان تماس وجود ندارد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پیدا کردن کالا')),
      body: ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          TextField(
            controller: q,
            autofocus: lastQuery.isEmpty,
            textInputAction: TextInputAction.search,
            onSubmitted: search,
            decoration: InputDecoration(
              hintText: 'اسم کالا یا برند',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: q.text.isEmpty
                  ? IconButton(
                      tooltip: 'جستجو',
                      onPressed: () => search(),
                      icon: const Icon(Icons.arrow_forward),
                    )
                  : IconButton(
                      tooltip: 'پاک کردن',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          CityPickerField(city: selectedCity, onChanged: _onCityChanged),
          if (lastQuery.isEmpty && recentSearches.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('جستجوهای اخیر', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches
                  .map((term) => ActionChip(label: Text(term), onPressed: () => search(term)))
                  .toList(),
            ),
          ],
          if (showingCache && items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('نتیجه قبلی — در حال بروزرسانی'),
            ),
          if (loading && items.isEmpty) ...[
            const SizedBox(height: 32),
            const Center(child: CircularProgressIndicator()),
          ],
          if (error != null && !loading)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(error!),
                  trailing: TextButton(
                    onPressed: () => search(lastQuery),
                    child: const Text('تلاش دوباره'),
                  ),
                ),
              ),
            ),
          if (!loading && error == null && lastQuery.isNotEmpty && items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'نتیجه‌ای پیدا نشد. نام کالا یا شهر دیگری را امتحان کن.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${items.length}${hasMore ? '+' : ''} نتیجه',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...items.map(_productCard),
            if (loadingMore)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/products/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: product.imageUrl.isEmpty
                      ? const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.inventory_2_outlined, size: 30),
                        )
                      : Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Colors.black12,
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Text(product.priceLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(product.available ? Icons.check_circle_outline : Icons.remove_circle_outline, size: 16),
                          label: Text(product.statusLabel),
                        ),
                        if (product.storeName.isNotEmpty)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: const Icon(Icons.storefront_outlined, size: 16),
                            label: Text(product.storeName),
                          ),
                      ],
                    ),
                    if (product.storeCity.isNotEmpty)
                      Text(product.storeCity, style: Theme.of(context).textTheme.bodySmall),
                    if (product.storePhone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _call(product.storePhone),
                          icon: const Icon(Icons.phone_outlined, size: 18),
                          label: const Text('تماس'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
