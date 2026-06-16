// sensor_models.dart
//
// Contains all models related to:
// 1. Sensor readings from ThingSpeak
// 2. Threshold configuration
// 3. Classification results
//

// SENSOR READING MODEL
//
// Represents a single sensor reading retrieved from ThingSpeak.
//
// Example:
// Temperature = 24°C
// Humidity = 85%
// CO₂ = 950 ppm
//

class SensorReading {
  final double temperature;
  final double humidity;
  final double co2;
  final DateTime timestamp;

  const SensorReading({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.timestamp,
  });

  @override
  String toString() {
    return '''
SensorReading(
  temperature: $temperature,
  humidity: $humidity,
  co2: $co2,
  timestamp: $timestamp
)
''';
  }
}


// THRESHOLD MODEL

// Defines the acceptable minimum and maximum values
// for a sensor parameter.
//
// Example:
// Temperature:
// min = 20
// max = 25
//
class Threshold {
  final double min;
  final double max;

  const Threshold({
    required this.min,
    required this.max,
  });

  /// Returns true if the value is within range.
  bool isWithinRange(double value) {
    return value >= min && value <= max;
  }
}


// CLASSIFICATION RESULT MODEL

// Stores the classification outcome for a sensor.
//
// Example:
//
// Temperature:
// value = 24
// status = GOOD
//
class ClassificationResult {
  final String parameter;
  final double value;
  final String status;

  const ClassificationResult({
    required this.parameter,
    required this.value,
    required this.status,
  });
}

// SENSOR STATUS CONSTANTS

// Prevents magic strings from being repeated
// throughout the application.
//
class SensorStatus {
  static const String good = 'GOOD';
  static const String wrong = 'WRONG';
}