// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailAlertService {
  // EmailJS Configuration
  static const String serviceId = 'service_20r486b';
  static const String templateId = 'template_37n70ei';
  static const String publicKey = 'q9ZyaTucDpHE5OiBo';

  // Prevent repeated alerts
  DateTime? _lastAlertTime;

  static const int cooldownMinutes = 30;

  Future<void> sendCriticalAlert({
    required String status,
    required String message,
    required double temperature,
    required double humidity,
    required double co2,
  }) async {
    final now = DateTime.now();

    // Cooldown protection
    if (_lastAlertTime != null &&
        now.difference(_lastAlertTime!).inMinutes < cooldownMinutes) {
      return;
    }

    _lastAlertTime = now;

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'status': status,
            'message': message,
            'temperature': temperature,
            'humidity': humidity,
            'co2': co2,
            'timestamp': now.toString(),
          }
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email alert sent successfully');
      } else {
        print('❌ Email alert failed');
        print(response.body);
      }
    } catch (e) {
      print('❌ Email error: $e');
    }
  }
}