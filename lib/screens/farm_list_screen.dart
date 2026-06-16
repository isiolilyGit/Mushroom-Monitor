import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import 'farm_dashboard_screen.dart';
import 'farm_form_screen.dart';

class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  @override
  void initState() {
    super.initState();

    // Load farms once when screen opens
    Future.microtask(() {
      context.read<FarmProvider>().loadFarms();
    });
  }

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
          ? const Center(
              child: Text('No farms yet. Add your first farm.'),
            )
          : ListView.builder(
              itemCount: provider.farms.length,
              itemBuilder: (context, index) {
                final farm = provider.farms[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(farm.name),
                    subtitle: Text('${farm.sensors.length} sensors'),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // IMPORTANT: delete by ID (not index)
                        provider.deleteFarm(farm.id);
                      },
                    ),

                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FarmDashboardScreen(farm: farm),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}