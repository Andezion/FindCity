import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/groq_config.dart';
import '../models/city.dart';
import '../models/game_settings.dart';

class GroqService {
  static Future<List<City>> fetchCities({
    required GameRegion region,
    required int count,
  }) async {
    if (!GroqConfig.isConfigured) {
      throw Exception('Groq API key not configured');
    }

    final regionPrompt = _regionPrompt(region);

    final prompt = '''
Generate a JSON array of $count ${regionPrompt}cities for a geography compass game.
Return ONLY a valid JSON array, no markdown, no explanation.
Each object must have exactly these fields:
{
  "name": "city name in Russian",
  "nameEn": "city name in English",
  "country": "country name in Russian",
  "countryCode": "ISO 3166-1 alpha-2 code",
  "lat": decimal latitude,
  "lng": decimal longitude,
  "population": integer (approximate city population),
  "description": "2-3 sentence interesting description in Russian"
}
Use accurate coordinates. Mix well-known and lesser-known cities.
''';

    final response = await http
        .post(
          Uri.parse(GroqConfig.baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${GroqConfig.apiKey}',
          },
          body: jsonEncode({
            'model': GroqConfig.model,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.7,
            'max_tokens': 4096,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;

    final cleaned = content
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final List<dynamic> json = jsonDecode(cleaned);
    return json.map((j) => _cityFromJson(j)).toList();
  }

  static City _cityFromJson(Map<String, dynamic> j) {
    return City(
      name: j['name'] as String,
      nameEn: j['nameEn'] as String,
      country: j['country'] as String,
      countryCode: (j['countryCode'] as String).toUpperCase(),
      region: '',
      lat: (j['lat'] as num).toDouble(),
      lng: (j['lng'] as num).toDouble(),
      population: (j['population'] as num).toInt(),
      description: j['description'] as String,
    );
  }

  static String _regionPrompt(GameRegion region) {
    switch (region) {
      case GameRegion.world:
        return 'worldwide ';
      case GameRegion.europe:
        return 'European ';
      case GameRegion.asia:
        return 'Asian ';
      case GameRegion.northAmerica:
        return 'North American ';
      case GameRegion.southAmerica:
        return 'South American ';
      case GameRegion.africa:
        return 'African ';
      case GameRegion.oceania:
        return 'Oceanian ';
    }
  }
}
