import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      final raw = await rootBundle.loadString('assets/data/iran_villages.json');
      final list = jsonDecode(raw) as List<dynamic>;
      final items = <IranLocation>[];
      for (final e in list) {
        final m = e as Map<String, dynamic>;
        final name = (m['n'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        items.add(IranLocation(
          name: name,
          province: (m['p'] as String?) ?? '',
          isVillage: true,
        ));
      }
      if (!mounted) return;
      setState(() {
        _villages = items;
        _loadingVillages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingVillages = false;
        _villageError = 'بارگذاری روستاها ناموفق بود';
      });
    }
  }

  List<IranLocation> get _filtered {
    final q = query.text.trim();
    final cities = iranCities
        .map((c) => IranLocation(name: c.name, province: c.province, isVillage: false))
        .toList();

    if (q.isEmpty) {
      return cities;
    }

    final cityHits = cities
        .where((c) => c.name.contains(q) || c.province.contains(q))
        .toList();

    final villages = _villages;
    if (villages == null) {
      if (q.length >= 2) {
        _ensureVillages();
      }
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
