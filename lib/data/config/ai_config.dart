// File: lib/config/ai_config.dart
class AIConfig {
  // Your Gemini API key
  static const String apiKey = 'YOUR API KEY';

  // Google Gemini (ACTIVE - Currently using this)
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  static const String geminiModel = 'gemini-2.5-flash';

  // Anthropic Claude (Alternative - not using)
  // static const String anthropicEndpoint = 'https://api.anthropic.com/v1/messages';
  // static const String anthropicVersion = '2023-06-01';
  // static const String model = 'claude-3-5-sonnet-20241022';

  // OpenAI (Alternative - not using)
  // static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  // static const String openAIModel = 'gpt-4';

  // Settings
  static const int maxTokens = 1024;
  static const int responseTimeout = 30; // seconds
}
