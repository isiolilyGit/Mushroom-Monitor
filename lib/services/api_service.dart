import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakApi {
  static const String baseUrl = 'https://api.thingspeak.com/channels';

  /// Returns a list of { 'created_at': String, 'value': double } for a given field.
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
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final feeds = data['feeds'] as List;
      return feeds
          .where((feed) => feed['field$fieldNumber'] != null)
          .map((feed) => {
                'created_at': feed['created_at'],
                'value':
                    double.tryParse(feed['field$fieldNumber'].toString()) ??
                        0.0,
              })
          .toList();
    } else {
      throw Exception(
          'Failed to load feed (status ${response.statusCode})');
    }
  }
}