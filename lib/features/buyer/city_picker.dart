import 'package:flutter/material.dart';
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

class CityPickerField extends StatelessWidget {
  const CityPickerField({super.key, required this.city, required this.onChanged});

  final String? city;
  final ValueChanged<String?> onChanged;

  Future<void> _open(BuildContext context) async {
    final selected = await showModalBottomSheet<IranCity>(
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
                  selected ? city! : 'انتخاب شهر',
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected ? null : Theme.of(context).hintColor,
                  ),
                ),
              ),
              if (selected) ...[
                const BlinkingGreenLight(),
                IconButton(
                  tooltip: 'حذف شهر',
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

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  List<IranCity> get _filtered {
    final q = query.text.trim();
    if (q.isEmpty) return iranCities;
    return iranCities.where((city) => city.name.contains(q) || city.province.contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cities = _filtered;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('شهر را انتخاب کن', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: query,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'جستجوی شهر یا استان',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: cities.isEmpty
                  ? const Center(child: Text('شهری پیدا نشد'))
                  : ListView.separated(
                      itemCount: cities.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final city = cities[i];
                        return ListTile(
                          title: Text(city.name),
                          subtitle: Text(city.province),
                          onTap: () => Navigator.pop(context, city),
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
