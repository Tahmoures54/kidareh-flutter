import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/product.dart';
import '../../core/network/api_client.dart';
import 'buyer_repository.dart';

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
  String? cursor;
  String? error;
  String lastQuery = '';
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
    q.addListener(_onQueryChanged);
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
      error = null;
      cursor = null;
      hasMore = false;
      items.clear();
      lastQuery = query;
    });

    _remember(query);

    try {
      final page = await repo.search(query);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        items.addAll(page.items);
        hasMore = page.hasMore;
        cursor = page.nextCursor;
      });
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
      final page = await repo.search(lastQuery, cursor: cursor);
      if (!mounted || generation != _searchGeneration) return;
      setState(() {
        items.addAll(page.items);
        hasMore = page.hasMore;
        cursor = page.nextCursor;
      });
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
    });
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
            autofocus: true,
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
          if (loading) ...[
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
                  'نتیجه‌ای پیدا نشد. نام کالا یا برند دیگری را امتحان کن.',
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
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      product.priceLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(
                            product.available ? Icons.check_circle_outline : Icons.remove_circle_outline,
                            size: 16,
                          ),
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
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 28),
                child: Icon(Icons.chevron_left),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
