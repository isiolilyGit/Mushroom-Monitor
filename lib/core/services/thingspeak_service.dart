import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mushroom_monitor/core/constants/api_endpoints.dart';
import 'package:mushroom_monitor/core/models/sensor_reading.dart';

enum MushroomChannel { controlled, uncontrolled }

class ThingSpeakService {
  final MushroomChannel channel;
  const ThingSpeakService({this.channel = MushroomChannel.controlled});

  String get _lastFeedUrl => channel == MushroomChannel.controlled
      ? ApiEndpoints.controlledLastFeed
      : ApiEndpoints.uncontrolledLastFeed;

  String _historyUrl(int count) => channel == MushroomChannel.controlled
      ? ApiEndpoints.controlledHistory(count)
      : ApiEndpoints.uncontrolledHistory(count);

  Future<SensorReading> fetchLatest() async {
    final response = await http.get(Uri.parse(_lastFeedUrl));
    if (response.statusCode != 200) {
      throw Exception('ThingSpeak error ${response.statusCode}');
    }
    return SensorReading.fromThingSpeak(json.decode(response.body));
  }

  Future<List<SensorReading>> fetchHistory({int count = 50}) async {
    final response = await http.get(Uri.parse(_historyUrl(count)));
    if (response.statusCode != 200) {
      throw Exception('ThingSpeak error ${response.statusCode}');
    }
    final feeds = json.decode(response.body)['feeds'] as List;
    return feeds.map((e) => SensorReading.fromThingSpeak(e)).toList();
  }
}
