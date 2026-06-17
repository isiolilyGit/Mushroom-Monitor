import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/farm.dart';
import '../providers/farm_provider.dart';
class FarmSettingsScreen extends StatefulWidget {
  final Farm farm;

  const FarmSettingsScreen({super.key, required this.farm});

  @override
  State<FarmSettingsScreen> createState() => _FarmSettingsScreenState();
}

class _FarmSettingsScreenState extends State<FarmSettingsScreen> {
  late TextEditingController nameController;

  late List<TextEditingController> minControllers;
  late List<TextEditingController> maxControllers;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.farm.name);

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

  Future<void> _save() async {
    final provider = context.read<FarmProvider>();

    final updatedFarm = Farm(
      id: widget.farm.id,
      name: nameController.text.trim(),
      startDate: widget.farm.startDate,
      sensors: widget.farm.sensors,
    );

    for (int i = 0; i < updatedFarm.sensors.length; i++) {
      updatedFarm.sensors[i].minIdeal = double.tryParse(minControllers[i].text);
      updatedFarm.sensors[i].maxIdeal = double.tryParse(maxControllers[i].text);
    }

    await provider.updateFarm(updatedFarm);

    if(mounted) {
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farm Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Farm Name",
            ),
          ),

          const SizedBox(height: 20),

          ...List.generate(
            widget.farm.sensors.length,
            (index) {

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
                        )),
                        
                      TextField(
                        controller: maxControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Max Ideal",
                        )),
                    ],
                  ),
              ),
              );
            },
          )
        ],

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
  @override
  void dispose() {

  nameController.dispose();

  for(final c in minControllers){
    c.dispose();
  }

  for(final c in maxControllers){
    c.dispose();
  }

  super.dispose();
}
}