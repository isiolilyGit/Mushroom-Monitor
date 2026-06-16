// classification_engine.dart

import 'package:mushroomapp/models/sensor_models.dart';

// ClassificationEngine
//
// Evaluates sensor readings against stage-specific thresholds.
//
// Produces:
// - NORMAL
// - WARNING
// - CRITICAL
///

class ClassificationEngine {
  final GrowthStage stage;

  ClassificationEngine({
    required this.stage,
  });

  ClassificationResult classify(SensorReading reading) {
    final threshold = Threshold.forStage(stage);

    String status = SensorStatus.normal;

    final reasons = <String>[];

  
    // TEMPERATURE

    if (reading.temperature <= threshold.tempCriticalMin ||
        reading.temperature >= threshold.tempCriticalMax) {
      status = SensorStatus.critical;

      reasons.add(
        'Temperature (${reading.temperature}°C) is critical.',
      );
    } else if (reading.temperature <= threshold.tempWarningMin ||
        reading.temperature >= threshold.tempWarningMax) {
      if (status != SensorStatus.critical) {
        status = SensorStatus.warning;
      }

      reasons.add(
        'Temperature (${reading.temperature}°C) is outside optimal range.',
      );
    }

    // HUMIDITY

    if (reading.humidity <= threshold.humidityCriticalMin ||
        reading.humidity >= threshold.humidityCriticalMax) {
      status = SensorStatus.critical;

      reasons.add(
        'Humidity (${reading.humidity}%) is critical.',
      );
    } else if (reading.humidity <= threshold.humidityWarningMin ||
        reading.humidity >= threshold.humidityWarningMax) {
      if (status != SensorStatus.critical) {
        status = SensorStatus.warning;
      }

      reasons.add(
        'Humidity (${reading.humidity}%) is outside optimal range.',
      );
    }

    // CO₂

    if (reading.co2 >= threshold.co2CriticalMax) {
      status = SensorStatus.critical;

      reasons.add(
        'CO₂ (${reading.co2} ppm) is critical.',
      );
    } else if (reading.co2 >= threshold.co2WarningMax) {
      if (status != SensorStatus.critical) {
        status = SensorStatus.warning;
      }

      reasons.add(
        'CO₂ (${reading.co2} ppm) is elevated.',
      );
    }

    // RESULT

    return ClassificationResult(
      status: status,
      message: reasons.isEmpty
          ? 'Environment is optimal for $stage.'
          : reasons.join(' '),
      temperature: reading.temperature,
      humidity: reading.humidity,
      co2: reading.co2,
    );
  }
}