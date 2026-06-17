import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/sensor_reading.dart';
import '../../../core/services/thingspeak_service.dart';

final thingSpeakServiceProvider = Provider(
  (_) => ThingSpeakService(channel: MushroomChannel.controlled),
);

final thingSpeakUncontrolledServiceProvider = Provider(
  (_) => ThingSpeakService(channel: MushroomChannel.uncontrolled),
);

/// Polls the CONTROLLED channel every 15 seconds.
final liveSensorProvider = StreamProvider<SensorReading>((ref) {
  final service = ref.watch(thingSpeakServiceProvider);
  final controller = StreamController<SensorReading>();

  Future<void> poll() async {
    try {
      final reading = await service.fetchLatest();
      if (!controller.isClosed) controller.add(reading);
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  poll();
  final timer = Timer.periodic(const Duration(seconds: 15), (_) => poll());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Polls the UNCONTROLLED channel every 15 seconds.
final liveUncontrolledProvider = StreamProvider<SensorReading>((ref) {
  final service = ref.watch(thingSpeakUncontrolledServiceProvider);
  final controller = StreamController<SensorReading>();

  Future<void> poll() async {
    try {
      final reading = await service.fetchLatest();
      if (!controller.isClosed) controller.add(reading);
    } catch (e) {
      if (!controller.isClosed) controller.addError(e);
    }
  }

  poll();
  final timer = Timer.periodic(const Duration(seconds: 15), (_) => poll());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

/// History providers
final historyProvider = FutureProvider<List<SensorReading>>((ref) {
  return ref.watch(thingSpeakServiceProvider).fetchHistory(count: 50);
});

final historyUncontrolledProvider = FutureProvider<List<SensorReading>>((ref) {
  return ref
      .watch(thingSpeakUncontrolledServiceProvider)
      .fetchHistory(count: 50);
});
