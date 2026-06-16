// sensor_models.dart
//

// PURPOSE
//
// This file contains all data models used by the Oyster Mushroom
// Environmental Monitoring and Control System.
//
// Models included:
//
// 1. GrowthStage
//    - Represents the current mushroom growth phase.
//
// 2. SensorReading
//    - Stores sensor values retrieved from ThingSpeak.
//
// 3. SensorStatus
//    - Defines possible classification states.
//
// 4. Threshold
//    - Defines acceptable environmental conditions for each stage.
//
// 5. ClassificationResult
//    - Stores the output of the Classification Engine.
//


// GROWTH STAGES
//
// Oyster mushrooms require different environmental conditions
// throughout their lifecycle.
//
// Stages:
//
// Spawn Run  -> Mycelium colonizes substrate
// Pinning    -> Initial mushroom formation
// Fruiting   -> Mushroom growth and development
// Harvest    -> Ready for collection
//

enum GrowthStage {
  spawnRun,
  pinning,
  fruiting,
  harvest,
}


// SENSOR READING MODEL
//
// Represents a single environmental reading retrieved
// from ThingSpeak.
//
// Example:
//
// Temperature = 24°C
// Humidity    = 70%
// CO₂         = 1500 ppm
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



// SENSOR STATUS
//
// Defines the possible environmental states determined
// by the Classification Engine.
//
// NORMAL   -> Conditions are optimal.
// WARNING  -> Conditions are slightly outside optimal range.
// CRITICAL -> Conditions may affect mushroom growth.
//

class SensorStatus {
  static const String normal = 'NORMAL';
  static const String warning = 'WARNING';
  static const String critical = 'CRITICAL';
}


// THRESHOLD MODEL
//
// Defines environmental limits used during classification.
//
// Different mushroom growth stages require different
// environmental conditions.
//
// The Classification Engine retrieves thresholds using:
//
// Threshold.forStage(stage)
//
// ============================================================================
class Threshold {

  // Temperature (°C)

  final double tempWarningMin;
  final double tempWarningMax;
  final double tempCriticalMin;
  final double tempCriticalMax;

  // Humidity (%)
  final double humidityWarningMin;
  final double humidityWarningMax;
  final double humidityCriticalMin;
  final double humidityCriticalMax;

  // CO₂ (ppm)
  
  final double co2WarningMax;
  final double co2CriticalMax;

  const Threshold({
    required this.tempWarningMin,
    required this.tempWarningMax,
    required this.tempCriticalMin,
    required this.tempCriticalMax,
    required this.humidityWarningMin,
    required this.humidityWarningMax,
    required this.humidityCriticalMin,
    required this.humidityCriticalMax,
    required this.co2WarningMax,
    required this.co2CriticalMax,
  });

  // STAGE-SPECIFIC THRESHOLDS
  //
  // Returns recommended environmental thresholds
  // for the specified mushroom growth stage.

  factory Threshold.forStage(GrowthStage stage) {
    switch (stage) {

      // SPAWN RUN
      //
      // Mycelium spreads throughout the substrate.
      // Higher CO₂ concentrations are acceptable.
      //
      case GrowthStage.spawnRun:
        return const Threshold(
          tempWarningMin: 22,
          tempWarningMax: 25,
          tempCriticalMin: 18,
          tempCriticalMax: 28,

          humidityWarningMin: 80,
          humidityWarningMax: 90,
          humidityCriticalMin: 70,
          humidityCriticalMax: 95,

          co2WarningMax: 1000,
          co2CriticalMax: 3000,
        );

      
      // PINNING
      //
      // Small mushroom pins begin to emerge.
      //
      case GrowthStage.pinning:
        return const Threshold(
          tempWarningMin: 21,
          tempWarningMax: 24,
          tempCriticalMin: 17,
          tempCriticalMax: 28,

          humidityWarningMin: 90,
          humidityWarningMax: 95,
          humidityCriticalMin: 80,
          humidityCriticalMax: 100,

          co2WarningMax: 600,
          co2CriticalMax: 1000,
        );

      
      // FRUITING
      //
      // Mushrooms grow to full size.
      //
      case GrowthStage.fruiting:
        return const Threshold(
          tempWarningMin: 18,
          tempWarningMax: 22,
          tempCriticalMin: 14,
          tempCriticalMax: 26,

          humidityWarningMin: 85,
          humidityWarningMax: 95,
          humidityCriticalMin: 80,
          humidityCriticalMax: 98,

          co2WarningMax: 1000,
          co2CriticalMax: 2000,
        );

      // HARVEST
      //
      // Mature mushrooms are ready for collection.
      //
      case GrowthStage.harvest:
        return const Threshold(
          tempWarningMin: 16,
          tempWarningMax: 24,
          tempCriticalMin: 12,
          tempCriticalMax: 28,

          humidityWarningMin: 80,
          humidityWarningMax: 90,
          humidityCriticalMin: 75,
          humidityCriticalMax: 95,

          co2WarningMax: 1200,
          co2CriticalMax: 2500,
        );
    }
  }
}


// CLASSIFICATION RESULT MODEL
//
// Produced by the Classification Engine after evaluating
// sensor readings against the appropriate thresholds.
//
// Example:
//
// Status  : WARNING
// Message : Humidity below optimal range
//

class ClassificationResult {
  final String status;

  final String message;

  final double temperature;
  final double humidity;
  final double co2;

  const ClassificationResult({
    required this.status,
    required this.message,
    required this.temperature,
    required this.humidity,
    required this.co2,
  });

  /// Returns true when conditions are optimal.
  bool get isNormal => status == SensorStatus.normal;

  /// Returns true when conditions require attention.
  bool get isWarning => status == SensorStatus.warning;

  /// Returns true when conditions require immediate action.
  bool get isCritical => status == SensorStatus.critical;

  @override
  String toString() {
    return '''
ClassificationResult(
  status: $status,
  message: $message,
  temperature: $temperature,
  humidity: $humidity,
  co2: $co2
)
''';
  }
}