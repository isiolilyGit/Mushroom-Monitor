// test_system.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:mushroomapp/models/sensor_models.dart';
import 'package:mushroomapp/services/thingspeak_service.dart';
import 'package:mushroomapp/repositories/sensor_repository.dart';
import 'package:mushroomapp/logic/classification_engine.dart';
import 'package:mushroomapp/services/env_controller.dart';
import 'package:mushroomapp/screens/dashboard.dart';
import 'package:mushroomapp/services/email_alert_service.dart';

Future<void> main() async {
  final thingSpeak = ThingSpeakService(
    channelId: '3393042',
    readApiKey: '',
  );

  final repository = SensorRepository(
    thingSpeakService: thingSpeak,
  );

  final alertService = EmailAlertService();

  final controller = EnvironmentController(
    repository: repository,
    engine: ClassificationEngine(
      stage: GrowthStage.spawnRun,
    ),
    // alertService:  EmailAlertService(),
    emailalertService: alertService,
  );

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final EnvironmentController controller;

  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(controller: controller),
    );
  }
}