// File: lib/services/ai_service.dart
import 'package:http/http.dart' as http;
import 'package:jpmfood/data/config/ai_config.dart';
import 'dart:convert';
import 'package:jpmfood/data/models/restaurant_data_model.dart';

class AIService {
  final String _apiKey = AIConfig.apiKey;
  final String _apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  Future<String> sendMessage(
    String userMessage,
    List<RestaurantData> restaurants,
  ) async {
    try {
      // Build context about available restaurants
      String restaurantContext = '';

      if (restaurants.isNotEmpty) {
        restaurantContext = '\n\nAvailable restaurants:\n';
        for (var restaurant in restaurants) {
          restaurantContext += '- ${restaurant.adminName}';
          if (restaurant.menuItems.isNotEmpty) {
            restaurantContext += ' (${restaurant.menuItems.length} items)';

            // Add some menu items as examples
            final sampleItems = restaurant.menuItems
                .take(3)
                .map((e) => e.name)
                .join(', ');
            restaurantContext += ': $sampleItems';
          }
          restaurantContext += '\n';
        }
      }

      final systemPrompt =
          '''You are a friendly food delivery assistant. 
Help users with:
- Restaurant recommendations
- Menu information
- Order assistance
- General food delivery questions

Be concise, helpful, and conversational. Keep responses under 100 words.
$restaurantContext

User question: $userMessage''';

      // Construct the proper API URL with query parameter
      final apiUrl = '$_apiEndpoint?key=$_apiKey';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': systemPrompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if response has the expected structure
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          print('Unexpected response structure: ${response.body}');
          return 'Sorry, I received an unexpected response. Please try again!';
        }
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return 'Sorry, I\'m having trouble connecting right now. Please try again!';
      }
    } catch (e) {
      print('AI Error: $e');
      return 'Sorry, something went wrong. Please try again later!';
    }
  }
}
