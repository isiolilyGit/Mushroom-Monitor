import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/farm.dart';
import '../services/api_service.dart';

class FarmDashboardScreen extends StatefulWidget {
  final Farm farm;
  const FarmDashboardScreen({super.key, required this.farm});

  @override
  State<FarmDashboardScreen> createState() => _FarmDashboardScreenState();
}

class _FarmDashboardScreenState extends State<FarmDashboardScreen> {
  late Future<List<List<Map<String, dynamic>>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchAllSensors();
  }

  double _safeDouble(dynamic v) {
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  DateTime _safeDate(dynamic v) {
    return DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
  }

  Future<void> _refresh() async {
    setState(() {
      _dataFuture = _fetchAllSensors();
    });
  }

  Future<List<List<Map<String, dynamic>>>> _fetchAllSensors() async {
    final futures = widget.farm.sensors.map((sensor) async {
      try {
        return await ThingSpeakApi.getFieldFeed(
          channelId: sensor.channelId,
          readApiKey: sensor.readApiKey,
          fieldKey: sensor.fieldKey,
          results: 200,
        );
      } catch (e) {
        debugPrint('ERROR ${sensor.label}: $e');
        return <Map<String, dynamic>>[];
      }
    }).toList();

    return Future.wait(futures);
  }

  bool _isOutOfRange(double value, SensorSource s) {
    final min = s.minIdeal ?? double.negativeInfinity;
    final max = s.maxIdeal ?? double.infinity;
    return value < min || value > max;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.farm.name)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<List<Map<String, dynamic>>>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final allData = snapshot.data ?? [];

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: widget.farm.sensors.length,
              itemBuilder: (context, index) {
                final sensor = widget.farm.sensors[index];
                final data = allData[index];
                return _buildSensorCard(sensor, data);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    SensorSource sensor,
    List<Map<String, dynamic>> rawData,
  ) {
    if (rawData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${sensor.label}: No data'),
        ),
      );
    }

    // =========================
    // FILTER LAST 6 HOURS
    // =========================
    final cutoff =
        DateTime.now().subtract(const Duration(hours: 6));

    final points = rawData.map((e) {
      return {
        'time': _safeDate(e['created_at']),
        'value': _safeDouble(e['value']),
      };
    }).where((e) => (e['time'] as DateTime).isAfter(cutoff)).toList();

    if (points.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('${sensor.label}: No recent data'),
        ),
      );
    }

    points.sort((a, b) =>
        (a['time'] as DateTime).compareTo(b['time'] as DateTime));

    final times = points.map((e) => e['time'] as DateTime).toList();
    final values = points.map((e) => e['value'] as double).toList();

    // =========================
    // RESAMPLE INTO 10-MIN BUCKETS (KEY FIX)
    // =========================
    const bucketMinutes = 10;
    const totalMinutes = 360;
    const bucketCount = totalMinutes ~/ bucketMinutes;

    final buckets = List<List<double>>.generate(
      bucketCount,
      (_) => [],
    );

    for (int i = 0; i < times.length; i++) {
      final minutesAgo =
          DateTime.now().difference(times[i]).inMinutes;

      if (minutesAgo < 0 || minutesAgo > totalMinutes) continue;

      final bucketIndex = minutesAgo ~/ bucketMinutes;

      if (bucketIndex >= 0 && bucketIndex < bucketCount) {
        buckets[bucketIndex].add(values[i]);
      }
    }

    final spots = <FlSpot>[];

    for (int i = 0; i < bucketCount; i++) {
      if (buckets[i].isEmpty) continue;

      final avg = buckets[i].reduce((a, b) => a + b) /
          buckets[i].length;

      final x = bucketCount - i.toDouble();

      spots.add(FlSpot(x, avg));
    }

    final latest = values.last;
    final isOut = _isOutOfRange(latest, sensor);

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);

    final padding = (maxY - minY) * 0.2;

    // =========================
    // UI
    // =========================
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(sensor.label,
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOut ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    latest.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: bucketCount.toDouble(),
                  minY: minY - padding,
                  maxY: maxY + padding,

                  gridData: const FlGridData(show: true),

                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 6,
                        getTitlesWidget: (value, meta) {
                          final hoursAgo =
                              ((bucketCount - value) * 10) ~/ 60;
                          final dt = DateTime.now()
                              .subtract(Duration(hours: hoursAgo));

                          return Text(
                            '${dt.hour}:00',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),

                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),

                  borderData: FlBorderData(show: false),

                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      color: isOut ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}