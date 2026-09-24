import 'iran_cities_data0.dart';
import 'iran_cities_data1.dart';
import 'iran_cities_data2.dart';

class IranCity {
  const IranCity(this.name, this.province);
  final String name;
  final String province;
  String get label => province == name ? name : '$name — $province';
}

/// Generated from https://github.com/sajaddp/list-of-cities-in-Iran
/// Source: cities-filtered.json (official divisions through 1404)
List<IranCity> get iranCities {
  if (_cache != null) return _cache!;
  final items = <IranCity>[];
  for (final data in [iranCitiesData0, iranCitiesData1, iranCitiesData2]) {
    for (final e in data.entries) {
      for (final name in e.value) {
        items.add(IranCity(name, e.key));
      }
    }
  }
  return _cache = items;
}

List<IranCity>? _cache;
