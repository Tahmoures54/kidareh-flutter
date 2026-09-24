import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/iran_cities.dart';

class BlinkingGreenLight extends StatefulWidget {
  const BlinkingGreenLight({super.key});

  @override
  State<BlinkingGreenLight> createState() => _BlinkingGreenLightState();
}

class _BlinkingGreenLightState extends State<BlinkingGreenLight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.25, end: 1).animate(_controller),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.65),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared location item for city or village.
class IranLocation {
  const IranLocation({
    required this.name,
    required this.province,
    required this.isVillage,
  });

  final String name;
  final String province;
  final bool isVillage;

  String get subtitle => isVillage
      ? (province.isEmpty ? 'روستا' : 'روستا · $province')
      : province;
}

/// Lazy loader for villages from official sajaddp dataset (cached).
class IranVillagesLoader {
  IranVillagesLoader._();
  static final IranVillagesLoader instance = IranVillagesLoader._();

  static const _cacheKey = 'iran_villages_v1';
  static const _url =
      'https://raw.githubusercontent.com/sajaddp/list-of-cities-in-Iran/main/dist/json/villages.json';
  static const _provincesUrl =
      'https://raw.githubusercontent.com/sajaddp/list-of-cities-in-Iran/main/dist/json/provinces.json';

  List<IranLocation>? _cache;
  Future<List<IranLocation>>? _inFlight;

  Future<List<IranLocation>> load() {
    if (_cache != null) return Future.value(_cache!);
    return _inFlight ??= _load();
  }

  Future<List<IranLocation>> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        final list = _parseCompact(cached);
        if (list.isNotEmpty) {
          _cache = list;
          return list;
        }
      }

      final results = await Future.wait([
        http.get(Uri.parse(_url)).timeout(const Duration(seconds: 45)),
        http.get(Uri.parse(_provincesUrl)).timeout(const Duration(seconds: 15)),
      ]);
      final villagesRes = results[0];
      final provincesRes = results[1];
      if (villagesRes.statusCode != 200) {
        throw Exception('villages HTTP ${villagesRes.statusCode}');
      }

      final provMap = <int, String>{};
      if (provincesRes.statusCode == 200) {
        final provList = jsonDecode(provincesRes.body) as List<dynamic>;
        for (final p in provList) {
          final m = p as Map<String, dynamic>;
          final id = m['id'];
          final name = m['name'] as String? ?? '';
          if (id is int) provMap[id] = name;
        }
      }

      final raw = jsonDecode(villagesRes.body) as List<dynamic>;
      final seen = <String>{};
      final items = <IranLocation>[];
      for (final e in raw) {
        final m = e as Map<String, dynamic>;
        final name = (m['name'] as String?)?.trim() ?? '';
        if (name.isEmpty || !seen.add(name)) continue;
        final pid = m['province_id'];
        final province = pid is int ? (provMap[pid] ?? '') : '';
        items.add(IranLocation(name: name, province: province, isVillage: true));
      }
      items.sort((a, b) => a.name.compareTo(b.name));

      final compact = items.map((e) => [e.name, e.province]).toList();
      await prefs.setString(_cacheKey, jsonEncode(compact));

      _cache = items;
      return items;
    } catch (_) {
      _inFlight = null;
      rethrow;
    }
  }

  List<IranLocation> _parseCompact(String cached) {
    final list = jsonDecode(cached) as List<dynamic>;
    final items = <IranLocation>[];
    for (final e in list) {
      if (e is List && e.isNotEmpty) {
        final name = e[0]?.toString() ?? '';
        final province = e.length > 1 ? (e[1]?.toString() ?? '') : '';
        if (name.isEmpty) continue;
        items.add(IranLocation(name: name, province: province, isVillage: true));
      }
    }
    return items;
  }
}

class CityPickerField extends StatelessWidget {
  const CityPickerField({super.key, required this.city, required this.onChanged});

  final String? city;
  final ValueChanged<String?> onChanged;

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<IranLocation>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CityPickerSheet(),
    );
    if (selected != null) onChanged(selected.name);
  }

  @override
  Widget build(BuildContext context) {
    final selected = city?.trim().isNotEmpty == true;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_city_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selected ? city! : 'انتخاب شهر یا روستا',
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected ? null : Theme.of(context).hintColor,
                  ),
                ),
              ),
              if (selected) ...[
                const BlinkingGreenLight(),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'حذف',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.close),
                ),
              ] else
                const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet();

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final query = TextEditingController();
  List<IranLocation>? _villages;
  bool _loadingVillages = false;
  String? _villageError;

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> _ensureVillages() async {
    if (_villages != null || _loadingVillages) return;
    setState(() {
      _loadingVillages = true;
      _villageError = null;
    });
    try {
      final items = await IranVillagesLoader.instance.load();
      if (!mounted) return;
      setState(() {
        _villages = items;
        _loadingVillages = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingVillages = false;
        _villageError = 'بارگذاری روستاها ناموفق بود (اینترنت لازم است)';
      });
    }
  }

  List<IranLocation> get _filtered {
    final q = query.text.trim();
    final cities = iranCities
        .map((c) => IranLocation(name: c.name, province: c.province, isVillage: false))
        .toList();

    if (q.isEmpty) return cities;

    final cityHits = cities
        .where((c) => c.name.contains(q) || c.province.contains(q))
        .toList();

    final villages = _villages;
    if (villages == null) {
      if (q.length >= 2) _ensureVillages();
      return cityHits;
    }

    final villageHits = villages
        .where((v) => v.name.contains(q) || v.province.contains(q))
        .take(200)
        .toList();

    return [...cityHits, ...villageHits];
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'شهر یا روستا را انتخاب کن',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: query,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'جستجوی شهر، روستا یا استان',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            if (_loadingVillages)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_villageError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  _villageError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        query.text.trim().isEmpty
                            ? 'در حال نمایش شهرها…'
                            : 'موردی پیدا نشد',
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        return ListTile(
                          leading: Icon(
                            item.isVillage ? Icons.holiday_village_outlined : Icons.location_city,
                            size: 22,
                          ),
                          title: Text(item.name),
                          subtitle: Text(item.subtitle),
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
