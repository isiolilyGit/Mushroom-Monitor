import 'package:flutter/material.dart';
import '../services/api_service.dart';
//import '../models/farm.dart';

class SensorSetupScreen extends StatefulWidget {
  final int channelId;
  final String readApiKey;

  const SensorSetupScreen({
    super.key,
    required this.channelId,
    required this.readApiKey,
  });

  @override
  State<SensorSetupScreen> createState() => _SensorSetupScreenState();
}

class _SensorSetupScreenState extends State<SensorSetupScreen> {
  late Future<List<String>> _fieldsFuture;

  @override
  void initState() {
    super.initState();
    _fieldsFuture = ThingSpeakApi.detectFields(
      channelId: widget.channelId,
      readApiKey: widget.readApiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Sensors'),
      ),
      body: FutureBuilder<List<String>>(
        future: _fieldsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final fields = snapshot.data ?? [];

          if (fields.isEmpty) {
            return const Center(
              child: Text('No fields found in this channel'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Detected ThingSpeak Fields',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ...fields.map((fieldKey) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.sensors),
                    title: Text(fieldKey),
                    subtitle: Text('Auto-detected from channel'),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              }),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, fields);
                },
                child: const Text('Use These Sensors'),
              ),
            ],
          );
        },
      ),
    );
  }
}