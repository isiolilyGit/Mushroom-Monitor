import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:flutter/foundation.dart";

/// ThingSpeak API service (clean + final version)
class ThingSpeakApi {
  static const String baseUrl = 'https://api.thingspeak.com';

  /// ---------------------------------------------
  /// FETCH CHANNEL METADATA (for auto-detection)
  /// ---------------------------------------------
  static Future<Map<String, dynamic>> getChannelInfo({
    required int channelId,
    required String readApiKey,
  }) async {
    final url = Uri.parse(
      '$baseUrl/channels/$channelId.json?api_key=$readApiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load channel info');
    }

    return json.decode(response.body);
  }

  /// ---------------------------------------------
  /// FETCH FIELD DATA (LAST N RESULTS)
  /// fieldKey format: "field1", "field2", etc.
  /// ---------------------------------------------
  static Future<List<Map<String, dynamic>>> getFieldFeed({
    required int channelId,
    required String readApiKey,
    required String fieldKey,
    int results = 100,
  }) async {
    final url = Uri.parse(
      '$baseUrl/channels/$channelId/feeds.json'
      '?api_key=$readApiKey'
      '&results=$results',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load feed');
    }

    final data = json.decode(response.body);
    final feeds = data['feeds'] as List;
    debugPrint(
      "RAW RESPONSE: ${data.toString()}",);
    debugPrint("FIELD KEY: $fieldKey");
    debugPrint("FIRST FEED: ${feeds.isNotEmpty ? feeds.first : 'EMPTY'}");

    return feeds
        .where((f) => f[fieldKey] != null && double.tryParse(f[fieldKey].toString(),) != null,)
        .map(
          (f) => {
            'created_at': f['created_at'],
            'value': double.tryParse(f[fieldKey].toString(),),
          },
        )
        .toList();
  }

  /// ---------------------------------------------
  /// FETCH LAST 24 HOURS ONLY (IMPORTANT FOR DASHBOARD)
  /// ---------------------------------------------
  static Future<List<Map<String, dynamic>>> getRecentData({
    required int channelId,
    required String readApiKey,
    required String fieldKey,
    int hours = 6,
  }) async {
    final allData = await getFieldFeed(
      channelId: channelId,
      readApiKey: readApiKey,
      fieldKey: fieldKey,
      results: 800, // enough history for filtering
    );

    final now = DateTime.now();

    return allData.where((entry) {
      final time = DateTime.parse(entry['created_at'],);
      return now.difference(time).inHours <= hours;
    }).toList();
  }

  /// ---------------------------------------------
  /// AUTO-DETECT AVAILABLE FIELDS (VERY IMPORTANT)
  /// ---------------------------------------------
  static Future<List<String>> detectFields({
    required int channelId,
    required String readApiKey,
  }) async {
    final data = await getChannelInfo(
      channelId: channelId,
      readApiKey: readApiKey,
    );

    final channel = data['channel'];

    final List<String> fields = [];

    for (int i = 1; i <= 8; i++) {
      final key = 'field$i';
      if (channel[key] != null && channel[key].toString().isNotEmpty) {
        fields.add(key);
      }
    }

    return fields;
  }
}
