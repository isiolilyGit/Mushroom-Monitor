// alert_service.dart
//
// Handles alert generation whenever environmental
// conditions become critical.

// ignore_for_file: avoid_print

class AlertService {
  DateTime? _lastAlertTime;

  /// Prevents repeated alerts every polling cycle.
  static const int cooldownMinutes = 30;

  Future<void> sendCriticalAlert({
    required String status,
    required String message,
  }) async {
    final now = DateTime.now();

    // Cooldown protection
    if (_lastAlertTime != null &&
        now.difference(_lastAlertTime!).inMinutes < cooldownMinutes) {
      return;
    }

    _lastAlertTime = now;

    print('\n');
    print('🚨🚨🚨 CRITICAL ALERT 🚨🚨🚨');
    print('Status : $status');
    print('Message: $message');
    print('Time   : $now');
    print('🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨🚨');
    print('\n');
  }
}