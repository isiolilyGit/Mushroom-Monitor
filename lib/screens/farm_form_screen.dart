import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/farm.dart';
import '../providers/farm_provider.dart';
//import '../services/api_service.dart';

class FarmFormScreen extends StatefulWidget {
  const FarmFormScreen({super.key});

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final List<_SensorInput> _sensors = [];

  void _addSensor() {
    setState(() {
      _sensors.add(_SensorInput());
    });
  }

  void _removeSensor(int index) {
    setState(() {
      _sensors[index].dispose();
      _sensors.removeAt(index);
    });
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    final farm = Farm(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      sensors: _sensors.map((s) {
        return SensorSource(
          channelId: int.parse(s.channelController.text.trim()),
          readApiKey: s.apiKeyController.text.trim(),
          fieldKey: s.fieldKeyController.text.trim(), // IMPORTANT FIX
          label: s.labelController.text.trim(),
          minIdeal: double.tryParse(s.minController.text.trim()),
          maxIdeal: double.tryParse(s.maxController.text.trim()),
        );
      }).toList(),
    );

    await context.read<FarmProvider>().addFarm(farm);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Farm')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Farm Name'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter farm name' : null,
            ),

            const SizedBox(height: 20),

            Text(
              'Sensors (ThingSpeak Fields)',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 10),

            ..._sensors.asMap().entries.map((entry) {
              final index = entry.key;
              final sensor = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: sensor.channelController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Channel ID',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),

                      TextFormField(
                        controller: sensor.apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Read API Key',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),

                      TextFormField(
                        controller: sensor.fieldKeyController,
                        decoration: const InputDecoration(
                          labelText: 'Field Key (field1, field2...)',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),

                      TextFormField(
                        controller: sensor.labelController,
                        decoration: const InputDecoration(
                          labelText: 'Label (e.g. Temperature)',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: sensor.minController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min Ideal',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: sensor.maxController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Ideal',
                              ),
                            ),
                          ),
                        ],
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeSensor(index),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: _addSensor,
              icon: const Icon(Icons.add),
              label: const Text('Add Sensor'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveFarm,
              child: const Text('Save Farm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final s in _sensors) {
      s.dispose();
    }
    super.dispose();
  }
}

/// --------------------------------------
/// SENSOR INPUT HOLDER
/// --------------------------------------
class _SensorInput {
  final channelController = TextEditingController();
  final apiKeyController = TextEditingController();
  final fieldKeyController = TextEditingController();
  final labelController = TextEditingController();
  final minController = TextEditingController();
  final maxController = TextEditingController();

  void dispose() {
    channelController.dispose();
    apiKeyController.dispose();
    fieldKeyController.dispose();
    labelController.dispose();
    minController.dispose();
    maxController.dispose();
  }
}