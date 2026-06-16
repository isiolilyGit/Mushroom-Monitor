import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakApi {
  static const String baseUrl = 'https://api.thingspeak.com/channels';

  static Future<List<Map<String, dynamic>>> getFieldFeed({
    required int channelId,
    required String readApiKey,
    required int fieldNumber,
    int results = 100,
  }) async {
    final url = Uri.parse(
      '$baseUrl/$channelId/feeds.json?api_key=$readApiKey&results=$results',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('ThingSpeak error: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    final feeds = (data['feeds'] as List?) ?? [];

    final parsed = feeds
        .map((feed) {
          final rawValue = feed['field$fieldNumber'];

          if (rawValue == null || rawValue.toString().isEmpty) {
            return null;
          }

          final value = double.tryParse(rawValue.toString());
          if (value == null) return null;

          final createdAt = DateTime.tryParse(feed['created_at'] ?? '');

          if (createdAt == null) return null;

          return {
            'created_at': createdAt.toIso8601String(),
            'value': value,
          };
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();

    // IMPORTANT: sort by time
    parsed.sort((a, b) =>
        DateTime.parse(a['created_at'])
            .compareTo(DateTime.parse(b['created_at'])));

    return parsed;
  }
}