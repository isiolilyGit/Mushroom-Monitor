import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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

  Future<List<List<Map<String, dynamic>>>> _fetchAllSensors() async {
    final results = <List<Map<String, dynamic>>>[];
    for (var sensor in widget.farm.sensors) {
      try {
        final data = await ThingSpeakApi.getFieldFeed(
          channelId: sensor.channelId,
          readApiKey: sensor.readApiKey,
          fieldNumber: sensor.fieldNumber,
          results: 100,   // you can adjust this
        );
        results.add(data);
      } catch (e) {
        debugPrint('Error fetching ${sensor.label}: $e');
        results.add([]);  // empty list on error
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.farm.name)),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading data: ${snapshot.error}'),
            );
          }
          final allSensorData = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: List.generate(widget.farm.sensors.length, (index) {
              final sensor = widget.farm.sensors[index];
              final data = allSensorData[index];
              return _buildSensorChart(sensor.label, data);
            }),
          );
        },
      ),
    );
  }

  Widget _buildSensorChart(String label, List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('$label: No data (check connection / API key)'),
        ),
      );
    }

    final spots = data.map((entry) {
      final dateTime = DateTime.parse(entry['created_at']);
      // x‑axis uses milliseconds since epoch for accurate time spacing
      final x = dateTime.millisecondsSinceEpoch.toDouble();
      final y = (entry['value'] as num).toDouble();
      return FlSpot(x, y);
    }).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('MM/dd').format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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