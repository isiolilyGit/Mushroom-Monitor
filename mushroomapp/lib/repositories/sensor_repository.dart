// sensor_repository.dart
//
// PURPOSE
//
// Acts as an abstraction layer between:
// - ThingSpeakService (data source)
// - Application logic (classification, UI)
//
// Responsibilities:
// 1. Fetch sensor data from ThingSpeak via service
// 2. Convert/normalize data into SensorReading model
// 3. Hide API details from the rest of the app
//
// This allows swapping data sources later (Firebase, MQTT, etc.)
// without changing business logic.
//

import 'package:mushroomapp/models/sensor_models.dart';
import 'package:mushroomapp/services/thingspeak_service.dart';

class SensorRepository {
  final ThingSpeakService _thingSpeakService;

  SensorRepository({
    required this._thingSpeakService,
  });

  
  // GET LATEST SENSOR READING
  //
  // Flow:
  // ThingSpeak JSON → ThingSpeakService → SensorReading → Repository → App
  //
  // The repository ensures the app always works with clean domain models.
  //

  Future<SensorReading> getLatestReading() async {
    final reading = await _thingSpeakService.fetchLatestReading();

    return SensorReading(
      temperature: reading.temperature,
      humidity: reading.humidity,
      co2: reading.co2,
      timestamp: reading.timestamp,
    );
  }

  // WATCH LATEST SENSOR READING (STREAM)
  // LIVE STREAM SIMULATION SUPPORT
  //
  // ThingSpeak does not push real-time updates.
  // So we simulate streaming using polling.
  //
  // Useful for:
  // - UI auto-refresh dashboards
  // - Real-time monitoring screens
  //
  

  Stream<SensorReading> watchLatestReading({
    Duration interval = const Duration(seconds: 30),
  }) async* {
    while (true) {
      try {
        final reading = await getLatestReading();
        yield reading;
      } catch (e) {
        rethrow;
      }

      await Future.delayed(interval);
    }
  }
}