import 'package:flutter/material.dart';
import 'models/farm.dart';
import 'screens/farm_dashboard_screen.dart';
import 'package:uuid/uuid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mushroom Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const _BootstrapScreen(),
    );
  }
}

/// This avoids crashing if you later load farms from API or storage
class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    // TEMP DUMMY DATA (replace later with real API or storage)
    final farm = Farm(
      id: const Uuid().v4(),
      name: "Test Farm",
      sensors: [
        // You can leave empty OR add test sensors here
      ],
    );

    return FarmDashboardScreen(farm: farm);
  }
}