import 'package:flutter/material.dart';
import '../models/farm.dart';

class FarmSettingsScreen extends StatefulWidget {
  final Farm farm;

  const FarmSettingsScreen({super.key, required this.farm});

  @override
  State<FarmSettingsScreen> createState() => _FarmSettingsScreenState();
}

class _FarmSettingsScreenState extends State<FarmSettingsScreen> {
  late List<TextEditingController> minControllers;
  late List<TextEditingController> maxControllers;

  @override
  void initState() {
    super.initState();

    minControllers = widget.farm.sensors
        .map((s) => TextEditingController(
              text: (s.minIdeal ?? 0).toString(),
            ))
        .toList();

    maxControllers = widget.farm.sensors
        .map((s) => TextEditingController(
              text: (s.maxIdeal ?? 0).toString(),
            ))
        .toList();
  }

  void _save() {
    for (int i = 0; i < widget.farm.sensors.length; i++) {
      final sensor = widget.farm.sensors[i];

      sensor.minIdeal = double.tryParse(minControllers[i].text);
      sensor.maxIdeal = double.tryParse(maxControllers[i].text);
    }

    Navigator.pop(context, widget.farm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farm Settings")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.farm.sensors.length,
        itemBuilder: (context, index) {
          final sensor = widget.farm.sensors[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sensor.label,
                      style: Theme.of(context).textTheme.titleMedium),

                  const SizedBox(height: 10),

                  TextField(
                    controller: minControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Min Ideal",
                    ),
                  ),

                  TextField(
                    controller: maxControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Max Ideal",
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _save,
          child: const Text("Save Settings"),
        ),
      ),
    );
  }
}