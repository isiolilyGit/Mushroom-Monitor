import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/farm.dart';
import '../providers/farm_provider.dart';

class FarmFormScreen extends StatefulWidget {
  const FarmFormScreen({super.key});

  @override
  State<FarmFormScreen> createState() => _FarmFormScreenState();
}

class _FarmFormScreenState extends State<FarmFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<_SensorInput> _sensors = [];   // dynamic list of sensor input groups

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

  void _saveFarm() {
    if (_formKey.currentState!.validate()) {
      final farm = Farm(
        name: _nameController.text.trim(),
        sensors: _sensors
            .map((s) => SensorSource(
                  channelId: int.parse(s.channelController.text),
                  readApiKey: s.apiKeyController.text.trim(),
                  fieldNumber: int.parse(s.fieldController.text),
                  label: s.labelController.text.trim(),
                ))
            .toList(),
      );
      context.read<FarmProvider>().addFarm(farm);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Farm')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Farm Name'),
              validator: (v) => v!.isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 24),
            Text('Sensors', style: Theme.of(context).textTheme.titleMedium),
            ..._sensors.asMap().entries.map((entry) {
              final idx = entry.key;
              final sensor = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: sensor.channelController,
                        decoration:
                            const InputDecoration(labelText: 'Channel ID'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: sensor.apiKeyController,
                        decoration:
                            const InputDecoration(labelText: 'Read API Key'),
                        validator: (v) =>
                            v!.isEmpty ? 'Required' : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: sensor.fieldController,
                              decoration: const InputDecoration(
                                  labelText: 'Field (1-8)'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 1 || n > 8) {
                                  return '1-8';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: sensor.labelController,
                              decoration:
                                  const InputDecoration(labelText: 'Label'),
                              validator: (v) =>
                                  v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeSensor(idx),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addSensor,
              icon: const Icon(Icons.add),
              label: const Text('Add Sensor'),
            ),
            const SizedBox(height: 24),
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
    for (var s in _sensors) {
      s.dispose();
    }
    super.dispose();
  }
}

// Helper class to hold TextEditingControllers for each sensor row
class _SensorInput {
  final channelController = TextEditingController();
  final apiKeyController = TextEditingController();
  final fieldController = TextEditingController();
  final labelController = TextEditingController();

  void dispose() {
    channelController.dispose();
    apiKeyController.dispose();
    fieldController.dispose();
    labelController.dispose();
  }
}