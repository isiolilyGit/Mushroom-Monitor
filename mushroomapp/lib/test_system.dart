// test_system.dart

// ignore_for_file: avoid_print

import 'package:mushroomapp/models/sensor_models.dart';
import 'package:mushroomapp/services/thingspeak_service.dart';
import 'package:mushroomapp/logic/classification_engine.dart';

Future<void> main() async {
  final thingSpeak = ThingSpeakService(
    channelId: '3393042',
    readApiKey: '',
  );

  try {
    // Fetch data from ThingSpeak
    final reading = await thingSpeak.fetchLatestReading();

    print('\n=== SENSOR READING ===');
    print(reading);

    // Classify for Spawn Run stage
    final engine = ClassificationEngine(
      stage: GrowthStage.spawnRun,
    );

    final result = engine.classify(reading);

    print('\n=== CLASSIFICATION RESULT ===');
    print(result);

    print('\nStatus: ${result.status}');
    print('Message: ${result.message}');
  } catch (e) {
    print('ERROR: $e');
  }
}