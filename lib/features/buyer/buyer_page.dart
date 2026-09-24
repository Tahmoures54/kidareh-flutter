import 'package:flutter/material.dart';
import 'buyer_repository.dart';
import 'package:go_router/go_router.dart';

class BuyerPage extends StatefulWidget {
  const BuyerPage({super.key});

  @override
  State<BuyerPage> createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  final q = TextEditingController();
  final scroll = ScrollController();
  final repo = BuyerRepository();

  final List<Map<String, dynamic>> items = [];
  final List<String> recentSearches = [];

  bool loading = false;
  bool loadingMore = false;
  bool hasMore = false;
  String? cursor;
  String? error;
  String lastQuery = '';

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
    setState(() {
      q.text = query;
      q.selection = TextSelection.collapsed(offset: q.text.length);
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
      if (!mounted) return;
      setState(() {
        items.addAll(page.items);
        hasMore = page.hasMore;
        cursor = page.nextCursor;
      });
    } catch (_) {
      if (mounted) setState(() => error = 'دریافت کالاها انجام نشد');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (lastQuery.isEmpty || !hasMore || loadingMore || cursor == null) return;
    setState(() {
      loadingMore = true;
      error = null;
    });

    try {
      final page = await repo.search(lastQuery, cursor: cursor);
      if (!mounted) return;
      setState(() {
        items.addAll(page.items);
        hasMore = page.hasMore;
        cursor = page.nextCursor;
      });
    } catch (_) {
      if (mounted) setState(() => error = 'نتایج بعدی دریافت نشد');
    } finally {
      if (mounted) setState(() => loadingMore = false);
    }
  }

  void _remember(String query) {
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 5) recentSearches.removeLast();
  }

  void _clearSearch() {
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
            const Text(
              'جستجوهای اخیر',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches
                  .map(
                    (term) => ActionChip(
                      label: Text(term),
                      onPressed: () => search(term),
                    ),
                  )
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

  Widget _productCard(Map<String, dynamic> product) {
    final name = (product['name'] ?? product['title'] ?? 'کالا').toString();
    final price = product['price'];
    final status = (product['status'] ?? 'ناموجود').toString();
    final productId = int.tryParse(product['id']?.toString() ?? '');
    final store = (product['store_name'] ?? '').toString();
    final city = (product['store_city'] ?? product['city'] ?? '').toString();

    final priceText = price is num && price > 0
        ? '${price.toStringAsFixed(0)} تومان'
        : 'قیمت توافقی';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: productId != null ? () => context.push('/products/$productId') : null,
        leading: const CircleAvatar(
          child: Icon(Icons.inventory_2_outlined),
        ),
        title: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            priceText,
            status,
            if (store.isNotEmpty) store,
            if (city.isNotEmpty) city,
          ].join(' • '),
        ),
      ),
    );
  }
}
