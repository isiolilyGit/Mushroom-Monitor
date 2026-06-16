// test_system.dart

// ignore_for_file: avoid_print

import 'package:mushroomapp/models/sensor_models.dart';
import 'package:mushroomapp/services/thingspeak_service.dart';
import 'package:mushroomapp/logic/classification_engine.dart';
import 'package:mushroomapp/repositories/sensor_repository.dart';
import 'package:mushroomapp/services/env_controller.dart';

Future<void> main() async {
  final thingSpeak = ThingSpeakService(
    channelId: '3393042',
    readApiKey: ''
  );

  final repository = SensorRepository(
    thingSpeakService: thingSpeak,
  );

  final controller = EnvironmentController(
  repository: repository,
  engine: ClassificationEngine(
    stage: GrowthStage.spawnRun,
  ),
);

 // Start live monitoring
  controller.startMonitoring(
    interval: const Duration(seconds: 10), // for testing
  );

  try {
    // Fetch data from ThingSpeak
    final reading = await repository.getLatestReading();

    print('\n=== SENSOR READING ===');
    print(reading);

    // Classify for Spawn Run stage
    final engine = ClassificationEngine(
      stage: GrowthStage.spawnRun,
    );

    final result = engine.classify(reading);

    // Listen to live classification results
  controller.stream.listen((result) {
    print('\n============================');
    print('STATUS: ${result.status}');
    print('MESSAGE: ${result.message}');
    print('TEMP: ${result.temperature}');
    print('HUMIDITY: ${result.humidity}');
    print('CO2: ${result.co2}');
    print('============================');
  });

    print('\n=== CLASSIFICATION RESULT ===');
    print(result);

    print('\nStatus: ${result.status}');
    print('Message: ${result.message}');
  } catch (e) {
    print('ERROR: $e');
  }
}