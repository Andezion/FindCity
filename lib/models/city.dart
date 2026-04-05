class City {
  final String name;
  final String nameEn;
  final String country;
  final String countryCode;
  final String region; // 'europe', 'asia', 'north_america', 'south_america', 'africa', 'oceania'
  final double lat;
  final double lng;
  final int population;
  final String description;

  const City({
    required this.name,
    required this.nameEn,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.lat,
    required this.lng,
    required this.population,
    required this.description,
  });
}
