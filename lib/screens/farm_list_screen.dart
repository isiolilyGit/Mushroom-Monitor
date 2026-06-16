import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/farm_provider.dart';
import 'farm_dashboard_screen.dart';
import 'farm_form_screen.dart';

class FarmListScreen extends StatelessWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Farms')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FarmFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Farm'),
      ),
      body: provider.farms.isEmpty
          ? const Center(child: Text('No farms added yet'))
          : ListView.builder(
              itemCount: provider.farms.length,
              itemBuilder: (context, index) {
                final farm = provider.farms[index];

                return ListTile(
                  title: Text(farm.name),
                  subtitle: Text('${farm.sensors.length} sensors'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<FarmProvider>().deleteFarm(farm.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FarmDashboardScreen(farm: farm),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}