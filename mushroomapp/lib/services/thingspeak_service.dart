import 'dart:convert';
import 'package:http/http.dart' as http;

//
// ThingSpeakService
// 
// This service class is responsible for ALL communication with the ThingSpeak
// cloud API.
//
// It acts as a "middle layer" between the Flutter app and ThingSpeak, meaning:
// - UI does NOT call HTTP directly
// - Business logic does NOT deal with raw API calls
// - All network operations are centralized here
//
// Supported operations:
// 1. Fetch latest sensor readings
// 2. Fetch historical sensor data
// 3. Send sensor data to ThingSpeak channel
//

class ThingSpeakService {
  /// Base URL for ThingSpeak REST API
  final String _baseUrl = "https://api.thingspeak.com";

  /// Channel ID identifies your IoT data stream on ThingSpeak
  final String channelId;

  /// API key used for reading data (optional depending on channel privacy)
  final String? readApiKey;

  /// API key used for writing data (required for sending sensor updates)
  final String? writeApiKey;

  /// Constructor
  /// All configuration for a ThingSpeak channel is injected here.
  ThingSpeakService({
    required this.channelId,
    this.readApiKey,
    this.writeApiKey,
  });

  //
  /// fetchLatestFeed()
  //
  // Purpose:
  // Retrieves the most recent sensor reading from the ThingSpeak channel.
  //
  // API Endpoint:
  // GET /channels/{channelId}/feeds/last.json
  //
  // Returns:
  // - Map<String, dynamic> representing the latest feed
  // - null if request fails
  ///
  /// Example response fields:
  /// {
  ///   "field1": "25.5",  // temperature
  ///   "field2": "60",    // humidity
  ///   "field3": "400"    // CO2
  /// }
  ///
  /// Errors:
  /// Throws exception if HTTP request fails or API returns non-200 status.
  /// ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> fetchLatestFeed() async {
    try {
      final url = Uri.parse(
        "$_baseUrl/channels/$channelId/feeds/last.json?api_key=$readApiKey",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          "Failed to fetch latest feed. "
          "Status: ${response.statusCode}, Body: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("ThingSpeak fetchLatestFeed error: $e");
    }
  }

  /// ---------------------------------------------------------------------------
  /// fetchFeedHistory()
  /// ---------------------------------------------------------------------------
  /// Purpose:
  /// Retrieves multiple historical sensor readings from the channel.
  ///
  /// Use case:
  /// - Charts (line graphs)
  /// - Trend analysis
  /// - Machine learning preprocessing
  ///
  /// Parameters:
  /// - results: number of records to fetch (default = 10)
  ///
  /// API Endpoint:
  /// GET /channels/{channelId}/feeds.json
  ///
  /// Returns:
  /// - List of feed objects (each representing a sensor reading)
  ///
  /// Example:
  /// [
  ///   {"field1": "25.1", "field2": "55"},
  ///   {"field1": "25.3", "field2": "57"}
  /// ]
  /// ---------------------------------------------------------------------------
  Future<List<dynamic>> fetchFeedHistory({int results = 10}) async {
    try {
      final url = Uri.parse(
        "$_baseUrl/channels/$channelId/feeds.json"
        "?api_key=$readApiKey&results=$results",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['feeds'];
      } else {
        throw Exception(
          "Failed to fetch feed history. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("ThingSpeak fetchFeedHistory error: $e");
    }
  }

  //
  // sendSensorData()
  //
  // Purpose:
  // Sends sensor readings from your app or device to ThingSpeak.
  //
  // Typical use case:
  // - ESP32/Flutter app pushes sensor updates
  // - Simulated IoT data testing
  //
  // Parameters:
  // - fields: Map of sensor values
  //  Example:
  //   {
  //     "field1": "25.6",  // temperature
  //     "field2": "60",    // humidity
  //     "field3": "420"    // CO2
  //   }
  //
  // API Endpoint:
  // POST /update
  //
  // Returns:
  // - true if upload succeeds
  // - throws exception if failure occurs
  //
  Future<bool> sendSensorData({
    required Map<String, String> fields,
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/update");

      final body = {
        "api_key": writeApiKey ?? "",
        ...fields,
      };

      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          "Failed to send sensor data. Response: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("ThingSpeak sendSensorData error: $e");
    }
  }
}