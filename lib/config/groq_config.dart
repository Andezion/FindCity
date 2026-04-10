class GroqConfig {
  static const String apiKey = 'YOUR_GROQ_API_KEY_HERE';

  static const String model = 'llama-3.3-70b-versatile';
  static const String baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static bool get isConfigured =>
      apiKey.isNotEmpty && apiKey != 'YOUR_GROQ_API_KEY_HERE';
}
