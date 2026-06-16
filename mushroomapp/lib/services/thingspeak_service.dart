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

// thingspeak_service.dart

import 'package:mushroomapp/models/sensor_models.dart';

// ThingSpeakService
//
// Handles communication with the ThingSpeak REST API.
//
// Responsibilities:
// - Fetch latest sensor reading
// - Convert JSON into SensorReading objects
//

class ThingSpeakService {
  static const String _baseUrl = 'https://api.thingspeak.com';

  final String channelId;
  final String readApiKey;

  const ThingSpeakService({
    required this.channelId,
    required this.readApiKey,
  });

  
  // Fetch Latest Reading
  //
  // Endpoint:
  // /channels/{channelId}/feeds/last.json
  //
  // Returns:
  //SensorReading
  //

  Future<SensorReading> fetchLatestReading() async {
    final url = Uri.parse(
      '$_baseUrl/channels/$channelId/feeds/last.json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch data. Status: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    return SensorReading(
      temperature: double.tryParse(data['field1'] ?? '0') ?? 0,
      humidity: double.tryParse(data['field2'] ?? '0') ?? 0,
      co2: double.tryParse(data['field3'] ?? '0') ?? 0,
      timestamp: DateTime.parse(data['created_at']).toLocal(),
    );
  }
}