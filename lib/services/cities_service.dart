import 'dart:math';
import '../models/city.dart';
import '../models/game_settings.dart';
import '../data/cities_data.dart';

class CitiesService {
  static List<City> getCitiesForRegion(GameRegion region) {
    if (region == GameRegion.world) return List.from(allCities);

    final key = region.key;
    return allCities.where((c) => c.region == key).toList();
  }

  static List<City> selectCities(GameRegion region, {int? count}) {
    final cities = getCitiesForRegion(region);

    cities.sort((a, b) => b.population.compareTo(a.population));

    final selected = _selectTopPerCountry(cities, topN: 3);

    final rng = Random();
    selected.shuffle(rng);

    if (count != null && count < selected.length) {
      return selected.sublist(0, count);
    }
    return selected;
  }

  static List<City> _selectTopPerCountry(List<City> sorted, {int topN = 3}) {
    final Map<String, int> countPerCountry = {};
    final List<City> result = [];

    for (final city in sorted) {
      final count = countPerCountry[city.countryCode] ?? 0;
      if (count < topN) {
        result.add(city);
        countPerCountry[city.countryCode] = count + 1;
      }
    }
    return result;
  }

  static List<City> getInfiniteQueue(GameRegion region) {
    final all = selectCities(region);
    final rng = Random();
    all.shuffle(rng);
    return all;
  }
}
