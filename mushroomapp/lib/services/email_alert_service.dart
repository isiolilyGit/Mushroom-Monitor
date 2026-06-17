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
    required List<String> recipientEmails,
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

    // Send email to each recipient
    for (final email in recipientEmails) {
      await _sendEmail(
        recipientEmail: email,
        status: status,
        message: message,
        temperature: temperature,
        humidity: humidity,
        co2: co2,
        timestamp: now,
      );
    }
  }

  Future<void> _sendEmail({
    required String recipientEmail,
    required String status,
    required String message,
    required double temperature,
    required double humidity,
    required double co2,
    required DateTime timestamp,
  }) async {
    try {
      
      print('Sending alert to: $recipientEmail');

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
            'to_email': recipientEmail,
            'status': status,
            'message': message,
            'temperature': temperature,
            'humidity': humidity,
            'co2': co2,
            'timestamp': timestamp.toString(),
          }
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Email alert sent to $recipientEmail');
      } else {
        print('❌ Failed to send email to $recipientEmail');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Email error for $recipientEmail');
      print(e);
    }
  }
}