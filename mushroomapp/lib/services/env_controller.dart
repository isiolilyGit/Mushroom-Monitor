// environment_controller.dart
//
// PURPOSE
//
// This controller is the CENTRAL ORCHESTRATOR of the system.
//
// It connects:
// 1. SensorRepository (data source)
// 2. ClassificationEngine (decision logic)
// 3. UI (live stream output)
//
// Flow:
// ThingSpeak → Repository → SensorReading → Engine → ClassificationResult → UI
//
// It also handles:
// - Continuous polling (since ThingSpeak is not real-time push)
// - Stream broadcasting to UI
// - Start/Stop lifecycle management
//

import 'dart:async';

import 'package:mushroomapp/models/sensor_models.dart';
import 'package:mushroomapp/repositories/sensor_repository.dart';
import 'package:mushroomapp/logic/classification_engine.dart';
import 'package:mushroomapp/services/email_alert_service.dart';
//import 'package:mushroomapp/config/alert_config.dart';

class EnvironmentController {
  final SensorRepository repository;
  final ClassificationEngine engine;
  final EmailAlertService emailalertService;

  List<String> _alertRecipients = [];

  EnvironmentController({
    required this.repository,
    required this.engine,
    required this.emailalertService,
  });

  
  // INTERNAL STREAM CONTROLLER
  

  final StreamController<ClassificationResult> _streamController =
      StreamController<ClassificationResult>.broadcast();

  Stream<ClassificationResult> get stream => _streamController.stream;

  Timer? _timer;
  bool _isRunning = false;


  void setAlertRecipients(List<String> emails) {
    _alertRecipients = emails;
  }

  List<String> get alertRecipients => _alertRecipients;
  // START LIVE MONITORING

  void startMonitoring({Duration interval = const Duration(seconds: 30)}) {
    if (_isRunning) return; // prevents multiple timers

    _isRunning = true;

    _timer = Timer.periodic(interval, (timer) async {
      try {
        // 1. Fetch latest sensor reading
        final SensorReading reading =
            await repository.getLatestReading();

        // 2. Classify environment state
        final ClassificationResult result =
            engine.classify(reading);

        // Trigger alert if critical
        if (_alertRecipients.isNotEmpty) {
          await emailalertService.sendCriticalAlert(
            recipientEmails: _alertRecipients,
            status: result.status,
            message: result.message,
            temperature: result.temperature,
            humidity: result.humidity,
            co2: result.co2,
          );
        }
        // 3. Push result to UI stream
        _streamController.add(result);
      } catch (e) {
        // If needed, you can emit error states to UI
        _streamController.addError(
          'Failed to fetch/classify sensor data: $e',
        );
      }
    });
  }

  // STOP LIVE MONITORING

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  // DISPOSE (IMPORTANT FOR FLUTTER)

  void dispose() {
    stopMonitoring();
    _streamController.close();
  }
}