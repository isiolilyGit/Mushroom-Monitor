import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
  final List<_SensorInput> _sensors = [];

  final _uuid = const Uuid();

  void _addSensor() {
    setState(() => _sensors.add(_SensorInput()));
  }

  void _removeSensor(int index) {
    setState(() {
      _sensors[index].dispose();
      _sensors.removeAt(index);
    });
  }

  void _saveFarm() {
    if (!_formKey.currentState!.validate()) return;

    final farm = Farm(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      sensors: _sensors
          .map((s) => SensorSource(
                id: _uuid.v4(),
                channelId: int.parse(s.channelController.text),
                readApiKey: s.apiKeyController.text.trim(),
                fieldNumber: int.parse(s.fieldController.text),
                label: s.labelController.text.trim(),
                minIdeal: double.parse(s.minController.text),
                maxIdeal: double.parse(s.maxController.text),
              ))
          .toList(),
    );

    context.read<FarmProvider>().addFarm(farm);
    Navigator.pop(context);
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

            const SizedBox(height: 20),

            Text('Sensors', style: Theme.of(context).textTheme.titleMedium),

            ..._sensors.asMap().entries.map((entry) {
              final idx = entry.key;
              final s = entry.value;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: s.labelController,
                        decoration: const InputDecoration(labelText: 'Label'),
                      ),
                      TextFormField(
                        controller: s.channelController,
                        decoration:
                            const InputDecoration(labelText: 'Channel ID'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: s.apiKeyController,
                        decoration:
                            const InputDecoration(labelText: 'API Key'),
                      ),
                      TextFormField(
                        controller: s.fieldController,
                        decoration:
                            const InputDecoration(labelText: 'Field (1-8)'),
                        keyboardType: TextInputType.number,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: s.minController,
                              decoration:
                                  const InputDecoration(labelText: 'Min Ideal'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: s.maxController,
                              decoration:
                                  const InputDecoration(labelText: 'Max Ideal'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeSensor(idx),
                        ),
                      )
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

            ElevatedButton(
              onPressed: _saveFarm,
              child: const Text('Save Farm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorInput {
  final labelController = TextEditingController();
  final channelController = TextEditingController();
  final apiKeyController = TextEditingController();
  final fieldController = TextEditingController();
  final minController = TextEditingController();
  final maxController = TextEditingController();

  void dispose() {
    labelController.dispose();
    channelController.dispose();
    apiKeyController.dispose();
    fieldController.dispose();
    minController.dispose();
    maxController.dispose();
  }
}